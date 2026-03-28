;*****************************************************************************
;  高精度タイマー関数群 (PfCount.ahk) (AHK v2版)
;*****************************************************************************
#Requires AutoHotkey v2.0
global TickFrequency := 0
global Ticks0 := 0

;-----------------------------------------------------------
; Performance Counterの初期化
; 戻り値          1:成功 / 0:失敗
;-----------------------------------------------------------
Pf_Init()
{
    global TickFrequency, Ticks0
    TickFrequency := 0
    Ticks0 := 0
    
    ; v2では参照渡しに & を使用します
    ret := DllCall("QueryPerformanceFrequency", "Int64*", &TickFrequency)
    if (ret)
    {
        ret := DllCall("QueryPerformanceCounter", "Int64*", &Ticks0)
    }
    
    if (!ret)
    {
        TickFrequency := 0
        Ticks0 := 0
    }
    return ret
}

;-----------------------------------------------------------
; Performance Counterによる起動後の経過時間（ミリ秒）
; 戻り値	0以外 起動後の経過時間 / 0:失敗
;-----------------------------------------------------------
Pf_Count()
{
    global TickFrequency, Ticks0
    if (TickFrequency == 0)
    {
        return A_TickCount
    }

    Ticks1 := 0
    if (!DllCall("QueryPerformanceCounter", "Int64*", &Ticks1))
    {
        return 0
    }
    myTick := (Ticks1 - Ticks0) * 1000.0 / TickFrequency
    return Floor(myTick)
}