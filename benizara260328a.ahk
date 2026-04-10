;-----------------------------------------------------------------------
;	名称：benizara / 紅皿 (AHK v2版)
;	機能：Yet another NICOLA Emulation Software
;         キーボード配列エミュレーションソフト
;	ver.0.2.0.0 .... 2026/3/28 (v2 modified)
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
#SingleInstance Off
#UseHook true
; 外部ファイルの読み込み
#Include IMEv2.ahk 
#Include ReadLayout6.ahk
#Include Settings7.ahk
#Include PfCount.ahk
#Include Logs1.ahk
#Include Path.ahk
#Include Objects.ahk
#Include KeyQueue.ahk
#Include SendOnHold.ahk
#Include keyHook.ahk
A_MaxHotkeysPerInterval := 400
InstallKeybdHook()
KeyHistory(100)
SetStoreCapsLockMode(false)

ProcessSetPriority("High")

global g_Ver := "ver.0.2.0.0"
global g_Date := "2026/3/28"
global MutexName := "benizara"
global hMutex := 0

; 多重起動防止・・・異なるバージョンであっても同時起動を禁止
if (DllCall("OpenMutexW", "Int", 0x100000, "Int", 0, "Str", MutexName)) {
    TrayTip("多重起動は禁止されています。", "キーボード配列エミュレーションソフト「紅皿」")
    ExitApp()
}
hMutex := DllCall("CreateMutexW", "Int", 0, "Int", False, "Str", MutexName)

SetWorkingDir(A_ScriptDir)

global idxLogs := 0
global g_Log := Map()
global aLogCnt := 0
Loop 64 {
    g_Log[A_Index-1] := ""
}

; コマンドライン引数の処理
Loop A_Args.Length {
    arg := A_Args[A_Index]
    if (arg == "/create") {
        thisCmd := 'schtasks.exe /create /tn benizara /tr "' A_ScriptFullPath '" /sc onlogon /rl highest /F'
        DllCall("ReleaseMutex", "Ptr", hMutex)
        DllCall("CloseHandle", "Ptr", hMutex)        
        Run('*RunAs ' thisCmd)
        ExitApp()
    }
    if (arg == "/delete") {
        thisCmd := 'schtasks.exe /delete /tn \benizara /F'
        DllCall("ReleaseMutex", "Ptr", hMutex)
        DllCall("CloseHandle", "Ptr", hMutex)
        Run('*RunAs ' thisCmd)
        ExitApp()
    }
    if (arg == "/admin") {
        DllCall("ReleaseMutex", "Ptr", hMutex)
        DllCall("CloseHandle", "Ptr", hMutex)
        Run('*RunAs "' A_ScriptFullPath '"')
        ExitApp()
    }
}

global g_DataDir := A_AppData . "\ayaki\benizara"
if (!FileExist(g_DataDir . "\benizara.ini")) {
    g_DataDir := A_ScriptDir
}
; グローバル変数として1つだけインスタンス化する
global State := BenizaraState()

global g_LayoutFile := ".\NICOLA配列.bnz"
global g_Continue := 1
global g_Threshold := 100

_keyboardDelayIdx := RegRead("HKEY_CURRENT_USER\Control Panel\Keyboard", "KeyboardDelay", 0)
global g_MaxTimeout := ( 0 == _keyboardDelayIdx) ? 250
              : ( 1 == _keyboardDelayIdx) ? 500
              : ( 2 == _keyboardDelayIdx) ? 750
              : ( 3 == _keyboardDelayIdx) ? 1000
              : 1000
if(g_MaxTimeout == 0) {
    g_MaxTimeout := 500
}

global g_MaxTimeoutM := 0
global g_ThresholdSS := 250
global g_OverlapMO := 35
global g_OverlapOM := 70
global g_OverlapOMO := 50
global g_OverlapSS := 35
global g_ZeroDelay := 1
global g_ZeroDelayOut := ""
global g_ZeroDelaySurface := ""
global g_Offset := 20
global g_vOut := ""

global INFINITE := 2147483648
global vOverlap := ""
global g_OyaTick   := Map()
global g_OyaUpTick := Map()
global g_Interval  := Map()
global g_LastKey   := Map()
g_LastKey["表層"] := ""

global g_metaKeyUp := Map()
g_metaKeyUp["R"] := "r", g_metaKeyUp["L"] := "l", g_metaKeyUp["M"] := "m"
g_metaKeyUp["S"] := "s", g_metaKeyUp["X"] := "x"
g_metaKeyUp["0"] := "_0", g_metaKeyUp["1"] := "_1", g_metaKeyUp["2"] := "_2"
g_metaKeyUp["3"] := "_3", g_metaKeyUp["4"] := "_4", g_metaKeyUp["5"] := "_5"
g_metaKeyUp["6"] := "_6", g_metaKeyUp["7"] := "_7", g_metaKeyUp["8"] := "_8"
g_metaKeyUp["9"] := "_9", g_metaKeyUp["A"] := "a", g_metaKeyUp["B"] := "b"
g_metaKeyUp["C"] := "c", g_metaKeyUp["D"] := "d"

global keyTick := Map()
global g_KeyOnHold := ""
global g_sansPos := ""
global g_debugout := ""
global vLayoutFile := g_LayoutFile
global g_Tau := 400

global g_intproc := 0
global g_RepeatCount := 0
global g_layoutPos := ""
global g_metaKey := ""
global kName := ""
global kup_save := Map()

; システム初期化
InitKeyQueue()
InitSettings()
ReadLayout()
TrayTip("benizara " g_Ver "`n" g_layoutName "　" g_layoutVersion, "キーボード配列エミュレーションソフト「紅皿」")
StartGdi()

A_TrayMenu.Delete()
A_TrayMenu.Add("紅皿設定", MenuSettings)
A_TrayMenu.Add("ログ", MenuLogs)
A_TrayMenu.Add("終了", MenuExit)

SetHotkeyInit()
Pf_Init()
_TickCount := Pf_Count()
g_OyaTick["R"] := _TickCount, g_OyaTick["L"] := _TickCount
g_OyaTick["A"] := _TickCount, g_OyaTick["B"] := _TickCount
g_OyaTick["C"] := _TickCount, g_OyaTick["D"] := _TickCount

if ProcessExist("yamabuki_r.exe") {
    TrayTip("やまぶきRが動作中。干渉のおそれがあります。", "キーボード配列エミュレーションソフト「紅皿」")
    ExitApp()
}
if ProcessExist("yamabuki.exe") {
    TrayTip("やまぶきが動作中。干渉のおそれがあります。", "キーボード配列エミュレーションソフト「紅皿」")
    ExitApp()
}
if ProcessExist("DvorakJ.exe") {
    TrayTip("DvorakJが動作中。干渉のおそれがあります。", "キーボード配列エミュレーションソフト「紅皿」")
    ExitApp()
}
if ProcessExist("em1keypc.exe") {
    TrayTip("em1keypcが動作中。干渉のおそれがあります。", "キーボード配列エミュレーションソフト「紅皿」")
    ExitApp()
}
if ProcessExist("姫踊子草2.exe") {
    TrayTip("姫踊子草2が動作中。干渉のおそれがあります。", "キーボード配列エミュレーションソフト「紅皿」")
    ExitApp()
}

SetTimer(Interrupt16, 16)
Suspend(false)
trayIconRefresh(State.IsPaused)

;-----------------------------------------------------------------------
; グローバル変数のクラス化
;-----------------------------------------------------------------------
class BenizaraState {
    ; --- 1. 基本的な打鍵状態プロパティ ---
    Romaji := "A"
    Oya := "N"
    Koyubi := "N"
    Sans := "N"

