;-----------------------------------------------------------------------
;	名称：Settings7.ahk (AHK v2版)
;	機能：紅皿のパラメータ設定
;	ver.0.2.0.0 .... 2026/3/28 (v2 modified)
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
#include Gdip_all.ahk
global SettingsGui := ""
global g_isDialog := 0
global g_TabName := "配列"
global GuiLayoutHash := Map("A", "英数", "R", "ローマ字")
global ShiftMode := Map()

StartGdi() {
	global pToken
	; Start gdi+
	pToken := Gdip_Startup()
	if (!pToken) {
		MsgBox("gdiplus error! Gdiplus failed to start. Please ensure you have gdiplus on your system", , 48)
		ExitApp()
	}
}

CloseGdi() {
	global pToken
	; gdi+ may now be shutdown
	Gdip_Shutdown(pToken)
}

;-----------------------------------------------------------------------
; Iniファイルの読み込み
;-----------------------------------------------------------------------
InitSettings() {
	global
	
	SetWorkingDir(g_DataDir)
	g_IniFile := g_DataDir . "\benizara.ini"
	
	if (!Path_FileExists(g_IniFile)) {
		g_LayoutFile := ".\NICOLA配列.bnz"
		IniWrite(g_LayoutFile, g_IniFile, "FilePath", "LayoutFile")
		g_Continue := 1
		IniWrite(g_Continue, g_IniFile, "Key", "Continue")
		g_Threshold := 100
		IniWrite(g_Threshold, g_IniFile, "Key", "Threshold")
		g_ThresholdSS := 250
		IniWrite(g_ThresholdSS, g_IniFile, "Key", "ThresholdSS")
		g_ZeroDelay := 1
		IniWrite(g_ZeroDelay, g_IniFile, "Key", "ZeroDelay")
		g_OverlapOM := 35
		IniWrite(g_OverlapOM, g_IniFile, "Key", "OverlapOM")
		g_OverlapMO := 70
		IniWrite(g_OverlapMO, g_IniFile, "Key", "OverlapMO")
		g_OverlapOMO := 70
		IniWrite(g_OverlapOMO, g_IniFile, "Key", "OverlapOMO")
		g_OverlapSS := 100
		IniWrite(g_OverlapSS, g_IniFile, "Key", "OverlapSS")
		g_OyaKey := "無変換－変換"
		IniWrite(g_OyaKey, g_IniFile, "Key", "OyaKey")
		g_KeySingle := "無効"
		IniWrite(g_KeySingle, g_IniFile, "Key", "KeySingle")
		State.PauseKey := "Pause"
		IniWrite(State.PauseKey, g_IniFile, "Key", "KeyPause")
	}
	
	g_LayoutFile := IniRead(g_IniFile, "FilePath", "LayoutFile", ".\NICOLA配列.bnz")
	g_Continue := IniRead(g_IniFile, "Key", "Continue", 1)
	if (g_Continue > 1) 
		g_Continue := 1
	if (g_Continue < 0)
		g_Continue := 0
		
	g_ZeroDelay := IniRead(g_IniFile, "Key", "ZeroDelay", 1)
	if (g_ZeroDelay > 1) 
		g_ZeroDelay := 1
	if (g_ZeroDelay < 0)
		g_ZeroDelay := 0
		
	g_Threshold := IniRead(g_IniFile, "Key", "Threshold", 100)
	if (g_Threshold < 10)
		g_Threshold := 10
	if (g_Threshold > 400)
		g_Threshold := 400
		
	g_ThresholdSS := IniRead(g_IniFile, "Key", "ThresholdSS", 250)
	if (g_ThresholdSS < 10)
		g_ThresholdSS := 10
	if (g_ThresholdSS > 400)
		g_ThresholdSS := 400
		
	g_OverlapMO := IniRead(g_IniFile, "Key", "OverlapMO", 70)
	if (g_OverlapMO < 10)
		g_OverlapMO := 10
	if (g_OverlapMO > 90)
		g_OverlapMO := 90
		
	g_OverlapOM := IniRead(g_IniFile, "Key", "OverlapOM", 35)
	if (g_OverlapOM < 10)
		g_OverlapOM := 10
	if (g_OverlapOM > 90)
		g_OverlapOM := 90
		
	g_OverlapOMO := IniRead(g_IniFile, "Key", "OverlapOMO", 70)
	if (g_OverlapOMO < 10)
		g_OverlapOMO := 10
	if (g_OverlapOMO > 90)
		g_OverlapOMO := 90
		
	g_OverlapSS := IniRead(g_IniFile, "Key", "OverlapSS", 100)
	if (g_OverlapSS < 10)
		g_OverlapSS := 10
	if (g_OverlapSS > 90)
		g_OverlapSS := 90
		
	g_OyaKey := IniRead(g_IniFile, "Key", "OyaKey", "無変換－変換")
	if (g_OyaKey != "無変換－変換" && g_OyaKey != "無変換－空白" && g_OyaKey != "空白－変換")
		g_OyaKey := "無変換－変換"
	vOyaKey := g_OyaKey
	
	g_KeySingle := IniRead(g_IniFile, "Key", "KeySingle", "無効")
	if (g_KeySingle != "有効" && g_KeySingle != "無効")
		g_KeySingle := "無効"
	
	if (g_KeySingle == "有効") {
		g_KeyRepeat := 1
	} else {
		g_KeyRepeat := 0
	}
	
	State.PauseKey := IniRead(g_IniFile, "Key", "KeyPause", "Pause")
	if (State.PauseKey != "Pause" && State.PauseKey != "ScrollLock" && State.PauseKey != "無効")
		State.PauseKey := "Pause"
		
	RemapOya()
}
	
