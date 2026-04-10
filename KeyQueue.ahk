;-----------------------------------------------------------------------
;	名称：KeyQueue.ahk (AHK v2版)
;	機能：キーコードのキュー
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
global g_RomajiOnHold := Map()
global g_KoyubiOnHold := Map()
global g_OyaOnHold    := Map()
global g_MojiOnHold   := Map()
global g_TDownOnHold  := Map()
global g_TUpOnHold    := Map()
global g_MetaOnHold   := Map()
global g_OnHoldIdx    := 1

; v1ではラベル(InitKeyQueue:)でしたが、v2では関数として定義します
InitKeyQueue()
{
	global
	g_RomajiOnHold.Clear()
	g_KoyubiOnHold.Clear()
	g_OyaOnHold.Clear()
	g_MojiOnHold.Clear()
	g_TDownOnHold.Clear()
	g_TUpOnHold.Clear()
	g_MetaOnHold.Clear()

	g_OnHoldIdx := 1
	
	; 0番目のインデックスも安全のため空文字で初期化しておきます
	g_MetaOnHold[0] := ""
    g_TDownOnHold[0] := 0    
    g_TUpOnHold[0] := 0      
    g_OyaOnHold[0] := ""     
    g_MojiOnHold[0] := ""    
    g_RomajiOnHold[0] := ""  
    g_KoyubiOnHold[0] := ""
    
	Loop 5
	{
		g_RomajiOnHold[A_Index] := ""
		g_OyaOnHold[A_Index]    := ""
		g_KoyubiOnHold[A_Index] := ""
		g_MojiOnHold[A_Index]   := ""
		g_TDownOnHold[A_Index]  := 0
		g_TUpOnHold[A_Index]    := 0
		g_MetaOnHold[A_Index]   := ""
	}
}
	
;----------------------------------------------------------------------
; 文字キー・親指キー出力後のキューの取り出し
;----------------------------------------------------------------------
dequeueKey()
{
	global

	if (g_OnHoldIdx >= 3) {
		g_OnHoldIdx := 3
	}
	
	; keyState が存在するか確認してからアクセス (v2の厳格なエラー対策)
	if (g_MojiOnHold.Has(1) && g_MojiOnHold[1] != "" && keyState.Has(g_MojiOnHold[1]) && keyState[g_MojiOnHold[1]] == 2) {
		keyState[g_MojiOnHold[1]] := 1
	}
	
	Loop 5
	{
		nextMeta := g_MetaOnHold.Has(A_Index + 1) ? g_MetaOnHold[A_Index + 1] : ""
		if (A_Index < g_OnHoldIdx && !RegExMatch(nextMeta, "^[rlabcdm]$")) {
			g_RomajiOnHold[A_Index] := g_RomajiOnHold[A_Index+1]
			g_OyaOnHold[A_Index]    := g_OyaOnHold[A_Index+1]
			g_KoyubiOnHold[A_Index] := g_KoyubiOnHold[A_Index+1]
			g_MojiOnHold[A_Index]   := g_MojiOnHold[A_Index+1]
			g_TDownOnHold[A_Index]  := g_TDownOnHold[A_Index+1]
			g_TUpOnHold[A_Index]    := g_TUpOnHold[A_Index+1]
			g_MetaOnHold[A_Index]   := g_MetaOnHold[A_Index+1]
		} else {
			g_RomajiOnHold[A_Index] := ""
			g_OyaOnHold[A_Index]    := ""
			g_KoyubiOnHold[A_Index] := ""
			g_MojiOnHold[A_Index]   := ""
			g_TDownOnHold[A_Index]  := 0
			g_TUpOnHold[A_Index]    := 0
			g_MetaOnHold[A_Index]   := ""
		}
	}
	g_OnHoldIdx := countQueue()
	return g_OnHoldIdx
}