    ; --- 2. 修飾キー (Modifier) のプロパティ管理 ---
    _modifier := 0
    Modifier {
        get => this._modifier
        set {
            if !IsNumber(value)
                throw TypeError("Modifierには数値を指定してください。")
            this._modifier := value
        }
    }

    ; --- 動作状態 ---
    IsPaused := 0
    _prevPaused := 0
    PauseKey := "Pause"
    
    ; --- タイミング制御 ---
    SansTick := 2147483648
    ModifierTick := 0
    SendTick := 2147483648
    
    ; ここから追加: --- 3. 一時的な打鍵状態（キュー・タイミング管理） --- 
    KeyInPtn := ""      
    Timeout := ""       
    Trigger := ""       
    PrefixShift := ""   

    ; --- コンストラクタ ---
    __New() {
        this.ResetBaseState()
    }

    ; --- 便利なヘルパーメソッド ---
    ResetBaseState() {
        this.Romaji := "A"
        this.Oya := "N"
        this.Koyubi := "N"
        this.Sans := "N"
        this.Modifier := 0
        ; 一時変数も初期化
        this.KeyInPtn := ""
        this.Timeout := ""
        this.Trigger := ""
        this.PrefixShift := ""
    }

    AddModifier(flag) {
        this.Modifier |= flag
    }

    RemoveModifier(flag) {
        this.Modifier &= ~flag
    }

    MaskModifiers() {
        this.Modifier &= 0x7E00
    }
    
    TogglePause() {
        this.IsPaused := !this.IsPaused
        this._prevPaused := this.IsPaused
    }
}
;-----------------------------------------------------------------------
; メニューコールバック
;-----------------------------------------------------------------------
MenuSettings(ItemName, ItemPos, MyMenu) {
    ShowSettings()
}

MenuLogs(ItemName, ItemPos, MyMenu) {
    ShowLogs()
}

MenuExit(ItemName, ItemPos, MyMenu) {
    CloseGdi()
    SetTimer(Interrupt16, 0)
    DllCall("ReleaseMutex", "Ptr", hMutex)
    SetHotkey("Off")
    SetHotkeyFunction("Off")
    SetHotkeyNumpad("Off")
    ExitApp()
}