;-----------------------------------------------------------------------
; 機能：設定ダイアログの表示
;-----------------------------------------------------------------------
ShowSettings() {
	global
	
	; tryで囲むことで、破棄済みのGUIにアクセスしてエラーになるのを防ぎます
	try {
		if (SettingsGui && WinExist(SettingsGui.Hwnd)) {
			WinActivate(SettingsGui.Hwnd)
			return
		}
	}
	
	vLayoutFile := g_LayoutFile
	g_CurrSimulMode := "…"
	BuildSettingsGui()
}

BuildSettingsGui() {
	global
	
	g_isDialog := 1
	SettingsGui := Gui("", "紅皿設定")
	SettingsGui.OnEvent("Close", GuiClose)
	
	SettingsGui.SetFont("s10 c000000")
	
	btnOk := SettingsGui.Add("Button", "x530 y405 w80 h22", "ＯＫ")
	btnOk.OnEvent("Click", gButtonOk)
	
	btnCancel := SettingsGui.Add("Button", "x620 y405 w80 h22", "キャンセル")
	btnCancel.OnEvent("Click", gButtonCancel)
	
	TabCtrl := SettingsGui.Add("Tab3", "x10 y10 w740 h390 vTabName", ["配列", "親指シフト", "文字同時打鍵", "状態", "紅皿について"])
	TabCtrl.OnEvent("Change", gTabChange)
	
	g_TabName := "配列"
	
	;==================== Tab 1: 配列 ====================
	TabCtrl.UseTab(1)
	SettingsGui.SetFont("underline")
	txtLayoutURL := SettingsGui.Add("Text", "x30 y40 cBlue", g_layoutName . "　" . g_layoutVersion)
	txtLayoutURL.OnEvent("Click", gLayoutURL)
	
	SettingsGui.SetFont("Norm")
	SettingsGui.Add("Text", "x320 y40", "定義ファイル：")
	SettingsGui.Add("Edit", "x400 y40 w220 h20 ReadOnly vFilePath", vLayoutFile)
	btnFileSelect := SettingsGui.Add("Button", "x630 y40 w32 h21", "…")
	btnFileSelect.OnEvent("Click", gFileSelect)

	if(ShiftMode.Has("R") && (ShiftMode["R"] == "親指シフト" || ShiftMode["R"] == "文字同時打鍵"))
	{
		SettingsGui.Add("Text", "x30 y70", "親指シフトキー：")
		
		oyaOptions := []
		if (ShiftMode["R"] == "文字同時打鍵") {
			oyaOptions := ["…"]
			ddlOya := SettingsGui.Add("DropDownList", "x133 y70 w125 vOyaKey", oyaOptions)
			ddlOya.Value := 1  ; リストの1番目(…)を選択状態にする
		} else {
			oyaOptions := ["無変換－変換", "無変換－空白", "空白－変換"]
			ddlOya := SettingsGui.Add("DropDownList", "x133 y70 w125 vOyaKey", oyaOptions)
			try ddlOya.Text := g_OyaKey  ; 現在の設定値を選択状態にする
		}
		ddlOya.OnEvent("Change", gOya)
		
		SettingsGui.Add("Text", "x290 y70", "単独打鍵：")
		
		singleOptions := []
		if (ShiftMode["R"] == "文字同時打鍵") {
			singleOptions := ["…"]
			ddlSingle := SettingsGui.Add("DropDownList", "x360 y70 w95 vKeySingle", singleOptions)
			ddlSingle.Value := 1  ; 1番目の「…」を選択
		} else {
			singleOptions := ["無効", "有効"]
			ddlSingle := SettingsGui.Add("DropDownList", "x360 y70 w95 vKeySingle", singleOptions)
			; 現在の g_KeySingle の値（"無効" または "有効"）に一致する項目を選択
			try ddlSingle.Text := g_KeySingle
		}
		ddlSingle.OnEvent("Change", gKeySingle)
		
		SettingsGui.Add("Text", "x490 y70", "同時打鍵の表示：")
		s_ddlist := RefreshSimulKeyMenu()
		; StrSplit で配列化したものを渡し、変数 ddlSimul にコントロールオブジェクトを格納
		ddlSimul := SettingsGui.Add("DropDownList", "x600 y70 w95 vCurrSimulMode", StrSplit(s_ddlist, "|"))
		
		; 現在の設定値 (g_CurrSimulMode) を初期選択状態にする
		try ddlSimul.Text := g_CurrSimulMode
		
		; イベントハンドラを登録（関数名が gCurrSimulMode_Change であることを確認してください）
		ddlSimul.OnEvent("Change", gCurrSimulMode_Change)
	}
	else if(ShiftMode.Has("R") && ShiftMode["R"] == "プレフィックスシフト")
	{
		SettingsGui.Add("Text", "x30 y70", "プレフィックスシフトを用いた配列です")
	}
	
	SettingsGui.SetFont("s10 c000000", "Meiryo UI")
	G2DrawKeyFrame(State.Romaji)
	SettingsGui.SetFont("s9 c000000", "Meiryo UI")
	SettingsGui.Add("Edit", "x60 y370 w650 h20 -Vscroll vEdit", "")
	G2RefreshLayout()
	
	;==================== Tab 2: 親指シフト ====================
	TabCtrl.UseTab(2)
	SettingsGui.SetFont("s10 c000000", "Meiryo UI")
	SettingsGui.Add("Edit", "x20 y40 w300 h20 ReadOnly -Vscroll", "親指シフトキーの押し続けをシフトオンとします。")
	chkCont := SettingsGui.Add("Checkbox", "x+20 y40 vContinue", "連続シフト")
	chkCont.Value := g_Continue
	chkCont.OnEvent("Click", gContinue)

	SettingsGui.Add("Edit", "x20 y70 w300 h20 ReadOnly -Vscroll", "キー打鍵と共に遅延なく候補文字を表示します。")
	chkZero := SettingsGui.Add("Checkbox", "x+20 y70 vZeroDelay", "零遅延モード")
	chkZero.Value := g_ZeroDelay
	chkZero.OnEvent("Click", gZeroDelay)
	
	SettingsGui.Add("Edit", "x20 y100 w300 h60 ReadOnly -Vscroll", "親指シフトキー⇒文字キーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。")
	SettingsGui.Add("Text", "x+20 y100 w230 h20", "親指キー⇒文字キーの重なりの割合：")
	SettingsGui.Add("Edit", "x+3 y98 w50 ReadOnly vOverlapNumOM", g_OverlapOM)
	SettingsGui.Add("Text", "x+10 y100 c000000", "[`%]")
	sldOM := SettingsGui.Add("Slider", "x320 y130 w400 vOlSliderOM Range10-90 Line10 TickInterval10", g_OverlapOM)
	sldOM.OnEvent("Change", gOlSliderOM)

	SettingsGui.Add("Edit", "x20 y170 w300 h60 ReadOnly -Vscroll", "文字キー⇒親指シフトキーの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。")
	SettingsGui.Add("Text", "x+20 y170 w230 h20", "文字キー⇒親指キーの重なりの割合：")
	SettingsGui.Add("Edit", "x+3 y168 w50 ReadOnly vOverlapNumMO", g_OverlapMO)
	SettingsGui.Add("Text", "x+10 y170 c000000", "[`%]")
	sldMO := SettingsGui.Add("Slider", "x320 y200 w400 vOlSliderMO Range10-90 Line10 TickInterval10", g_OverlapMO)
	sldMO.OnEvent("Change", gOlSliderMO)

	SettingsGui.Add("Edit", "x20 y240 w300 h60 ReadOnly -Vscroll", "文字キー⇒親指シフトキーオフ⇒文字キーオフの順の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。")
	SettingsGui.Add("Text", "x+20 y240 w230 h20", "親指キーオフ時の重なりの割合：")
	SettingsGui.Add("Edit", "x+3 y238 w50 ReadOnly vOverlapNumOMO", g_OverlapOMO)
	SettingsGui.Add("Text", "x+10 y240 c000000", "[`%]")
	sldOMO := SettingsGui.Add("Slider", "x320 y270 w400 vOlSliderOMO Range10-90 Line10 TickInterval10", g_OverlapOMO)
	sldOMO.OnEvent("Change", gOlSliderOMO)

	SettingsGui.Add("Edit", "x20 y310 w300 h60 ReadOnly -Vscroll", "文字キーと親指シフトキーの打鍵の重なり期間やが何ミリ秒のときに同時打鍵であるかを決定します。")
	SettingsGui.Add("Text", "x+20 y310 w230 h20", "文字キーと親指キーの重なりの判定時間：")
	SettingsGui.Add("Edit", "x+3 y308 w50 ReadOnly vThresholdNum", g_Threshold)
	SettingsGui.Add("Text", "x+10 y310 c000000", "[mSEC]")
	sldTh := SettingsGui.Add("Slider", "x320 y340 w400 vThSlider Range10-400 Line10 TickInterval10", g_Threshold)
	sldTh.OnEvent("Change", gThSlider)

	;==================== Tab 3: 文字同時打鍵 ====================
	TabCtrl.UseTab(3)
	SettingsGui.Add("Edit", "x20 y40 w300 h60 ReadOnly -Vscroll", "キー打鍵と共に遅延なく候補文字を表示します。")
	chkZeroSS := SettingsGui.Add("Checkbox", "x+20 y65 vZeroDelaySS", "零遅延モード")
	chkZeroSS.Value := g_ZeroDelay
	chkZeroSS.OnEvent("Click", gZeroDelaySS_Click)
	
	SettingsGui.Add("Edit", "x20 y110 w300 h60 ReadOnly -Vscroll", "文字キー同志の打鍵の重なりが打鍵全体の何％のときに、同時打鍵であるかを決定します。")
	SettingsGui.Add("Text", "x+20 y110 w230 h20", "文字キー同志の重なりの割合：")
	SettingsGui.Add("Edit", "x+3 y108 w50 ReadOnly vOverlapNumSS", g_OverlapSS)
	SettingsGui.Add("Text", "x+10 y110 c000000", "[`%]")
	sldSS := SettingsGui.Add("Slider", "x320 y140 w400 vOlSliderSS Range10-90 Line10 TickInterval10", g_OverlapSS)
	sldSS.OnEvent("Change", gOlSliderSS)
	
	SettingsGui.Add("Edit", "x20 y180 w300 h60 ReadOnly -Vscroll", "文字キー同志の打鍵の重なり期間が何ミリ秒のときに同時打鍵であるかを決定します。")
	SettingsGui.Add("Text", "x+20 y180 w230 h20", "文字キー同志の重なりの判定時間：")
	SettingsGui.Add("Edit", "x+3 y178 w50 ReadOnly vThresholdNumSS", g_ThresholdSS)
	SettingsGui.Add("Text", "x+10 y180 c000000", "[mSEC]")
	sldThSS := SettingsGui.Add("Slider", "x320 y210 w400 vThSliderSS Range10-400 Line10 TickInterval10", g_ThresholdSS)
	sldThSS.OnEvent("Change", gThSliderSS)
	
	;==================== Tab 4: 状態 ====================
	TabCtrl.UseTab(4)
	SettingsGui.SetFont("s10 c000000", "Meiryo UI")
	SettingsGui.Add("Edit", "x20 y40 w300 h20 ReadOnly -Vscroll", "紅皿を一時停止させるキーを決定します。")
	
	
	; オプション配列は常に共通でOK
	pauseOptions := ["Pause", "ScrollLock", "無効"]
	
	; ドロップダウンを追加
	ddlPause := SettingsGui.Add("DropDownList", "x+20 y40 w125 vKeyPause", pauseOptions)
	
	; 現在の設定値 (State.PauseKey) に基づいて初期選択を行う
	try ddlPause.Text := State.PauseKey
	
	; イベントハンドラを登録
	ddlPause.OnEvent("Change", gSetPause)
	
	SettingsGui.Add("Edit", "x20 y70 w300 h20 ReadOnly -Vscroll", "一時停止状態であるか否かの表示です。")
	chkPauseStat := SettingsGui.Add("Checkbox", "x+20 y70 vPauseStatus", "一時停止")
	State.IsPaused := 0
	State._prevPaused := 0
	
	SettingsGui.Add("Edit", "x20 y100 w300 h40 ReadOnly -Vscroll", "管理者権限で動作しているアプリケーションに対して親指シフト入力するか否かを決定します。")
	if (DllCall("shell32\IsUserAnAdmin")) {
		SettingsGui.Add("Text", "x+20 y100", "紅皿は管理者権限で動作しています。")
	} else {
		SettingsGui.Add("Text", "x+20 y100", "紅皿は通常権限で動作しています。")
		btnAdmin := SettingsGui.Add("Button", "x340 y120 w140 h22", "管理者権限に切替")
		btnAdmin.OnEvent("Click", gButtonAdmin)
	}

	;==================== Tab 5: 紅皿について ====================
	TabCtrl.UseTab(5)
	SettingsGui.SetFont("s10 c000000", "Meiryo UI")
	SettingsGui.Add("Text", "x30 y52", "名称：benizara / 紅皿")
	SettingsGui.Add("Text", "x30 y92", "機能：Yet another NICOLA Emulaton Software")
	SettingsGui.Add("Text", "x30 y114", "　　　キーボード配列エミュレーションソフト")
	SettingsGui.Add("Text", "x30 y142", "バージョン：" . g_Ver . " / " . g_Date)
	SettingsGui.Add("Text", "x30 y182", "作者：Ken'ichiro Ayaki")
	SettingsGui.SetFont("underline")
	txtDL := SettingsGui.Add("Text", "x30 y222 cBlue", "ダウンロードページ")
	txtDL.OnEvent("Click", gURLdownload)
	txtSup := SettingsGui.Add("Text", "x30 y262 cBlue", "サポートページ")
	txtSup.OnEvent("Click", gURLsupport)
	
	SettingsGui.Show("w770 h440")

	s_Romaji := ""
	s_KeySingle := ""
	SetTimer(G2PollingLayout,256)
	SetTimer(G4PollingPause, 256)
	SettingsGui["Edit"].Focus()
}

