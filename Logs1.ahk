;-----------------------------------------------------------------------
;	名称：Logs1.ahk (AHK v2版)
;	機能：紅皿のログ表示
;	ver.0.2.0.0 .... 2026/3/28 (v2 modified)
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
global LogGui := ""
global LogDispCtrls := []

;-----------------------------------------------------------------------
; 機能：ログダイアログの表示 (旧 Logs: ラベル)
;-----------------------------------------------------------------------
ShowLogs() {
    global LogGui, LogDispCtrls

    if WinExist("紅皿ログ") {
        WinActivate("紅皿ログ")
        return
    }
    
    ; GUIオブジェクトの生成
    LogGui := Gui("", "紅皿ログ")
    LogGui.OnEvent("Close", LogButtonClose) ; ウィンドウの[X]ボタンが押された時の処理
    
    LogGui.SetFont("s9 c000000")
    
    ; ボタンの作成とクリックイベントの割り当て
    btnSave := LogGui.Add("Button", "x343 y666 w77 h22", "ログ保存")
    btnSave.OnEvent("Click", LogButtonSave)
    
    btnClose := LogGui.Add("Button", "x431 y666 w77 h22", "閉じる")
    btnClose.OnEvent("Click", LogButtonClose)
    
    LogGui.SetFont("s9 c000000", "ＭＳ ゴシック")
    LogGui.Add("Text", "x30 y10", "__TIME|PERIOD| INPUT           |O|MD  |TG |OVL| TOUT |SEND")
    
    ; v2では動的な変数名(vdisp%A_Index%)の代わりに、配列にコントロールオブジェクトを格納します
    LogDispCtrls := []
    Loop 64 {
        _yaxis := A_Index * 10 + 10
        _disp := "_                                                               _                                                               "
        ctrl := LogGui.Add("Text", "x30 y" _yaxis, _disp)
        LogDispCtrls.Push(ctrl)
    }
    
    LogGui.Show("w547 h700")
    
    ; タイマーには関数オブジェクトを渡します
    SetTimer(LogRedraw, 500)
}

;-----------------------------------------------------------------------
; 機能：ログ再描画 (旧 LogRedraw: ラベル)
;-----------------------------------------------------------------------
LogRedraw() {
    global LogGui, LogDispCtrls, idxLogs, aLogCnt, g_Log
    
    ; GUIが既に閉じられている場合はタイマーを停止
    if (!LogGui) {
        SetTimer(LogRedraw, 0)
        return
    }

    Loop 64 {
        _idx := (idxLogs - aLogCnt + A_Index - 1) & 63
        
        ; v2では未割り当ての配列要素にアクセスするとエラーになるため、Has()でチェックします
        logStr := g_Log.Has(_idx) ? g_Log[_idx] : ""
        _disp := logStr . "                                                                                                                                "
        
        ; GuiControlコマンドの代わりに、コントロールオブジェクトのValueプロパティを更新します
        if (LogDispCtrls.Has(A_Index)) {
            try LogDispCtrls[A_Index].Value := _disp
        }
    }
}

;-----------------------------------------------------------------------
; 機能：ログ保存ボタンの押下 (旧 gButtonSave: ラベル)
;-----------------------------------------------------------------------
LogButtonSave(btn, info) {
    global g_DataDir, g_Ver, g_OverlapMO, g_OverlapOM, g_OverlapSS
    global g_Threshold, g_ThresholdSS, g_Continue, g_ZeroDelay, g_KeySingle, g_KeyRepeat
    global idxLogs, aLogCnt, g_Log

    SetWorkingDir(g_DataDir)
    
    ; FileSelectFile は FileSelect 関数になりました
    vLogFileAbs := FileSelect("S", ".\" A_Now ".log", , "Log File (*.log)")
    
    if (vLogFileAbs != "") {
        file := FileOpen(vLogFileAbs, "w")
        if (file) {
            file.WriteLine(g_Ver . "`r`n")
            file.WriteLine("オーバラップ文字親指=" . g_OverlapMO . "`r")
            file.WriteLine("オーバラップ親指文字=" . g_OverlapOM . "`r")
            file.WriteLine("オーバラップ文字同時=" . g_OverlapSS . "`r")
            file.WriteLine("親指シフト同時打鍵間隔=" . g_Threshold . "`r")
            file.WriteLine("文字同時打鍵間隔=" . g_ThresholdSS . "`r")
            file.WriteLine("連続モード=" . g_Continue . "`r")
            file.WriteLine("零遅延モード=" . g_ZeroDelay . "`r")
            file.WriteLine("親指キー単独打鍵=" . g_KeySingle . "`r")
            file.WriteLine("親指キーリピート=" . g_KeyRepeat . "`r")
            file.WriteLine("  TIME|PERIOD| INPUT           |O|MD  |TG |OVL| TOUT |SEND`r")
            Loop 64 {
                _idx := (idxLogs - aLogCnt + A_Index - 1) & 63
                logStr := g_Log.Has(_idx) ? g_Log[_idx] : ""
                file.WriteLine(logStr . "`r")
            }
            file.Close() ; v2では大文字Cの Close() になります
        }
    }
    
    SetTimer(LogRedraw, 0)
    LogButtonClose() ; 古いGUIを破棄
    ShowLogs()       ; Goto, Logs の代わりに再呼び出しして開き直す
}

;-----------------------------------------------------------------------
; 機能：閉じるボタンの押下 (旧 gButtonClose: ラベル)
;-----------------------------------------------------------------------
LogButtonClose(ctrl := "", info := "") {
    global LogGui
    SetTimer(LogRedraw, 0) ; SetTimer(関数, 0) でオフにします
    if (LogGui) {
        LogGui.Destroy()
        LogGui := ""
    }
}