;-----------------------------------------------------------------------
; 共通イベントハンドラ: キーダウン
;-----------------------------------------------------------------------
GlobalKeyDownCallback(ThisHotkey) {
    global
    Critical("On")
    ScanModifier()
    
    g_layoutPos := layoutPosHash.Has(ThisHotkey) ? layoutPosHash[ThisHotkey] : ""
    State.KeyInPtn := getKeyinPtnFromQueue()
    kName := keyNameHash.Has(g_layoutPos) ? keyNameHash[g_layoutPos] : ""
    
    if(kName == "LShift" || kName == "RShift") {
        State.Koyubi := "K"
    }	
    attrKey := State.Romaji . KoyubiOrSans(State.Koyubi, State.Sans) . g_layoutPos
    g_metaKey := keyAttribute3.Has(attrKey) ? keyAttribute3[attrKey] : ""
    
    if(kName == "LShift" || kName == "RShift") {
        ProcessKeyDown(g_metaKey)
        return
    }	
    
    if(kName == "LCtrl") {
    	State.AddModifier(0x0200)
    	ProcessKeyDown(g_metaKey) 
    	return
   	}
    if(kName == "RCtrl") {
    	State.AddModifier(0x0400)
    	ProcessKeyDown(g_metaKey)
    	return
    }
    if(kName == "LAlt")  { 
    	State.AddModifier(0x0800)
    	ProcessKeyDown(g_metaKey)
    	return
    }
    if(kName == "RAlt")  { 
    	State.AddModifier(0x1000)
    	ProcessKeyDown(g_metaKey)
    	return
    }
    if(kName == "LWin")  {
    	State.AddModifier(0x2000)
    	ProcessKeyDown(g_metaKey)
    	return
    }
    if(kName == "RWin")  {
    	State.AddModifier(0x4000)
    	ProcessKeyDown(g_metaKey)
    	return
    }
    
    if(State.Modifier != 0) {
        RegLogs(kName . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")
        State.Timeout := ""
        ModeInitialize()
        
        if(g_metaKey == "M" && kdn.Has("ANN") && kdn["ANN"] != "") {
            SubSendOne(kdn.Has("ANN" . g_layoutPos) ? kdn["ANN" . g_layoutPos] : "")
            SetKeyupSave(kup.Has("ANN" . g_layoutPos) ? kup["ANN" . g_layoutPos] : "", g_layoutPos)
        } else {
            SubSendOne(MnDown(kName))
            SetKeyupSave(MnUp(kName), g_layoutPos)
        }
        State.KeyInPtn := clearQueue()
        g_LastKey["表層"] := ""
        State.Timeout := 60000
        State.SendTick := INFINITE
        State.PrefixShift := ""
        Critical("Off")
        return
    }
    ProcessKeyDown(g_metaKey)
}

;-----------------------------------------------------------------------
; 共通イベントハンドラ: キーアップ
;-----------------------------------------------------------------------
GlobalKeyUpCallback(ThisHotkey) {
    global
    Critical("On")
    ScanModifier()
    
    g_layoutPos := layoutPosHash.Has(ThisHotkey) ? layoutPosHash[ThisHotkey] : ""
    State.KeyInPtn := getKeyinPtnFromQueue()
    kName := keyNameHash.Has(g_layoutPos) ? keyNameHash[g_layoutPos] : ""
    
    if(kName == "LShift" || kName == "RShift") {
        State.Koyubi := "N"
    }
    
    attrKey := State.Romaji . KoyubiOrSans(State.Koyubi, State.Sans) . g_layoutPos
    g_metaKey := keyAttribute3.Has(attrKey) ? keyAttribute3[attrKey] : ""
    
    if(kName == "LCtrl") {
		State.RemoveModifier(0x0200)    
    }
    if(kName == "RCtrl") {
		State.RemoveModifier(0x0400)    
    }
    if(kName == "LAlt")  {
		State.RemoveModifier(0x0800)    
    }
    if(kName == "RAlt")  {
		State.RemoveModifier(0x1000)    
    }
    if(kName == "LWin")  {
		State.RemoveModifier(0x2000)    
    }
    if(kName == "RWin")  {
		State.RemoveModifier(0x4000)    
    }
    ProcessKeyUp(g_metaKey)
}

;=======================================================================
; キー種別ごとのダウン処理 (元の keydownM: などの代替)
;=======================================================================
ProcessKeyDown(meta) {
    global
    
    Switch meta {
        Case "R", "L", "A", "B", "C", "D":
            State.Trigger := g_metaKey
            pf_TickCount := Pf_Count()
            g_OyaTick[g_metaKey] := pf_TickCount
            RegLogs(g_metaKey . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
            if(keyState.Has(g_layoutPos) && keyState[g_layoutPos] != 0) {
                if(g_KeyRepeat == 0 && g_layoutPos != "A02") {
                    Critical("Off")
                    return
                }
            }
            State.Oya := g_metaKey
            keyState[g_layoutPos] |= 2
            keyTick[g_layoutPos] := pf_TickCount

            if(State.KeyInPtn == "MM" || State.KeyInPtn == "MMm") {
                _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                chkKey := _mode . SafeMojiOnHold(2) . SafeMojiOnHold(1)
                if(!kdn.Has(chkKey) || kdn[chkKey] == "") {
                    State.KeyInPtn := SendOnHoldM()
                    SubSendUp(SafeMojiOnHold(1))
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                } else {
                    g_Interval["M" . g_metaKey] := pf_TickCount - SafeTDownOnHold(2)
                    g_Interval["S12"]  := SafeTDownOnHold(2) - SafeTDownOnHold(1)
                    if(g_Interval["S12"] < g_Interval["M" . g_metaKey]) {
                        State.KeyInPtn := SendOnHoldMM()
                        if(State.KeyInPtn == "M") {
                            SubSendUp(SafeMojiOnHold(1))
                            State.Timeout := SetTimeout(State.KeyInPtn)
                            State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                        }
                    } else {
                        State.KeyInPtn := SendOnHoldM()
                        SubSendUp(SafeMojiOnHold(1))
                        State.Timeout := SetTimeout(State.KeyInPtn)
                        State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    }
                }
            } else if(State.KeyInPtn == "MMM") {
                State.KeyInPtn := SendOnHoldMMM()
            }
            
            if(State.KeyInPtn == "") {
                State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                State.Timeout := SetTimeout(State.KeyInPtn)
                State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
            } else if(State.KeyInPtn == "M") {
                g_Interval["M" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                if(g_Interval["M" . g_metaKey] > Min(Floor((g_Threshold*(100-g_OverlapMO))/g_OverlapMO), g_MaxTimeout)) {
                    State.KeyInPtn := SendOnHoldM()
                    State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                } else {
                    State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    g_Interval["M" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx-1)
                    State.Timeout := Min(Floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)), g_MaxTimeout)
                    State.SendTick := pf_TickCount + Min(Floor(g_Interval["M" . g_metaKey]*g_OverlapMO/(100-g_OverlapMO)), g_MaxTimeout)
                }
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]$")) {
                State.KeyInPtn := SendOnHoldO()
                State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                State.Timeout := SetTimeout(State.KeyInPtn)
                State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
            } else if(RegExMatch(State.KeyInPtn, "^M[RLABCD]$")) {
                State.KeyInPtn := SendOnHoldMO()
                State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                State.Timeout := SetTimeout(State.KeyInPtn)
                State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M$")) {
                State.KeyInPtn := SendOnHoldOM()
                /*
                State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                State.Timeout := SafeTUpOnHold(g_OnHoldIdx) - SafeTDownOnHold(g_OnHoldIdx-1)
                State.SendTick := calcSendTick(keyTick[g_layoutPos], State.Timeout)
                */
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[rlabcd]$")) {
                State.KeyInPtn := SendOnHoldOM()
            }
            Critical("Off")
            return

        Case "M":
            State.Trigger := g_metaKey
            RegLogs(kName . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")

            pf_TickCount := Pf_Count()	
            if(keyState.Has(g_layoutPos) && keyState[g_layoutPos] != 0) {
                if(State.KeyInPtn == "MM" || State.KeyInPtn == "MMm") {
                    Critical("Off")
                    return
                }
                _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                if(ksc.Has(_mode . g_layoutPos) && ksc[_mode . g_layoutPos] > 1) {
                    if (keyState[g_layoutPos] == 2) {
                        if(pf_TickCount - keyTick[g_layoutPos] < g_MaxTimeoutM) {
                            Critical("Off")
                            return
                        }
                        keyState[g_layoutPos] |= 4
                    }
                    g_KeyOnHold := GetPushedKeys()
                    if(StrLen(g_KeyOnHold) >= 6) {
                        Critical("Off")
                        return
                    }
                }
            }
            keyTick[g_layoutPos] := pf_TickCount
            State.Timeout := ""
            
            keyState[g_layoutPos] |= 2
            State.SansTick := INFINITE
            if(keyState.Has(g_sansPos) && keyState[g_sansPos] == 2) {
                keyState[g_sansPos] := 1
            }
            
            if(ShiftMode[State.Romaji] == "プレフィックスシフト") {
                if(State.PrefixShift != "" ) {
                    SendKey(State.Romaji . State.PrefixShift . KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos)
                    State.Timeout := 60000
                    State.SendTick := INFINITE
                    State.PrefixShift := ""
                    Critical("Off")
                    return
                }
                SendKey(State.Romaji . "N" . KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos)
                State.Timeout := 60000
                State.SendTick := INFINITE
                Critical("Off")
                return
            }
            if(ShiftMode[State.Romaji] == "小指シフト") {
                SendKey(State.Romaji . "N" . KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos)
                clearQueue()
                Critical("Off")
                return
            }
            
            if(State.KeyInPtn == "M") {
                if(SafeMetaOnHold(1) == "M") {
                    _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                    chkA := _mode . g_layoutPos
                    chkB := _mode . SafeMojiOnHold(1) . g_layoutPos
                    if(!ksc.Has(chkA) || ksc[chkA] <= 1 
                    || (ksc[chkA] == 2 && (!kdn.Has(chkB) || kdn[chkB] == ""))
                    || (!ksc.Has(chkB) || ksc[chkB] == 0)) {
                        State.KeyInPtn := SendOnHoldM()
                    }
                }
            } else if(RegExMatch(State.KeyInPtn, "^M[RLABCD]$")) {
                if(g_Continue == 0) {
                    wOya := SafeOyaOnHold(g_OnHoldIdx)
                    g_Interval["M" . wOya] := SafeTDownOnHold(g_OnHoldIdx) - SafeTDownOnHold(g_OnHoldIdx-1)
                    g_Interval[wOya . "M"] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                    if(g_Interval["M" . wOya] < g_Interval[wOya . "M"]) {
                        State.KeyInPtn := SendOnHoldMO()
                    } else {
                        State.KeyInPtn := SendOnHoldM()
                    }
                } else {
                    State.KeyInPtn := SendOnHoldMO()
                }
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M$")) {
                State.KeyInPtn := SendOnHoldOM()
                /*
                _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                chkA := _mode . g_layoutPos
                chkB := _mode . SafeMojiOnHold(g_OnHoldIdx) . g_layoutPos
                if(!ksc.Has(chkA) || ksc[chkA] <= 1 
                || (ksc[chkA] == 2 && (!kdn.Has(chkB) || kdn[chkB] == ""))
                || (!ksc.Has(chkB) || ksc[chkB] == 0)) {
                    State.KeyInPtn := SendOnHoldOM()
                } else if(g_OnHoldIdx == 1) {
                    State.KeyInPtn := SendOnHoldOM()
                } else {
                    wOya := SafeOyaOnHold(1)
                    g_Interval[wOya . "M"] := SafeTDownOnHold(2) - SafeTDownOnHold(1)
                    g_Interval["S12"] := pf_TickCount - SafeTDownOnHold(2)
                    if(g_Interval[wOya . "M"] < g_Interval["S12"]) {
                        State.KeyInPtn := SendOnHoldOM()
                    } else {
                        State.KeyInPtn := SendOnHoldO()
                    }
                }*/
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD]$")) {
                State.KeyInPtn := SendOnHoldOM()
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[rlabcd]$")) {
                State.KeyInPtn := SendOnHoldOM()
                ; cleanup
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD][rlabcd]$")) {
                State.KeyInPtn := SendOnHoldOM()
                ; cleanup
            } else if(State.KeyInPtn == "MM") {	
                _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                chkA := _mode . g_layoutPos
                chkC := _mode . SafeMojiOnHold(2) . SafeMojiOnHold(1)
                chkB := chkC . g_layoutPos
                if(!ksc.Has(chkA) || ksc[chkA] <= 2 || (ksc[chkA] == 3 && (!kdn.Has(chkB) || kdn[chkB] == ""))) {
                    g_Interval["S12"] := SafeTDownOnHold(2) - SafeTDownOnHold(1)
                    g_Interval["S23"] := pf_TickCount - SafeTDownOnHold(2)
                    if(kdn.Has(chkC) && kdn[chkC] != "" && g_Interval["S12"] < g_Interval["S23"]) {
                        State.KeyInPtn := SendOnHoldMM()
                        SubSendUp(SafeMojiOnHold(1))
                    } else {
                        State.KeyInPtn := SendOnHoldM()
                        SubSendUp(SafeMojiOnHold(1))
                    }
                }
            } else if(State.KeyInPtn == "MMm") {
                g_Interval["S12"] := SafeTDownOnHold(2) - SafeTDownOnHold(1)
                g_Interval["S23"] := pf_TickCount - SafeTDownOnHold(2)
                _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                chkC := _mode . SafeMojiOnHold(2) . SafeMojiOnHold(1)
                if(kdn.Has(chkC) && kdn[chkC] != "" && g_Interval["S12"] < g_Interval["S23"]) {
                    State.KeyInPtn := SendOnHoldMM()
                    SubSendUp(SafeMojiOnHold(1))
                } else {
                    State.KeyInPtn := SendOnHoldM()
                    SubSendUp(SafeMojiOnHold(1))
                }
            } else if(State.KeyInPtn == "MMM") {
                State.KeyInPtn := SendOnHoldMMM()
            }
            
            ChkIME()

            if(State.Oya == "N") {
                if(State.KeyInPtn == "") {
                    State.KeyInPtn := enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick :=  calcSendTick(pf_TickCount, State.Timeout)
                    JudgePushedKeys(SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1), SafeMojiOnHold(1))
                    if(State.KeyInPtn == "M") {
                        SendZeroDelay(SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1), SafeMojiOnHold(1), g_ZeroDelay)
                    }
                } else if(State.KeyInPtn == "M") {
                    State.KeyInPtn := enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    JudgePushedKeys(SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1), SafeMojiOnHold(2) . SafeMojiOnHold(1))
                } else if(State.KeyInPtn == "MM") {
                    enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.KeyInPtn := SendOnHoldMMM()
                    State.KeyInPtn := clearQueue()
                    State.Timeout := 60000
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                }
            } else {
                if(State.KeyInPtn == "") {
                    State.KeyInPtn := enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    g_Interval[State.KeyInPtn] := pf_TickCount - g_OyaTick[State.Oya]
                    State.Timeout := g_MaxTimeout
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    JudgePushedKeys(SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1), SafeMojiOnHold(1))
                    if(State.KeyInPtn == State.Oya . "M") {
                        SendZeroDelayOM()
                    }
                } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]$")) {
                    wOya := SafeOyaOnHold(1)
                    State.KeyInPtn := enqueueKey(State.Romaji, wOya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    g_Interval[State.KeyInPtn] := pf_TickCount - SafeTDownOnHold(1)
                    State.Timeout := Min(Floor(g_Interval[State.KeyInPtn]*g_OverlapOM/(100-g_OverlapOM)), g_MaxTimeout)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    JudgePushedKeys(SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1), SafeMojiOnHold(1))
                    if(State.KeyInPtn == State.Oya . "M") {
                        SendZeroDelayOM()
                    }
                } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD]?$")) {
                    mergeOMKey()
                    State.KeyInPtn := enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    JudgePushedKeys(SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1), SafeMojiOnHold(2) . SafeMojiOnHold(1))
                } else if(RegExMatch(State.KeyInPtn, "^M[RLABCD]$")) {
                    mergeMOKey()
                    State.KeyInPtn := enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                } else if(State.KeyInPtn == "MM") {
                    State.KeyInPtn := enqueueKey(State.Romaji, State.Oya, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKey, pf_TickCount)
                    State.Timeout := SetTimeout(State.KeyInPtn)
                    State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    State.KeyInPtn := SendOnHoldMMM()
                }
            }
            Critical("Off")
            return

        Case "T":
            kName := TenkeyHash.Has(GetKeyState("NumLock", "T") . kName) ? TenkeyHash[GetKeyState("NumLock", "T") . kName] : kName
            ProcessKeyDown("X") ; Route through to regular modifiers
            return

        Case "X":
            State.Trigger := g_metaKey
            pf_TickCount := Pf_Count()		
            keyTick[g_layoutPos] := pf_TickCount
            RegLogs(kName . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""

            if(State.PauseKey == kName) {
                State.IsPaused := gPauseStatus(State.IsPaused)
                trayIconRefresh(State.IsPaused)
            }
            keyState[g_layoutPos] |= 2

            ModeInitialize()
            if(ShiftMode[State.Romaji] == "プレフィックスシフト") {
                SubSendOne(MnDown(kName))
                SetKeyupSave(MnUp(kName), g_layoutPos)
                g_LastKey["表層"] := ""
                State.PrefixShift := ""
                Critical("Off")
                return
            }
            State.ModifierTick := pf_TickCount
            SubSendOne(MnDown(kName))
            SetKeyupSave(MnUp(kName), g_layoutPos)

            ChkIME()
            if(LF.Has(State.Romaji . "N" . KoyubiOrSans(State.Koyubi, State.Sans)) && LF[State.Romaji . "N" . KoyubiOrSans(State.Koyubi, State.Sans)] != "") {
                SetHotkey("On")
                SetHotkeyFunction("On")
            } else {
                SetHotkey("Off")
                SetHotkeyFunction("Off")
            }
            g_LastKey["表層"] := ""
            State.KeyInPtn := ""
            Critical("Off")
            return

        Case "S":
            State.Trigger := g_metaKey
            RegLogs(kName . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")

            pf_TickCount := Pf_Count()
            if(keyState.Has(g_layoutPos) && keyState[g_layoutPos] != 0) {
                if(keyState[g_layoutPos] == 2) {
                    if(pf_TickCount - keyTick[g_layoutPos] < g_MaxTimeoutM) {
                        Critical("Off")
                        return
                    }
                }
                keyState[g_layoutPos] |= 4
            }
            keyTick[g_layoutPos] := pf_TickCount
            State.Timeout := ""
            keyState[g_layoutPos] |= 2

            State.ModifierTick := pf_TickCount
            ModeInitialize()
            
            if(State.Sans == "S" && State.SansTick != INFINITE) {
                SubSendOne(MnDown(kName))
                SetKeyupSave(MnUp(kName), g_layoutPos)
                g_LastKey["表層"] := ""
            }
            State.Sans := "S"
            State.SansTick := pf_TickCount + g_MaxTimeout
            if(ShiftMode[State.Romaji] == "プレフィックスシフト") {
                State.PrefixShift := ""
            } else {
                State.KeyInPtn := ""
            }
            Critical("Off")
            return

        Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            pf_TickCount := Pf_Count()
            keyTick[g_layoutPos] := pf_TickCount
            RegLogs(kName . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""

            keyState[g_layoutPos] |= 2
            State.Trigger := g_metaKey
            if(State.PrefixShift == "") {
                State.PrefixShift := g_metaKey
                Critical("Off")
                return
            }
            SendKey(State.Romaji . State.PrefixShift . KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos)
            clearQueue()

            State.PrefixShift := ""
            Critical("Off")
            return
    }
}

;=======================================================================
; キー種別ごとのアップ処理 (元の keyupM: などの代替)
;=======================================================================
ProcessKeyUp(meta) {
    global
    
    Switch meta {
        Case "R", "L", "A", "B", "C", "D":
            State.Trigger := g_metaKeyUp.Has(g_metaKey) ? g_metaKeyUp[g_metaKey] : ""
            pf_TickCount := Pf_Count()

            setKeyup(g_layoutPos, pf_TickCount)

            if(keyState.Has(g_layoutPos) && keyState[g_layoutPos] != 0) {
                RegLogs(g_metaKey . " up", State.KeyInPtn, State.Trigger, State.Timeout, "")
                State.Timeout := ""
                
                if(State.KeyInPtn == g_metaKey) {
                    State.KeyInPtn := SendOnHoldO()
                } else if(State.KeyInPtn == "M" . g_metaKey) {
                    g_Interval[g_metaKey . "_" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                    g_Interval["M_" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx-1)
                    if(g_Interval["M_" . g_metaKey] > 0) {
                        vOverlap := Floor((g_Interval[g_metaKey . "_" . g_metaKey]*100)/g_Interval["M_" . g_metaKey])
                        State.KeyInPtn := SendOnHoldMO()
                    } else {
                        vOverlap := 0
                        State.KeyInPtn := SendOnHoldM()
                        State.KeyInPtn := SendOnHoldO()
                    }
                    /*
                    if(vOverlap >= g_OverlapMO) {
                        State.KeyInPtn := SendOnHoldMO()
                    } else {
                        State.KeyInPtn := SendOnHoldM()
                        State.KeyInPtn := SendOnHoldO()
                    }
                    */
                } else if(State.KeyInPtn == g_metaKey . "M") {
                    g_Interval["M_" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                    g_Interval[g_metaKey . "_" . g_metaKey] := pf_TickCount - g_OyaTick[g_metaKey]
                    if(g_Continue == 1 && g_OnHoldIdx == 1) {
                        if(g_Interval["M_" . g_metaKey] > g_Threshold) {
                            State.KeyInPtn := SendOnHoldOM()
                        } else {
                            State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKeyUp[g_metaKey], pf_TickCount)
                            g_Interval["M_" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                            State.Timeout := Min(Floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOMO))/g_OverlapOMO), g_MaxTimeout)
                            State.SendTick := pf_TickCount + Min(Floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOM))/g_OverlapOM), g_MaxTimeout)
                        }
                    } else {
                        if(g_Interval[g_metaKey . "_" . g_metaKey] > 0) {
                            vOverlap := Floor((100*g_Interval["M_" . g_metaKey])/g_Interval[g_metaKey . "_" . g_metaKey])
                        } else {
                            vOverlap := 0
                        }
                        if(vOverlap < g_OverlapOM && g_Interval["M_" . g_metaKey] <= g_Tau) {
                            State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKeyUp[g_metaKey], pf_TickCount)
                            g_Interval["M_" . g_metaKey] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                            State.Timeout := Min(Floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOMO))/g_OverlapOMO), g_MaxTimeout)
                            State.SendTick := pf_TickCount + Min(Floor((g_Interval["M_" . g_metaKey]*(100-g_OverlapOM))/g_OverlapOM), g_MaxTimeout)
                        } else {
                            State.KeyInPtn := SendOnHoldOM()
                        }
                    }
                } else if(RegExMatch(State.KeyInPtn, "^" . g_metaKey . "M[RLABCD]$")) {
                    State.KeyInPtn := SendOnHoldMO()
                    ; cleanup
                } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M" . g_metaKey . "$")) {
                    clearLastQueue()
                } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M" . g_metaKey . "[rlabcd]$")) {
                    wOya := SafeOyaOnHold(g_OnHoldIdx)
                    g_Interval["M_" . wOya] := SafeTUpOnHold(g_OnHoldIdx) - SafeTDownOnHold(g_OnHoldIdx-2)
                    g_Interval[g_metaKey . "_" . g_metaKey] := pf_TickCount - g_OyaTick[g_metaKey]
                    if(g_Interval["M_" . wOya] > g_Interval[g_metaKey . "_" . g_metaKey]) {
                        State.KeyInPtn := SendOnHoldOM()
                    } else {
                        State.KeyInPtn := SendOnHoldO()
                        State.KeyInPtn := SendOnHoldOM()
                    }
                }
            }
            SubSendUp(g_layoutPos)
            
            if(State.Oya == g_metaKey) {
                State.Oya := "N"
                /*
                if(g_Continue == 1) {
                    State.Oya := "N"
                    _oyaOther := "RLABCD"
                    Loop Parse, _oyaOther {
                        if(A_LoopField != g_metaKey) {
                            _layout := g_Oya2Layout.Has(A_LoopField) ? g_Oya2Layout[A_LoopField] : ""
                            if(_layout != "") {
                                _scanCode := ScanCodeHash.Has(_layout) ? ScanCodeHash[_layout] : ""
                                if(_scanCode != "") {
                                    _keyState := GetKeyState(_scanCode, "P")
                                    if(_keyState != 0) {
                                        State.Oya := A_LoopField
                                        break
                                    }
                                }
                            }
                        }
                    }
                } else {
                    State.Oya := "N"
                }
                */
            }
            Critical("Off")
            Sleep(-1)
            return

        Case "M":
            State.Trigger := g_metaKeyUp.Has(g_metaKey) ? g_metaKeyUp[g_metaKey] : ""
            pf_TickCount := Pf_Count()
            RegLogs(kName . " up", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
            keyState[g_layoutPos] := 0
            
            if(ShiftMode[State.Romaji] == "プレフィックスシフト" || ShiftMode[State.Romaji] == "小指シフト") {
                SubSendUp(g_layoutPos)
                Critical("Off")
                Sleep(-1)
                return
            }
            setKeyup(g_layoutPos, pf_TickCount)

            if(State.KeyInPtn == "M") {
                if(g_layoutPos == SafeMojiOnHold(1)) {
                    State.KeyInPtn := SendOnHoldM()
                }
            } else if(State.KeyInPtn == "MM") {
                if(g_layoutPos == SafeMojiOnHold(1)) {
                    _mode := SafeRomajiOnHold(1) . SafeOyaOnHold(1) . SafeKoyubiOnHold(1)
                    chk := _mode . SafeMojiOnHold(2) . SafeMojiOnHold(1)
                    if(!kdn.Has(chk) || kdn[chk] == "") {
                        State.KeyInPtn := SendOnHoldM()
                        SubSendUp(SafeMojiOnHold(1))
                        State.Timeout := SetTimeout(State.KeyInPtn)
                        State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    } else {
                        g_Interval["S1_1"] := SafeTUpOnHold(1) - SafeTDownOnHold(1)
                        g_Interval["S2_1"] := SafeTUpOnHold(1) - SafeTDownOnHold(2)
                        if(g_Interval["S1_1"] > 0) {
                            vOverlap := Floor((100*g_Interval["S2_1"])/g_Interval["S1_1"])
                        } else {
                            vOverlap := 0
                        }
                        if(g_Interval["S2_1"] > g_ThresholdSS || g_OverlapSS <= vOverlap) {
                            State.KeyInPtn := SendOnHoldMM()
                            if(State.KeyInPtn == "M") {
                                SubSendUp(SafeMojiOnHold(1))
                                State.KeyInPtn := SendOnHoldM()
                            }
                        } else {
                            State.KeyInPtn := enqueueKey(State.Romaji, g_metaKey, KoyubiOrSans(State.Koyubi, State.Sans), g_layoutPos, g_metaKeyUp[g_metaKey], 0)
                            State.Timeout := SetTimeout(State.KeyInPtn)
                            State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                        }
                    }
                } else if(g_layoutPos == SafeMojiOnHold(2)) {
                    State.KeyInPtn := SendOnHoldMM()
                    if(State.KeyInPtn == "M") {
                        SubSendUp(SafeMojiOnHold(1))
                        State.KeyInPtn := SendOnHoldM()
                    }
                }
            } else if(State.KeyInPtn == "MMm") {
                if(g_layoutPos == SafeMojiOnHold(2)) {
                    g_Interval["S1_2"] := SafeTUpOnHold(2) - SafeTDownOnHold(1)
                    g_Interval["S2_1"] := SafeTUpOnHold(1) - SafeTDownOnHold(2)
                    if (g_Interval["S1_2"] > 0) {
                        vOverlap := Floor((100*g_Interval["S2_1"])/g_Interval["S1_2"])
                    } else {
                        vOverlap := 0
                    }
                    if(g_OverlapSS <= vOverlap) {
                        State.KeyInPtn := SendOnHoldMM()
                        if(State.KeyInPtn == "M") {
                            SubSendUp(SafeMojiOnHold(1))
                            State.KeyInPtn := SendOnHoldM()
                        }
                    } else {
                        State.KeyInPtn := SendOnHoldM()
                        SubSendUp(SafeMojiOnHold(1))
                        State.KeyInPtn := SendOnHoldM()
                    }
                }
            } else if(State.KeyInPtn == "MMM") {
                State.KeyInPtn := SendOnHoldMMM()
            } else if(RegExMatch(State.KeyInPtn, "^M[RLABCD]$")) {
                if(SafeMetaOnHold(1) == "M" && g_layoutPos == SafeMojiOnHold(1)) {
                    wOya := SafeOyaOnHold(g_OnHoldIdx)
                    g_Interval["M_M"] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx-1)
                    g_Interval[wOya . "_M"] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx)
                    if(g_Interval["M_M"] > 0) {
                        vOverlap := Floor((100*g_Interval[wOya . "_M"])/g_Interval["M_M"])
                    } else {
                        vOverlap := 0
                    }
                    if(vOverlap < g_OverlapMO) {
                        State.KeyInPtn := SendOnHoldM()
                        State.Timeout := 60000
                        State.SendTick := calcSendTick(pf_TickCount, State.Timeout)
                    } else {
                        State.KeyInPtn := SendOnHoldMO()
                    }
                }
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD]?$")) {
                if((SafeMetaOnHold(1) == "M" && g_layoutPos == SafeMojiOnHold(1))
                || (SafeMetaOnHold(2) == "M" && g_layoutPos == SafeMojiOnHold(2))) {
                    State.KeyInPtn := SendOnHoldOM()
                }
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[rlabcd]$")) {
                if((SafeMetaOnHold(1) == "M" && g_layoutPos == SafeMojiOnHold(1))
                || (SafeMetaOnHold(2) == "M" && g_layoutPos == SafeMojiOnHold(2))) {
                    wOya := SafeOyaOnHold(g_OnHoldIdx)
                    g_Interval["M_" . wOya] := SafeTUpOnHold(g_OnHoldIdx) - SafeTDownOnHold(g_OnHoldIdx-1)
                    g_Interval["M_M"] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx-1)
                    if(g_Interval["M_M"] > 0) {
                        vOverlap := Floor((g_Interval["M_" . wOya]*100)/g_Interval["M_M"])
                    } else {
                        vOverlap := 0
                    }
                    if(vOverlap > g_OverlapOMO) {
                        State.KeyInPtn := SendOnHoldOM()
                    } else {
                        State.KeyInPtn := SendOnHoldO()
                        State.KeyInPtn := SendOnHoldM()
                        State.KeyInPtn := clearQueue()
                    }
                }
            } else if(RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD][rlabcd]$")) {
                if((SafeMetaOnHold(1) == "M" && g_layoutPos == SafeMojiOnHold(1))
                || (SafeMetaOnHold(2) == "M" && g_layoutPos == SafeMojiOnHold(2))) {
                    if (g_OnHoldIdx < 3) {
                        State.KeyInPtn := SendOnHoldOM()
                    } else {
                        wOya  := SafeOyaOnHold(g_OnHoldIdx)
                        wOya1 := SafeOyaOnHold(g_OnHoldIdx-1)
                        g_Interval["M_" . wOya] := SafeTDownOnHold(g_OnHoldIdx-2) - SafeTUpOnHold(g_OnHoldIdx)
                        g_Interval[wOya1 . "_M"] := pf_TickCount - SafeTDownOnHold(g_OnHoldIdx-1)
                        if(g_Interval["M_" . wOya] > g_Interval[wOya1 . "_M"]) {
                            State.KeyInPtn := SendOnHoldOM()
                        } else {
                            State.KeyInPtn := SendOnHoldO()
                            State.KeyInPtn := SendOnHoldOM()
                            State.KeyInPtn := clearQueue()
                        }
                    }
                }
            }
            SubSendUp(g_layoutPos)
            State.Trigger := ""
            Critical("Off")
            Sleep(-1)
            return

        Case "X", "T":
            State.Trigger := g_metaKeyUp.Has(g_metaKey) ? g_metaKeyUp[g_metaKey] : ""
            RegLogs(kName . " up", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
            SubSendUp(g_layoutPos)
            State.Trigger := ""
            Critical("Off")
            Sleep(-1)
            return

        Case "S":
            State.Trigger := g_metaKeyUp.Has(g_metaKey) ? g_metaKeyUp[g_metaKey] : ""
            RegLogs(kName . " up", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
            if(State.SansTick != INFINITE) {
                SubSendOne(MnDown(kName))
                SetKeyupSave(MnUp(kName), g_layoutPos)
                State.SansTick := INFINITE
            }
            SubSendUp(g_layoutPos)
            State.Trigger := ""
            State.Sans := "N"
            Critical("Off")
            Sleep(-1)
            return

        Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            State.Trigger := g_metaKeyUp.Has(g_metaKey) ? g_metaKeyUp[g_metaKey] : ""
            RegLogs(kName . " up", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
            SubSendUp(g_layoutPos)
            Critical("Off")
            Sleep(-1)
            return
    }
}

;----------------------------------------------------------------------
; 16[mSEC]ごとの割込処理 (メインループ)
;----------------------------------------------------------------------
Interrupt16() {
    global
    Critical("On")
    ScanModifier()
    ScanOyaKey()
    ScanPauseKey()
    
    if (State.Modifier != 0) {
        ModeInitialize()
    } else if (State.IsPaused == 1) {
        ModeInitialize()
        SetHotkey("Off")
        SetHotkeyFunction("Off")
    } else {
        ChkIME()
        chkKey := State.Romaji . "N" . KoyubiOrSans(State.Koyubi, State.Sans)
        if (LF.Has(chkKey) && LF[chkKey] != "") {
            SetHotkey("On")
            SetHotkeyFunction("On")
        } else {
            SetHotkey("Off")
            SetHotkeyFunction("Off")
        }
    }
    
    if (keyState.Has("A04") && keyState["A04"] != 0) {
        _TickCount := Pf_Count()
        if (_TickCount > keyTick["A04"] + 100) {
            ; ひらがな／カタカナキーはキーアップを受信できないから、0.1秒でキーアップと見做す
            g_layoutPos := "A04"
            attrKey := State.Romaji . KoyubiOrSans(State.Koyubi, State.Sans) . g_layoutPos
            g_metaKey := keyAttribute3.Has(attrKey) ? keyAttribute3[attrKey] : ""
            kName := keyNameHash.Has(g_layoutPos) ? keyNameHash[g_layoutPos] : ""
            ProcessKeyUp(g_metaKey)
        }
    }
    
    if (State.Sans == "S") {
        if (keyNameHash.Has(g_sansPos) && GetKeyState(keyNameHash[g_sansPos], "P") == 0) {
            SansSend()
        }
    }
    
    PollingTimeout()
    Critical("Off")
    
    if (!A_IsCompiled) {
        vImeConvMode := IME_GetConvMode()
        szConverting := IME_GetConverting()
        g_debugout3 := ":" . State.IsPaused
        g_debugout2 := g_LastKey.Has("表層") ? g_LastKey["表層"] : ""
        g_debugout := vImeMode ":" vImeConvMode szConverting ":" State.Romaji State.Oya KoyubiOrSans(State.Koyubi, State.Sans) ":" g_layoutPos ":" State.KeyInPtn ":" g_vOut
        ToolTip(g_debugout, 0, 0, 2)
    }
    Sleep(-1)
}

;----------------------------------------------------------------------
; ヘルパー関数群
;----------------------------------------------------------------------
SansSend() {
    global
    if (State.SansTick != INFINITE) {
        k := keyNameHash.Has(g_sansPos) ? keyNameHash[g_sansPos] : ""
        if (k != "") {
            SubSendOne(MnDown(k))
            SubSendOne(MnUp(k))
        }
        State.SansTick := INFINITE
        kup_save[g_sansPos] := ""
        keyState[g_sansPos] := 0
    }
    State.Sans := "N"
}

PollingTimeout() {
    global
    if (State.SendTick != INFINITE) {
        State.Trigger := "TO"
        _TickCount := Pf_Count()
        if (_TickCount > State.SendTick) {
            if (State.KeyInPtn == "M") {
                State.KeyInPtn := SendOnHoldM()
            } else if (State.KeyInPtn == "MM") {
                State.KeyInPtn := SendOnHoldMM()
                if (State.KeyInPtn == "M") {
                    SubSendUp(SafeMojiOnHold(1))
                    State.KeyInPtn := SendOnHoldM()
                }
            } else if (State.KeyInPtn == "MMm") {
                State.KeyInPtn := SendOnHoldM()
                SubSendUp(SafeMojiOnHold(1))
                State.KeyInPtn := SendOnHoldM()
            } else if (State.KeyInPtn == "MMM") {
                State.KeyInPtn := SendOnHoldMMM()
            } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]$")) {
                if (SafeMojiOnHold(1) == "A02" || g_KeySingle == "有効") {
                    State.KeyInPtn := SendOnHoldO()
                } else {
                    _layout := g_Oya2Layout.Has(State.Oya) ? g_Oya2Layout[State.Oya] : ""
                    if (_layout != "") {
                        _keyName := keyNameHash.Has(_layout) ? keyNameHash[_layout] : ""
                        if (_keyName != "" && GetKeyState(_keyName, "P") == 0) {
                            State.KeyInPtn := SendOnHoldO()
                        }
                    }
                }
            } else if (RegExMatch(State.KeyInPtn, "^M[RLABCD]$")) {
                State.KeyInPtn := SendOnHoldMO()
            } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]M$")) {
                State.KeyInPtn := SendOnHoldOM()
            } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD]$")) {
                State.KeyInPtn := SendOnHoldO()
                State.KeyInPtn := SendOnHoldOM()
            } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]M[rlabcd]$")) {
                State.KeyInPtn := SendOnHoldOM()
            } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD][rlabcd]$")) {
                ; キュー要素が3未満なら計算不能なので安全にフラッシュして抜ける
                if (g_OnHoldIdx < 3) {
                    State.KeyInPtn := SendOnHoldOM()
                } else {
                    wOya  := SafeOyaOnHold(g_OnHoldIdx)
                    wOya1 := SafeOyaOnHold(g_OnHoldIdx-1)
                    g_Interval["M_" . wOya] := SafeTUpOnHold(g_OnHoldIdx) - SafeTDownOnHold(g_OnHoldIdx-2)
                    g_Interval[wOya1 . "_M"] := _TickCount - SafeTDownOnHold(g_OnHoldIdx-1)
                    if (g_Interval["M_" . wOya] > g_Interval[wOya1 . "_M"]) {
                        State.KeyInPtn := SendOnHoldOM()
                    } else {
                        State.KeyInPtn := SendOnHoldO()
                        State.KeyInPtn := SendOnHoldOM()
                        State.KeyInPtn := clearQueue()
                    }
                }
            }
            State.KeyInPtn := clearQueue()
            State.Timeout := 60000
            State.SendTick := INFINITE
        }
        
        if (_TickCount > State.SansTick) {
            k := keyNameHash.Has(g_sansPos) ? keyNameHash[g_sansPos] : ""
            if (k != "") {
                SubSendOne(MnDown(k))
                State.SansTick := INFINITE
                SetKeyupSave(MnUp(k), g_sansPos)
            }
        }
    }
    State.Trigger := ""
}