;----------------------------------------------------------------------
; 文字キー・親指キーをキューにセット
;----------------------------------------------------------------------
enqueueKey(_Romaji, _Oya, _Koyubi, _Moji, _Meta, _Tick)
{
	global
	local _KeyInPtn

	g_OnHoldIdx := countQueue()
	
	currMeta := g_MetaOnHold.Has(g_OnHoldIdx) ? g_MetaOnHold[g_OnHoldIdx] : ""
	if (RegExMatch(currMeta, "^[rlabcdm]$")) {
		g_RomajiOnHold[g_OnHoldIdx] := ""
		g_OyaOnHold[g_OnHoldIdx]    := ""
		g_KoyubiOnHold[g_OnHoldIdx] := ""
		g_MojiOnHold[g_OnHoldIdx]   := ""
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := 0
		g_MetaOnHold[g_OnHoldIdx]   := ""
		g_OnHoldIdx -= 1
	}
	
	if (RegExMatch(_Meta, "^[rlabcdm]$")) {
		g_OnHoldIdx += 1
		g_RomajiOnHold[g_OnHoldIdx] := _Romaji
		g_OyaOnHold[g_OnHoldIdx]    := _Oya
		g_KoyubiOnHold[g_OnHoldIdx] := _Koyubi
		g_MojiOnHold[g_OnHoldIdx]   := _Moji
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := _Tick
		g_MetaOnHold[g_OnHoldIdx]   := _Meta
	} else {
		g_OnHoldIdx += 1
		g_RomajiOnHold[g_OnHoldIdx] := _Romaji
		g_OyaOnHold[g_OnHoldIdx]    := _Oya
		g_KoyubiOnHold[g_OnHoldIdx] := _Koyubi
		g_MojiOnHold[g_OnHoldIdx]   := _Moji
		g_TDownOnHold[g_OnHoldIdx]  := _Tick
		g_MetaOnHold[g_OnHoldIdx]   := _Meta
		g_TUpOnHold[g_OnHoldIdx]    := 0
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; キーアップを設定
;----------------------------------------------------------------------
queueClearKeyup()
{
	global

	g_OnHoldIdx := countQueue()
	currMeta := g_MetaOnHold.Has(g_OnHoldIdx) ? g_MetaOnHold[g_OnHoldIdx] : ""
	
	if (RegExMatch(currMeta, "^[rlabcdm]$")) {
		g_RomajiOnHold[g_OnHoldIdx] := ""
		g_OyaOnHold[g_OnHoldIdx]    := ""
		g_KoyubiOnHold[g_OnHoldIdx] := ""
		g_MojiOnHold[g_OnHoldIdx]   := ""
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := 0
		g_MetaOnHold[g_OnHoldIdx]   := ""
		g_OnHoldIdx -= 1
	}
}

;----------------------------------------------------------------------
; キーアップを設定
;----------------------------------------------------------------------
setKeyup(_Moji, _UpTick)
{
	global

	Loop 5
	{
		if (g_MojiOnHold.Has(A_Index) && _Moji == g_MojiOnHold[A_Index]) {
			g_TUpOnHold[A_Index] := _UpTick
		}
	}
}

;----------------------------------------------------------------------
; キューをカウント
;----------------------------------------------------------------------
countQueue()
{
	global
	local _onHoldIdx
	
	_onHoldIdx := 0
	Loop 5
	{
		if (g_MetaOnHold.Has(A_Index) && g_MetaOnHold[A_Index] != "") {
			_onHoldIdx := A_Index
		}
	}
	return _onHoldIdx
}

;----------------------------------------------------------------------
; キューからキー入力パターンを取得
;----------------------------------------------------------------------
getKeyinPtnFromQueue()
{
	global
	local _keyInPtn
	
	_keyInPtn := ""
	Loop 5
	{
		if (g_MetaOnHold.Has(A_Index) && g_MetaOnHold[A_Index] != "") {
			_keyInPtn .= g_MetaOnHold[A_Index]
		}
	}
	
	firstOya := g_OyaOnHold.Has(1) ? g_OyaOnHold[1] : ""
	if ((_keyInPtn == "M" || RegExMatch(_keyInPtn, "^M[rlabcd]$")) && RegExMatch(firstOya, "^[RLABCD]$"))
	{
		_keyInPtn := firstOya . _keyInPtn
	}
	return _keyInPtn
}

;----------------------------------------------------------------------
; 文字キーのOMを１つにマージ
;----------------------------------------------------------------------
mergeOMKey()
{
	global
	
	meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
	meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""
	
	if (RegExMatch(meta1, "^[RLABCD]$") && meta2 == "M") {
		g_RomajiOnHold[2] := g_RomajiOnHold[1]
		g_OyaOnHold[2]    := g_OyaOnHold[1]
		g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
		dequeueKey()
	}
}

;----------------------------------------------------------------------
; 文字キーのMOを１つにマージ
;----------------------------------------------------------------------
mergeMOKey()
{
	global
	
	meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
	meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""

	if (meta1 == "M" && RegExMatch(meta2, "^[RLABCD]$")) {
		g_MetaOnHold[2]   := g_MetaOnHold[1]
		g_MojiOnHold[2]   := g_MojiOnHold[1]
		g_TDownOnHold[2]  := g_TDownOnHold[1]
		g_TUpOnHold[2]    := g_TUpOnHold[1]
		dequeueKey()
	}
}

;----------------------------------------------------------------------
; 文字キーキューの全クリア
;----------------------------------------------------------------------
clearQueue()
{
	global
	
	Loop 5
	{
		g_RomajiOnHold[A_Index] := ""
		g_OyaOnHold[A_Index]    := ""
		g_KoyubiOnHold[A_Index] := ""
		
		currMoji := g_MojiOnHold.Has(A_Index) ? g_MojiOnHold[A_Index] : ""
		if (currMoji != "" && keyState.Has(currMoji) && keyState[currMoji] == 2) {
			keyState[currMoji] := 1
		}
		
		g_MojiOnHold[A_Index]   := ""
		g_TDownOnHold[A_Index]  := 0
		g_TUpOnHold[A_Index]    := 0
		g_MetaOnHold[A_Index]   := ""
	}
	g_OnHoldIdx := 0
	return ""
}

;----------------------------------------------------------------------
; 文字キーキューの末尾のクリア
;----------------------------------------------------------------------
clearLastQueue()
{
	global

	if (g_OnHoldIdx != 0)
	{
		g_RomajiOnHold[g_OnHoldIdx] := ""
		g_OyaOnHold[g_OnHoldIdx]    := ""
		g_KoyubiOnHold[g_OnHoldIdx] := ""
		
		currMoji := g_MojiOnHold.Has(g_OnHoldIdx) ? g_MojiOnHold[g_OnHoldIdx] : ""
		if (currMoji != "" && keyState.Has(currMoji) && keyState[currMoji] == 2) {
			keyState[currMoji] := 1
		}
		
		g_MojiOnHold[g_OnHoldIdx]   := ""
		g_TDownOnHold[g_OnHoldIdx]  := 0
		g_TUpOnHold[g_OnHoldIdx]    := 0
		g_MetaOnHold[g_OnHoldIdx]   := ""
		g_OnHoldIdx -= 1
	}
	return ""
}

;----------------------------------------------------------------------
; 押されている文字キーの取得
;----------------------------------------------------------------------
GetMojiOnHold()
{
	global
	local _Moji
	
	_Moji := ""
	Loop g_OnHoldIdx
	{
		if (g_MetaOnHold.Has(A_Index) && g_MetaOnHold[A_Index] == "M") {
			_Moji .= g_MojiOnHold[A_Index]
		}
	}
	return _Moji
}

;----------------------------------------------------------------------
; キュー中の文字数
;----------------------------------------------------------------------
countMoji()
{
	global
	local _cntM

	_cntM := 0
	Loop g_OnHoldIdx
	{
		if (g_MetaOnHold.Has(A_Index) && g_MetaOnHold[A_Index] == "M") {
			_cntM += 1
		}
	}
	return _cntM
}
;----------------------------------------------------------------------
; 安全なキューアクセス関数群
; インデックスが範囲外の場合はデフォルト値を返す
;----------------------------------------------------------------------
SafeTDownOnHold(idx) {
    global g_TDownOnHold
    return (idx >= 1 && g_TDownOnHold.Has(idx)) ? g_TDownOnHold[idx] : 0
}

SafeTUpOnHold(idx) {
    global g_TUpOnHold
    return (idx >= 1 && g_TUpOnHold.Has(idx)) ? g_TUpOnHold[idx] : 0
}

SafeOyaOnHold(idx) {
    global g_OyaOnHold
    return (idx >= 1 && g_OyaOnHold.Has(idx)) ? g_OyaOnHold[idx] : ""
}

SafeMetaOnHold(idx) {
    global g_MetaOnHold
    return (idx >= 1 && g_MetaOnHold.Has(idx)) ? g_MetaOnHold[idx] : ""
}

SafeMojiOnHold(idx) {
    global g_MojiOnHold
    return (idx >= 1 && g_MojiOnHold.Has(idx)) ? g_MojiOnHold[idx] : ""
}

SafeRomajiOnHold(idx) {
    global g_RomajiOnHold
    return (idx >= 1 && g_RomajiOnHold.Has(idx)) ? g_RomajiOnHold[idx] : ""
}

SafeKoyubiOnHold(idx) {
    global g_KoyubiOnHold
    return (idx >= 1 && g_KoyubiOnHold.Has(idx)) ? g_KoyubiOnHold[idx] : ""
}