;-----------------------------------------------------------------------
; 機能：URLを開く
;-----------------------------------------------------------------------
gLayoutURL(ctrl, info) {
	global g_layoutURL
	if (g_layoutURL != "")
		Run(g_layoutURL)
}
	
gURLdownload(ctrl, info) {
	Run("https://github.com/k-ayaki/benizara")
}

gURLsupport(ctrl, info) {
	Run("https://benizara.hatenablog.com/")
}

;-----------------------------------------------------------------------
; 機能：キーレイアウトの表示
;-----------------------------------------------------------------------
G2DrawKeyFrame(a_Romaji) {
	global SettingsGui, GuiLayoutHash, ShiftMode
	
	_ch := GuiLayoutHash.Has(a_Romaji) ? GuiLayoutHash[a_Romaji] : ""
	if (ShiftMode.Has(a_Romaji))
		_ch .= ":" . ShiftMode[a_Romaji]
		
	SettingsGui.Add("GroupBox", "vkeyLayoutName x20 y90 w720 h270", _ch)
	Loop 14 {
		DrawKeyE2B(1, A_Index)
	}
	Loop 12 {
		DrawKeyE2B(2, A_Index)
	}
	Loop 12 {
		DrawKeyE2B(3, A_Index)
	}
	Loop 11 {
		DrawKeyE2B(4, A_Index)
	}
	Loop 4 {
		DrawKeyA(5, A_Index)
	}
	DrawKeyUsage(5)
}