ScanModifier() {
    global
    if (keyHook.Has(fkeyPosHash["左Shift"]) && keyHook[fkeyPosHash["左Shift"]] == "Off") {
        GetKeyStateWithLog5("左Shift")
    }
    if (keyHook.Has(fkeyPosHash["右Shift"]) && keyHook[fkeyPosHash["右Shift"]] == "Off") {
        GetKeyStateWithLog5("右Shift")
    }
    if ((keyHook.Has(fkeyPosHash["左Shift"]) && keyHook[fkeyPosHash["左Shift"]] == "Off") 
     || (keyHook.Has(fkeyPosHash["右Shift"]) && keyHook[fkeyPosHash["右Shift"]] == "Off")) {
        if ((keyState.Has(fkeyPosHash["左Shift"]) && keyState[fkeyPosHash["左Shift"]] != 0) 
         || (keyState.Has(fkeyPosHash["右Shift"]) && keyState[fkeyPosHash["右Shift"]] != 0)) {
            State.Koyubi := "K"
        } else {
            State.Koyubi := "N"
        }
    }
    if (keyHook.Has(fkeyPosHash["左Ctrl"]) && keyHook[fkeyPosHash["左Ctrl"]] == "Off") 
    {
        GetKeyStateWithLog5("左Ctrl")
        if (keyState[fkeyPosHash["左Ctrl"]] != 0) {
            State.AddModifier(0x0200)
        } else {
            State.RemoveModifier(0x0200)
        }
    }
    if (keyHook.Has(fkeyPosHash["右Ctrl"]) && keyHook[fkeyPosHash["右Ctrl"]] == "Off") 
    {
        GetKeyStateWithLog5("右Ctrl")
        if (keyState[fkeyPosHash["右Ctrl"]] != 0) {
            State.AddModifier(0x0400)
        } else {
            State.RemoveModifier(0x0400)
        }
    }
    if (keyHook.Has(fkeyPosHash["左Alt"]) && keyHook[fkeyPosHash["左Alt"]] == "Off") {
        GetKeyStateWithLog5("左Alt")
        if (keyState[fkeyPosHash["左Alt"]] != 0) {
            State.AddModifier(0x0800)
        } else {
            State.RemoveModifier(0x0800)
        }
    }
    if (keyHook.Has(fkeyPosHash["右Alt"]) && keyHook[fkeyPosHash["右Alt"]] == "Off") {
        GetKeyStateWithLog5("右Alt")
        if (keyState[fkeyPosHash["右Alt"]] != 0) {
            State.AddModifier(0x1000)
        } else {
            State.RemoveModifier(0x1000)
        }
    }
    if (keyHook.Has(fkeyPosHash["左Win"]) && keyHook[fkeyPosHash["左Win"]] == "Off") {
        GetKeyStateWithLog5("左Win")
        if (keyState[fkeyPosHash["左Win"]] != 0) {
            State.AddModifier(0x2000)
        } else {
            State.RemoveModifier(0x2000)
        }
    }
    if (keyHook.Has(fkeyPosHash["右Win"]) && keyHook[fkeyPosHash["右Win"]] == "Off") {
        GetKeyStateWithLog5("右Win")
        if (keyState[fkeyPosHash["右Win"]] != 0) {
            State.AddModifier(0x4000)
        } else {
            State.RemoveModifier(0x4000)
        }
    }
    GetKeyStateWithLog5("Applications")
}

ScanOyaKey() {
    global
    _oya := State.Oya
    _pos := g_Oya2Layout.Has(_oya) ? g_Oya2Layout[_oya] : ""

    if (_pos == "") {
        State.Oya := "N"
        return
    }

    if (keyHook.Has(_pos) && keyHook[_pos] == "Off") {
        if (keyState.Has(_pos) && keyState[_pos] != 0) {
            g_layoutPos := _pos
            g_metaKey := _oya
            ProcessKeyUp(_oya)
        } else {
            State.Oya := "N"
        }
        return
    }

    _scanCode := ScanCodeHash.Has(_pos) ? ScanCodeHash[_pos] : ""
    if (_scanCode = "") {
        State.Oya := "N"
        return
    }

    if (GetKeyState(_scanCode, "P") == 0) {
        if (keyState.Has(_pos) && keyState[_pos] != 0) {
            g_layoutPos := _pos
            g_metaKey := _oya
            ProcessKeyUp(_oya)
        } else {
            State.Oya := "N"
        }
    }
    /*
    _pos := g_Oya2Layout.Has(State.Oya) ? g_Oya2Layout[State.Oya] : ""
    if (_pos != "") {
        if (keyHook.Has(_pos) && keyHook[_pos] == "Off") {
            State.Oya := "N"
        } else {
            _scanCode := ScanCodeHash.Has(_pos) ? ScanCodeHash[_pos] : ""
            if (_scanCode != "" && GetKeyState(_scanCode, "P") == 0) {
                State.Oya := "N"
            }
        }
    } else {
        State.Oya := "N"
    }
    */
}