DrawKeyE2B(a_col, a_row) {
	global SettingsGui, g_colhash, g_rowhash
	_xpos0 := 32*(a_col-1) + 48*(a_row - 1) + 44
	_ypos0 := (a_col - 1)*48 + 115
	_col2 := g_colhash.Has(a_col) ? g_colhash[a_col] : ""
	_row2 := g_rowhash.Has(a_row) ? g_rowhash[a_row] : ""
	
	if (_col2 != "" && _row2 != "") {
		SettingsGui.Add("Picture", "x" _xpos0 " y" _ypos0 " w44 h44 0xE vKeyRectangle" _col2 _row2)
		RefreshKey(_col2 . _row2)
	}
}

DrawKeyA(a_col, a_row) {
	global SettingsGui, g_colhash, g_rowhash
	_xpos0 := 32*(a_col-1) + 48*(a_row + 2 - 1) + 44
	_ypos0 := (a_col - 1)*48 + 115
	_col2 := g_colhash.Has(a_col) ? g_colhash[a_col] : ""
	_row2 := g_rowhash.Has(a_row) ? g_rowhash[a_row] : ""
	
	if (_col2 != "" && _row2 != "") {
		SettingsGui.Add("Picture", "x" _xpos0 " y" _ypos0 " w44 h44 0xE vKeyRectangle" _col2 _row2)
		RefreshKey(_col2 . _row2)
	}
}