ScanPauseKey() {
    global
    if (State.PauseKey != "" && State.PauseKey != "無効") {
        if (GetKeyStateWithLog5(State.PauseKey) == 1) {
            State.IsPaused := gPauseStatus(State.IsPaused)
            trayIconRefresh(State.IsPaused)
        }
    }
}

ModeInitialize() {
    global
    if (State.KeyInPtn == "M") {
        State.KeyInPtn := SendOnHoldM()
    } else if (State.KeyInPtn == "MM") {
        State.KeyInPtn := SendOnHoldMM()
        if (State.KeyInPtn == "M") {
            SubSendUp(SafeMojiOnHold(1))
            State.KeyInPtn := SendOnHoldM()
        }
        State.Timeout := 60000
        State.SendTick := INFINITE
    } else if (State.KeyInPtn == "MMm") {
        State.KeyInPtn := SendOnHoldMM()
        if (State.KeyInPtn == "M") {
            SubSendUp(SafeMojiOnHold(1))
            State.KeyInPtn := SendOnHoldM()
        }
        State.Timeout := 60000
        State.SendTick := INFINITE
    } else if (State.KeyInPtn == "MMM") {
        State.KeyInPtn := SendOnHoldMMM()
        State.Timeout := 60000
        State.SendTick := INFINITE
    } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]$")) {
        State.KeyInPtn := SendOnHoldO()
        State.Timeout := 60000
        State.SendTick := INFINITE
    } else if (RegExMatch(State.KeyInPtn, "^M[RLABCD]$")) {
        State.KeyInPtn := SendOnHoldMO()
        State.Timeout := 60000
        State.SendTick := INFINITE
    } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD]?$")) {
        State.KeyInPtn := SendOnHoldOM()
        State.Timeout := 60000
        State.SendTick := INFINITE
    } else if (RegExMatch(State.KeyInPtn, "^[RLABCD]M[RLABCD]?[rlabcd]$")) {
        ; キュー要素が3未満なら計算不能なので安全にフラッシュして抜ける
        if (g_OnHoldIdx < 3) {
            State.KeyInPtn := SendOnHoldOM()
        } else {
            wOya  := SafeOyaOnHold(g_OnHoldIdx)
            wOya1 := SafeOyaOnHold(g_OnHoldIdx-1)
            g_Interval["M_" . wOya] := SafeTDownOnHold(g_OnHoldIdx-2) - SafeTUpOnHold(g_OnHoldIdx)
            g_Interval[wOya1 . "_M"] := Pf_Count() - SafeTDownOnHold(g_OnHoldIdx-1)
            if (g_Interval["M_" . wOya] > g_Interval[wOya1 . "_M"]) {
                State.KeyInPtn := SendOnHoldOM()
            } else {
                State.KeyInPtn := SendOnHoldO()
                State.KeyInPtn := SendOnHoldOM()
                State.KeyInPtn := clearQueue()
            }
        }
        State.Timeout := 60000
        State.SendTick := INFINITE
    }
}

GetKeyStateWithLog5(_fName) {
    global
    local _kDown := 0
    _locationPos := fkeyPosHash.Has(_fName) ? fkeyPosHash[_fName] : ""
    
    if (_locationPos != "" && keyHook.Has(_locationPos) && keyHook[_locationPos] == "Off") {
        vkey := fkeyVkeyHash.Has(_fName) ? fkeyVkeyHash[_fName] : ""
        stCurr := (vkey != "") ? GetKeyState(vkey, "P") : 0
        
        if (stCurr != 0 && keyState.Has(_locationPos) && keyState[_locationPos] == 0) {
            _kDown := 1
            RegLogs(kName . " down", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
        } else if (stCurr == 0 && keyState.Has(_locationPos) && keyState[_locationPos] != 0) {
            RegLogs(kName . " up", State.KeyInPtn, State.Trigger, State.Timeout, "")
            State.Timeout := ""
        }
        keyState[_locationPos] := stCurr
    }
    return _kDown
}

trayIconRefresh(a_Pause) {
    if (a_Pause == 0) {
        if (FileExist(A_ScriptDir . "\benizara_on.ico")) {
            TraySetIcon(A_ScriptDir . "\benizara_on.ico", 1)
        }
    } else {
        if (FileExist(A_ScriptDir . "\benizara_off.ico")) {
            TraySetIcon(A_ScriptDir . "\benizara_off.ico", 1)
        }
    }
    return 0
}

ChkIME() {
    global
    if (WinExist("ahk_class #32768")) {
        vImeMode := 0
    } else {
        vImeMode := IME_GET() & 32767
    }
    
    if (vImeMode == 0) {
        vImeConvMode := IME_GetConvMode()
        State.Romaji := "A"
    } else {
        vImeConvMode := IME_GetConvMode()
        if ((vImeConvMode & 0x01) == 1) {
            State.Romaji := "R"
        } else {
            State.Romaji := "A"
        }
    }
}

KoyubiOrSans(_Koyubi, _sans) {
    global
    if (State.Sans == "S") {
        k := keyNameHash.Has(g_sansPos) ? keyNameHash[g_sansPos] : ""
        if (k != "" && GetKeyState(k, "P") == 0) {
            SansSend()
            _sans := "N"
        }
    }
    if (_Koyubi == "K") {
        return "K"
    }
    if (_sans == "S") {
        return "S"
    }
    return "N"
}

RegLogs(_keyEvent, _KeyInPtn, _trigger, _Timeout, _send) {
    global
    local _tickCount, _tmp, _timeSinceLastLog
    static tickLast := 0
    
    _tickCount := Pf_Count()
    _timeSinceLastLog := _tickCount - tickLast
    tickLast := _tickCount
    _tickCount := Mod(_tickCount, 100000)
    
    _tmp := Format("{: 6}|", _tickCount)
    _timeSinceLastLog := Mod(_timeSinceLastLog, 100000)
    _tmp .= Format("{: 6}|", _timeSinceLastLog)
    _tmp .= " "
    _tmp .= Format("{:-16}|", _keyEvent)
    _tmp .= SubStr(State.Oya . " ", 1, 1) . "|"
    _tmp .= Format("{:-4}|", _KeyInPtn)
    _tmp .= Format("{:-3}|", _trigger)
    
    _MojiPos := "   "
    if (g_OnHoldIdx == 1) {
        if (SafeMetaOnHold(1) == "M") {
            _MojiPos := SafeMojiOnHold(1)
        }
    } else if (g_OnHoldIdx >= 2) {
        if (SafeMetaOnHold(1) == "M") {
            _MojiPos := SafeMojiOnHold(1)
        } else if (SafeMetaOnHold(2) == "M") {
            _MojiPos := SafeMojiOnHold(2)
        }
    }
    _tmp .= Format("{: 3}|", vOverlap)
    vOverlap := ""
    _sendTick := Mod(State.SendTick, 100000)
    _tmp .= Format("{: 6}|", _sendTick)
    _tmp .= _send
    
    g_Log[idxLogs] := _tmp
    idxLogs += 1
    idxLogs &= 63
    
    if (aLogCnt < 64) {
        aLogCnt += 1
    }
}