DrawKeyUsage(a_col) {
	global SettingsGui
	_ypos0 := (a_col - 1)*48 + 115
	_xpos0 := 40
	SettingsGui.Add("Picture", "x" _xpos0 " y" _ypos0 " w44 h44 0xE vKeyRectangleA00")
	RefreshKey("A00")
}

;-----------------------------------------------------------------------
; 機能：キー表示 (GDI+)
;-----------------------------------------------------------------------
Gdip_KeyRect(CtrlName, Foreground, Background:=0x00000000, TextLU:="", TextRU:="", TextLD:="", TextRD:="", pushed:=0)
{
	global SettingsGui
	if (!SettingsGui)
		return 0
		
	local ctrl
	try {
		ctrl := SettingsGui[CtrlName]
	} catch {
		return 0
	}
	
	hwnd := ctrl.Hwnd
	ctrl.GetPos(&x, &y, &Posw, &Posh)
	
	pBrushFront := Gdip_BrushCreateSolid(Foreground)
	pBrushBack := Gdip_BrushCreateSolid(Background)
	pBitmap := Gdip_CreateBitmap(Posw, Posh)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothingMode(G, 4)
	
	Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
	if(pushed == 0)
	{
		Gdip_FillRoundedRectangle(G, pBrushFront, 2, 3, (Posw-5), Posh-5, 3)
		Gdip_TextToGraphics(G, TextLU, "x6p y6p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		Gdip_TextToGraphics(G, TextRU, "x50p y6p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		if(StrLen(TextLD) > 6) {
			Gdip_TextToGraphics(G, TextLD, "x3p y50p s15p left cff000000 r4", "Meiryo UI", Posw, Posh)
		} else {
			Gdip_TextToGraphics(G, TextLD, "x6p y50p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		}
		Gdip_TextToGraphics(G, TextRD, "x50p y50p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
	} else {
		Gdip_FillRoundedRectangle(G, pBrushFront, 3, 2, (Posw-5), Posh-5, 3)
		Gdip_TextToGraphics(G, TextLU, "x8p y4p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		Gdip_TextToGraphics(G, TextRU, "x52p y4p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		if(StrLen(TextLD) > 6) {
			Gdip_TextToGraphics(G, TextLD, "x5p y48p s15p left cff000000 r4", "Meiryo UI", Posw, Posh)
		} else {
			Gdip_TextToGraphics(G, TextLD, "x8p y48p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
		}
		Gdip_TextToGraphics(G, TextRD, "x52p y48p s25p left cff000000 r4", "Meiryo UI", Posw, Posh)
	}
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	; v2では Value に "HBITMAP:" とハンドルを渡して画像をセットします
	try ctrl.Value := "HBITMAP:" . hBitmap
	
	Gdip_DeleteBrush(pBrushFront)
	Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	DeleteObject(hBitmap)
	return 0
}

;-----------------------------------------------------------------------
; イベントハンドラ等
;-----------------------------------------------------------------------
G2PollingLayout() {
	global g_isDialog, g_TabName, s_KeySingle, g_KeySingle, s_Romaji, GuiLayoutHash, ShiftMode, SettingsGui

	; 1. 設定画面がそもそも開いていないなら何もしない
    if (g_isDialog == 0 || !SettingsGui) {
    	SetTimer(G2PollingLayout, 0)
		return
	}
	; 2. 【ここが重要】「配列」タブ以外のときは更新処理をスキップする
	if(g_TabName != "配列")
		return
	
	if(s_KeySingle != g_KeySingle || s_Romaji != State.Romaji)
	{
		if(s_Romaji != State.Romaji) 
		{
			s_Romaji := State.Romaji
			_ch := GuiLayoutHash.Has(State.Romaji) ? GuiLayoutHash[State.Romaji] : ""
			if (ShiftMode.Has(State.Romaji))
				_ch .= ":" . ShiftMode[State.Romaji]
			
			; ▼ SettingsGui.Has(...) の代わりに try を使って安全にテキストを更新します
			try SettingsGui["keyLayoutName"].Text := _ch
			
			G2RefreshLayout()
			s_ddlist := "|" . RefreshSimulKeyMenu()
  	         	
			; ▼ こちらも try を使って安全にドロップダウンリストを更新します
			try {
				SettingsGui["CurrSimulMode"].Delete()
				SettingsGui["CurrSimulMode"].Add(StrSplit(s_ddlist, "|"))
			}
		}
		s_KeySingle := g_KeySingle
		RefreshLayoutA()
	}
	; ReadKeyboardState()
}

RefreshSimulKeyMenu() {
	global g_CurrSimulMode, g_SimulMode
	s_ddlist := "…"
	if (s_ddlist == g_CurrSimulMode) {
		s_ddlist .= "||"
	} else {
		s_ddlist .= "|"
	}
	for k, v in g_SimulMode {
		if (SubStr(v, 1, 1) == State.Romaji) {
			if (v == g_CurrSimulMode) {
				s_ddlist .= v . "||"
			} else {
				s_ddlist .= v . "|"
			}
		}
	}
	return s_ddlist
}

RefreshLayoutA() {
	RefreshKey("A01"), RefreshKey("A02"), RefreshKey("A03"), RefreshKey("A04"), RefreshKey("A00")
}

G2RefreshLayout() {
	global layoutArys
	for index, element in layoutArys {
		RefreshKey(element)
	}
}

RefreshKey(_pos, _keystatus:=0) {
	global g_keyState, g_isDialog, ShiftMode, g_CurrSimulMode, keyAttribute3, kLabel, g_pos2Colors, g_sansPos
	
	g_keyState[_pos] := _keystatus 
	if(g_isDialog == 0)
		return 0
	
	if (_pos == "A00") {
		if(ShiftMode.Has("R") && (ShiftMode["R"] == "親指シフト" || ShiftMode["R"] == "文字同時打鍵")) {
			if(g_CurrSimulMode == "…") {
				Gdip_KeyRect("KeyRectangle" . _pos, 0xffFFFFFF, 0xff000000, "左", "右", "小", "無")
			} else {
				Gdip_KeyRect("KeyRectangle" . _pos, 0xffFFFFFF, 0xff000000, "左", "右", SubStr(g_CurrSimulMode, 4), "無")
			}
		} else if(ShiftMode.Has("R") && ShiftMode["R"] == "プレフィックスシフト") {
			Gdip_KeyRect("KeyRectangle" . _pos, 0xffFFFFFF, 0xff000000, "１", "２", "小", "無")
		}
	} else if (SubStr(_pos, 1, 1) == "A") {
		attr := keyAttribute3.Has(State.Romaji . "N" . _pos) ? keyAttribute3[State.Romaji . "N" . _pos] : ""
		lbl := kLabel.Has(_pos) ? kLabel[_pos] : ""
		
		if(attr == "L") {
			Gdip_KeyRect("KeyRectangle" . _pos, 0xffFFFF00, 0xff000000, "左親指", "", lbl, "", 0)
		} else if(attr == "R") {
			Gdip_KeyRect("KeyRectangle" . _pos, 0xff00FFFF, 0xff000000, "右親指", "", lbl, "", 0)
		} else {
			Gdip_KeyRect("KeyRectangle" . _pos, 0xffFFFFFF, 0xff000000, "", "", lbl, "", 0)
		}
	} else {
		_chrk := ""
		if(g_sansPos != "") {
			_chrk := kLabel.Has(State.Romaji . "NS" . _pos) ? kLabel[State.Romaji . "NS" . _pos] : ""
		} else if(g_CurrSimulMode == "…") {
			_chrk := kLabel.Has(State.Romaji . "NK" . _pos) ? kLabel[State.Romaji . "NK" . _pos] : ""
		} else {
			_chrk := kLabel.Has(g_CurrSimulMode . _pos) ? kLabel[g_CurrSimulMode . _pos] : ""
		}
		
		_chrn := kLabel.Has(State.Romaji . "NN" . _pos) ? kLabel[State.Romaji . "NN" . _pos] : ""
		_chrl := kLabel.Has(State.Romaji . "LN" . _pos) ? kLabel[State.Romaji . "LN" . _pos] : ""
		if(_chrl == "") {
			_chrl := kLabel.Has(State.Romaji . "1N" . _pos) ? kLabel[State.Romaji . "1N" . _pos] : ""
		}
		_chrr := kLabel.Has(State.Romaji . "RN" . _pos) ? kLabel[State.Romaji . "RN" . _pos] : ""
		if(_chrr == "") {
			_chrr := kLabel.Has(State.Romaji . "2N" . _pos) ? kLabel[State.Romaji . "2N" . _pos] : ""
		}
		
		col := g_pos2Colors.Has(_pos) ? g_pos2Colors[_pos] : "FFFFFF"
		Gdip_KeyRect("KeyRectangle" . _pos, "0xff" . col, 0xff000000, _chrl, _chrr, _chrk, _chrn, _keystatus)
	}
	return 0
}

G4PollingPause() {
	global g_isDialog, SettingsGui
	if(g_isDialog == 0) {
		SetTimer(G4PollingPause, 0)
		return
	}
	if (State.IsPaused != State._prevPaused) {
		State._prevPaused := State.IsPaused
		try SettingsGui["PauseStatus"].Value := State.IsPaused
		trayIconRefresh(State.IsPaused)
	}
}

ReadKeyboardState() {
	global layoutArys, keyHook, vkeyStrHash, g_keyState
	for index, element in layoutArys {
		if(element == "A04")
			continue
		if(keyHook.Has(element) && keyHook[element] == "Off") {
			s_vkey := vkeyStrHash.Has(element) ? vkeyStrHash[element] : ""
			if (s_vkey != "") {
				s_keyState := GetKeyState(s_vkey, "P")
				if(s_keyState != g_keyState[element]) {
					RefreshKey(element, s_keyState)
				}
			}
		}
	}
}

gTabChange(ctrl, info) {
	global g_TabName, SettingsGui
	g_TabName := ctrl.Text
	SettingsGui["Edit"].Focus()
	if(g_TabName == "配列") {
		SetTimer(G2PollingLayout, 64)
	} else {
		SetTimer(G2PollingLayout, 0)
	}
}

gThSlider(ctrl, info) {
	global g_Threshold, SettingsGui
	g_Threshold := ctrl.Value
	SettingsGui["ThresholdNum"].Value := g_Threshold
}

gThSliderSS(ctrl, info) {
	global g_ThresholdSS, SettingsGui
	g_ThresholdSS := ctrl.Value
	SettingsGui["ThresholdNumSS"].Value := g_ThresholdSS
}

gOlSliderMO(ctrl, info) {
	global g_OverlapMO, SettingsGui
	g_OverlapMO := ctrl.Value
	SettingsGui["OverlapNumMO"].Value := g_OverlapMO
}

gOlSliderOM(ctrl, info) {
	global g_OverlapOM, SettingsGui
	g_OverlapOM := ctrl.Value
	SettingsGui["OverlapNumOM"].Value := g_OverlapOM
}

gOlSliderOMO(ctrl, info) {
	global g_OverlapOMO, SettingsGui
	g_OverlapOMO := ctrl.Value
	SettingsGui["OverlapNumOMO"].Value := g_OverlapOMO
}

gOlSliderSS(ctrl, info) {
	global g_OverlapSS, SettingsGui
	g_OverlapSS := ctrl.Value
	SettingsGui["OverlapNumSS"].Value := g_OverlapSS
}

gContinue(ctrl, info) {
	global g_Continue, g_Threshold, g_OverlapOM, g_OverlapMO, g_OverlapOMO, SettingsGui
	g_Continue := ctrl.Value
	if(g_Continue == 1) {
		g_Threshold := 100, g_OverlapOM := 35, g_OverlapMO := 70, g_OverlapOMO := 70
	} else {
		g_Threshold := 150, g_OverlapOM := 35, g_OverlapMO := 70, g_OverlapOMO := 70
	}
	SettingsGui["ThSlider"].Value := g_Threshold
	SettingsGui["ThresholdNum"].Value := g_Threshold
	SettingsGui["OverlapNumOM"].Value := g_OverlapOM
	SettingsGui["OlSliderOM"].Value := g_OverlapOM
	SettingsGui["OverlapNumMO"].Value := g_OverlapMO
	SettingsGui["OlSliderMO"].Value := g_OverlapMO
	SettingsGui["OverlapNumOMO"].Value := g_OverlapOMO
	SettingsGui["OlSliderOMO"].Value := g_OverlapOMO
}

gZeroDelay(ctrl, info) {
	global g_ZeroDelay
	g_ZeroDelay := ctrl.Value
}

gZeroDelaySS_Click(ctrl, info) {
	global g_ZeroDelay
	g_ZeroDelay := ctrl.Value
}

gOya(ctrl, info) {
	global g_OyaKey
	if(ctrl.Text != "…") {
		g_OyaKey := ctrl.Text
		RemapOya()
		; RefreshLayoutA()
	}
}

gKeySingle(ctrl, info) {
	global g_KeySingle, g_KeyRepeat
	if(ctrl.Text != "…") {
		g_KeySingle := ctrl.Text
		if(g_KeySingle == "有効") {
			g_KeyRepeat := 1
		} else {
			g_KeyRepeat := 0
		}
		RemapOya()
		; RefreshLayoutA()
	}
}

gCurrSimulMode_Change(ctrl, info) {
	global g_CurrSimulMode, SettingsGui
	g_CurrSimulMode := ctrl.Text
	SettingsGui.Destroy()
	BuildSettingsGui()
}

gFileSelect(ctrl, info) {
	global g_DataDir, vLayoutFile, g_LayoutFile, g_Ver, g_layoutName, g_layoutVersion, _currentTick, g_MojiTick, g_OyaTick, vIntKeyUp, vIntKeyDn, SettingsGui, g_CurrSimulMode
	SetTimer(G2PollingLayout, 0)
	SetWorkingDir(g_DataDir)
	
	vLayoutFileAbs := FileSelect("S", g_DataDir, "", "Layout File (*.bnz; *.yab)")
	
	if (vLayoutFileAbs != "") {
		vLayoutFile := Path_RelativePathTo(A_WorkingDir, 0x10, vLayoutFileAbs, 0x20)
		if (vLayoutFile == "")
			vLayoutFile := vLayoutFileAbs
			
		SettingsGui["FilePath"].Value := vLayoutFile

		SetTimer(Interrupt16, 0)
		SetHotkey("Off")
		SetHotkeyFunction("Off")
		
		InitLayout2()
		ReadLayoutFile(vLayoutFile)
		
		global g_error
		if(g_error == "") {
			TrayTip("benizara " . g_Ver . "`n" . g_layoutName . "　" . g_layoutVersion, "キーボード配列エミュレーションソフト「紅皿」")
		} else {
			MsgBox(g_error)
			; 元ファイルを再読み込みする
			InitLayout2()
			vLayoutFile := g_LayoutFile
			ReadLayoutFile(g_LayoutFile)
			SettingsGui["FilePath"].Value := vLayoutFile
		}
		SetLayoutProperty()
		g_LayoutFile := vLayoutFile
		
		_currentTick := Pf_Count()
		g_MojiTick := Map()
		g_MojiTick[0] := _currentTick
		g_OyaTick["R"] := _currentTick
		g_OyaTick["L"] := _currentTick
		
		SetTimer(Interrupt16, 16) ; on -> 16ms
		vIntKeyUp := 0
		vIntKeyDn := 0
	}
	SettingsGui.Destroy()
	g_CurrSimulMode := "…"
	BuildSettingsGui()
}

gSetPause(ctrl, info) {
	if(ctrl.Text == "Pause" || ctrl.Text == "ScrollLock" || ctrl.Text == "無効") {
		State.PauseKey := ctrl.Text
	}
}

gPauseStatus(a_Pause) {
	if (a_Pause == 0)
		return 1
	return 0
}

gButtonAdmin(ctrl, info) {
	try { 
		if(A_IsCompiled) {
			Run('*RunAs "' A_ScriptFullPath '" /restart')
		} else {
			SetWorkingDir(A_ScriptDir)
			Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
		}
	} 
	ExitApp()
}

gButtonOk(ctrl, info) {
	global g_DataDir, g_LayoutFile, g_Continue, g_Threshold, g_ThresholdSS, g_ZeroDelay
	global g_OverlapMO, g_OverlapOM, g_OverlapOMO, g_OverlapSS, g_OyaKey, g_KeySingle
	
	SetWorkingDir(g_DataDir)
	g_IniFile := g_DataDir . "\benizara.ini"
	IniWrite(g_LayoutFile, g_IniFile, "FilePath", "LayoutFile")
	IniWrite(g_Continue, g_IniFile, "Key", "Continue")
	IniWrite(g_Threshold, g_IniFile, "Key", "Threshold")
	IniWrite(g_ThresholdSS, g_IniFile, "Key", "ThresholdSS")
	IniWrite(g_ZeroDelay, g_IniFile, "Key", "ZeroDelay")
	IniWrite(g_OverlapMO, g_IniFile, "Key", "OverlapMO")
	IniWrite(g_OverlapOM, g_IniFile, "Key", "OverlapOM")
	IniWrite(g_OverlapOMO, g_IniFile, "Key", "OverlapOMO")
	IniWrite(g_OverlapSS, g_IniFile, "Key", "OverlapSS")
	IniWrite(g_OyaKey, g_IniFile, "Key", "OyaKey")
	IniWrite(g_KeySingle, g_IniFile, "Key", "KeySingle")
	IniWrite(State.PauseKey, g_IniFile, "Key", "KeyPause")
	
	SetTimer(G2PollingLayout, 0)
	SettingsGui.Destroy()
}

gButtonCancel(ctrl, info) {
	GuiClose()
}

GuiClose(GuiObj:="", info:="") {
	global g_isDialog, SettingsGui
	SetTimer(G2PollingLayout, 0)
	SetTimer(G4PollingPause, 0)
	if (SettingsGui) {
		SettingsGui.Destroy()
		SettingsGui := ""
	}
	g_isDialog := 0
}
;-----------------------------------------------------------------------
; 機能：親指シフトモードの変数設定
;-----------------------------------------------------------------------
RemapOya() {
    global ShiftMode
    
    if (ShiftMode.Has("A") && ShiftMode["A"] == "親指シフト") {
        RemapOyaKey("A")
    }
    if (ShiftMode.Has("R") && ShiftMode["R"] == "親指シフト") {
        RemapOyaKey("R")
    }
}
