;-----------------------------------------------------------------------
;	名称：SendOnHold.ahk (AHK v2版)
;	機能：キューのキーコード送信
;	作者：Ken'ichiro Ayaki
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
;----------------------------------------------------------------------
; 保留の出力：セットされた文字のセットされた親指の出力
;----------------------------------------------------------------------
SendOnHoldMO()
{
	global
	local _cntM, _mode, _KeyInPtn
	
	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
	} else if(_cntM >= 1) {
		meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
		meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""

		if(meta1 == "M" && RegExMatch(meta2, "^[RLABCD]$"))
		{
			_mode := g_RomajiOnHold[2] . g_OyaOnHold[2] . g_KoyubiOnHold[2]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			clearQueue()
		} else if(meta1 == "M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			clearQueue()
		}
	} else {
		clearQueue() ; debugging
	}
	if(g_Continue == 0) {
		State.Oya := "N"
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留の出力：セットされた文字のセットされた親指の出力
;----------------------------------------------------------------------
SendOnHoldOM()
{
	global
	local _cntM, _mode, _KeyInPtn
	
	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		clearQueue()
	} else if(_cntM >= 1) {
		meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
		meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""

		if(RegExMatch(meta1, "^[RLABCD]$") && meta2 == "M")
		{
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			SendOnHold(_mode, g_MojiOnHold[2], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			clearQueue()
		} else if(meta1 == "M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			clearQueue()
		}
	} else {
		clearQueue() ; debugging
	}
	if(g_Continue == 0) {
		State.Oya := "N"
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldM()
{
	global
	local _cntM, _mode, _KeyInPtn
	
	_cntM := countMoji()
	if(_cntM >= 1) {
		meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
		meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""

		if(g_OnHoldIdx >= 2 && RegExMatch(meta1, "^[RLABCD]$") && meta2 == "M")
		{
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
			dequeueKey()
		} else if(meta1 == "M") {
			_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		}
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldMM()
{
	global
	local _cntM, _keyInPtn, _mode

	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		_keyInPtn := clearQueue()
		State.Timeout := 60000
		State.SendTick := INFINITE
		return _keyInPtn
	}
	else if(_cntM == 1) {
		_keyInPtn := SendOnHoldM()
		_keyInPtn := clearQueue()
		State.Timeout := 60000
		State.SendTick := INFINITE
		return _keyInPtn
	}
	
	if(_cntM >= 2) {
		meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
		meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""
		meta3 := g_MetaOnHold.Has(3) ? g_MetaOnHold[3] : ""

		if(g_OnHoldIdx >= 3 && RegExMatch(meta1, "^[RLABCD]$") && meta2 == "M" && meta3 == "M")
		{
			g_RomajiOnHold[2] := g_RomajiOnHold[1]
			g_OyaOnHold[2]    := g_OyaOnHold[1]
			g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
			dequeueKey()
		}
		_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
		
		chkKey := _mode . g_MojiOnHold[2] . g_MojiOnHold[1]
		if(kdn.Has(chkKey) && kdn[chkKey] != "") {
			SendOnHold(_mode, g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)
			dequeueKey()
			dequeueKey()
			_keyInPtn := clearQueue()
			State.Timeout := 60000
			State.SendTick := INFINITE
		} else {
			_keyInPtn := SendOnHoldM()
		}
	} else {
		_keyInPtn := SendOnHoldM()
	}
	return _keyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力：セットされた文字の出力
;----------------------------------------------------------------------
SendOnHoldMMM()
{
	global
	local _cntM, _KeyInPtn, _mode
	
	_cntM := countMoji()
	if(g_OnHoldIdx < 1) {
		_KeyInPtn := clearQueue()
		State.Timeout := 60000
		State.SendTick := INFINITE
		return _KeyInPtn
	}
	else if(_cntM == 1) {
		_KeyInPtn := SendOnHoldM()
		return _KeyInPtn
	}
	else if(_cntM == 2) {
		_KeyInPtn := SendOnHoldMM()
		if(_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[1])
			_KeyInPtn := SendOnHoldM()
		}
		return _KeyInPtn
	}
	
	meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
	meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""
	meta3 := g_MetaOnHold.Has(3) ? g_MetaOnHold[3] : ""
	meta4 := g_MetaOnHold.Has(4) ? g_MetaOnHold[4] : ""

	; 異常時の対処
	if(RegExMatch(meta1, "^[RLABCD]$") && meta2 == "M" && meta3 == "M" && meta4 == "M")
	{
		g_RomajiOnHold[2] := g_RomajiOnHold[1]
		g_OyaOnHold[2]    := g_OyaOnHold[1]
		g_KoyubiOnHold[2] := g_KoyubiOnHold[1]
		dequeueKey()
		_KeyInPtn := getKeyinPtnFromQueue()
	}
	
	_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]
	chkKey3 := _mode . g_MojiOnHold[3] . g_MojiOnHold[2] . g_MojiOnHold[1]
	chkKey2 := _mode . g_MojiOnHold[2] . g_MojiOnHold[1]
	
	if(kdn.Has(chkKey3) && kdn[chkKey3] != "") {
		SendOnHold(_mode, g_MojiOnHold[3] . g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)	
		_KeyInPtn := clearQueue()
		State.Timeout := 60000
		State.SendTick := INFINITE
	} else if(kdn.Has(chkKey2) && kdn[chkKey2] != "") {
		SendOnHold(_mode, g_MojiOnHold[2] . g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		dequeueKey()
		SubSendUp(g_MojiOnHold[1])
		_KeyInPtn := SendOnHoldM()
		_KeyInPtn := clearQueue()
		return _KeyInPtn
	} else {
		SendOnHold(_mode, g_MojiOnHold[1], g_ZeroDelay)
		dequeueKey()
		SubSendUp(g_MojiOnHold[1])
		
		_KeyInPtn := SendOnHoldMM()
		if(_KeyInPtn == "M") {
			SubSendUp(g_MojiOnHold[1])
			_KeyInPtn := SendOnHoldM()
			_KeyInPtn := clearQueue()
		} else {
			_KeyInPtn := clearQueue()
		}
	}
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留された親指キーの出力
;----------------------------------------------------------------------
SendOnHoldO()
{
	global
	local _KeyInPtn, _vOut

	meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
	if(RegExMatch(meta1, "^[RLABCD]$")) 
	{
		if(g_KeySingle == "有効" || g_MojiOnHold[1] == "A02") {
			chkKey := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1] . g_MojiOnHold[1]
			_vOut := kdn.Has(chkKey) ? kdn[chkKey] : ""
			SubSendOne(_vOut)
			SetKeyupSave(kup.Has(chkKey) ? kup[chkKey] : "", g_MojiOnHold[1])
		}
		dequeueKey()
	}
	queueClearKeyup()

	if(g_MetaOnHold.Has(1) && g_MetaOnHold[1] == "M") {	; 直前の文字キーをシフトオフする
		g_OyaOnHold[1] := "N"
	}
	if(g_Continue == 0) 
	{
		State.Oya := "N"
	}
	_KeyInPtn := getKeyinPtnFromQueue()
	return _KeyInPtn
}

;----------------------------------------------------------------------
; 保留キーの出力関数
;----------------------------------------------------------------------
SendOnHold(_mode, _MojiOnHold, _ZeroDelay)
{
	global
	local _MojiOnHoldLast, _vOut, _nextKey, _aStr

	g_KeyOnHold := GetPushedKeys()
	_MojiOnHoldLast := SubStr(_MojiOnHold, StrLen(_MojiOnHold)-2)
	
	chkKeyA := _mode . g_KeyOnHold . _MojiOnHold
	if(StrLen(_MojiOnHold) == 3 && StrLen(g_KeyOnHold) == 6 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "") {
		_MojiOnHold := g_KeyOnHold . _MojiOnHold
	} else if(StrLen(_MojiOnHold) == 3 && StrLen(g_KeyOnHold) == 3 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "") {
		_MojiOnHold := g_KeyOnHold . _MojiOnHold
	} else if(StrLen(_MojiOnHold) == 6 && StrLen(g_KeyOnHold) == 3 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "") {
		_MojiOnHold := g_KeyOnHold . _MojiOnHold
	}
	
	_vOut := kdn.Has(_mode . _MojiOnHold) ? kdn[_mode . _MojiOnHold] : ""
	kup_save[_MojiOnHoldLast] := kup.Has(_mode . _MojiOnHold) ? kup[_mode . _MojiOnHold] : ""
	
	_nextKey := nextDakuten(_mode, _MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, &_down, &_up, &_status)
		_vOut := _down
		kup_save[_MojiOnHoldLast] := _up
	} else {
		g_LastKey["表層"] := kLabel.Has(_mode . _MojiOnHold) ? kLabel[_mode . _MojiOnHold] : ""
	}
	
	if(_ZeroDelay == 1)
	{
		if(_vOut != g_ZeroDelayOut)
		{
			CancelZeroDelayOut(_ZeroDelay)
			SubSend(_vOut)
		} else {
			RegLogs("", State.KeyInPtn, State.Trigger, State.Timeout, "")
		}
		g_ZeroDelayOut := ""
		g_ZeroDelaySurface := ""
	} else {
		SubSend(_vOut)
	}
}

;----------------------------------------------------------------------
; 送信文字列の出力
;----------------------------------------------------------------------
SubSend(_vOut)
{
	global g_vOut

	g_vOut := _vOut
	_strokes := StrSplit(_vOut, Chr(9))
	_scnt := 0
	_sendch := ""
	Loop _strokes.Length
	{
		_stroke := _strokes[A_Index]
		_idx := InStr(_stroke, "{")
		if (_idx > 0 && _idx + 1 <= StrLen(_stroke))
		{
			_sendch := SubStr(_stroke, _idx + 1, 1)
		} else {
			_sendch := ""
		}
		
		if(State.Koyubi == "K" && isCapsLock(_sendch) && InStr(_stroke, "{vk") == 0) {
			if(_scnt >= 4) 
			{
				SetKeyDelay(16, -1)
				_scnt := 0
			} else {
				SetKeyDelay(-1, -1)
			}
			Send("{Blind}{CapsLock}")
			_scnt +=  1
			RegLogs("", State.KeyInPtn, State.Trigger, State.Timeout, "{capslock}")
			State.Timeout := ""
			
			if(InStr(_stroke, "^{M") > 0 || InStr(_stroke, "{Enter") > 0) {
				_scnt += 4
			}
			if(_scnt >= 4)
			{
				SetKeyDelay(64, -1)
				_scnt := 0
			} else {
				SetKeyDelay(-1, -1)
			}
			Send(_stroke)
			_scnt += 1
			RegLogs("", State.KeyInPtn, State.Trigger, State.Timeout, _stroke)
			State.Timeout := ""
			
			if(_scnt >= 4) 
			{
				SetKeyDelay(16, -1)
				_scnt := 0
			} else {
				SetKeyDelay(-1, -1)
			}
			Send("{Blind}{CapsLock}")
			_scnt += 1
			RegLogs("", State.KeyInPtn, State.Trigger, State.Timeout, "{capslock}")
			State.Timeout := ""
		} else {
			if(InStr(_stroke, "^{M") > 0 || InStr(_stroke, "{Enter") > 0) {
				_scnt += 4
			}
			if(_scnt >= 4)
			{
				SetKeyDelay(64, -1)
				_scnt := 0
			} else {
				SetKeyDelay(-1, -1)
			}
			Send(_stroke)
			RegLogs("", State.KeyInPtn, State.Trigger, State.Timeout, _stroke)
			_scnt += 1
			State.Timeout := ""
		}
	}
}

;----------------------------------------------------------------------
; 送信文字列の出力・１つだけ
;----------------------------------------------------------------------
SubSendOne(_vOut)
{
	global
	
	if(_vOut != "") {
		SetKeyDelay(-1, -1)
		_vOut2 := "{Blind}" . _vOut
		Send(_vOut2)
		RegLogs("", State.KeyInPtn, State.Trigger, State.Timeout, _vOut2)
		State.Timeout := ""
	}
}

;----------------------------------------------------------------------
; キーダウン時の出力コードを保存
;----------------------------------------------------------------------
SetKeyupSave(_kup, _layoutPos)
{
	global kup_save, keyState
	kup_save[_layoutPos] := _kup
	keyState[_layoutPos] := 1
}

;----------------------------------------------------------------------
; キーアップ時の出力コードを送信
;----------------------------------------------------------------------
SubSendUp(_layoutPos)
{
	global kup_save, keyState
	if (kup_save.Has(_layoutPos)) {
		SubSendOne(kup_save[_layoutPos])
		kup_save[_layoutPos] := ""
	}
	keyState[_layoutPos] := 0
}

;----------------------------------------------------------------------
; capslockが必要か
;----------------------------------------------------------------------
isCapsLock(_ch)
{
	if (_ch == "")
		return false
	_code := Ord(_ch)
	if(0x61 <= _code && _code <= 0x7A) {
		return true
	}	
	if(InStr("1234567890-^\@[;:],./\", _ch) > 0) {
		return true
	}
	return false
}

;----------------------------------------------------------------------
; キーから送信文字列に変換
;----------------------------------------------------------------------
MnDownUp(_key)
{
	if(_key != "")
		return "{" . _key . " down}{" . _key . " up}"
	else
		return ""
}

;----------------------------------------------------------------------
; 零遅延モード出力のキャンセル
;----------------------------------------------------------------------
CancelZeroDelayOut(_ZeroDelay) {
	global g_ZeroDelaySurface, g_ZeroDelayOut

	if(_ZeroDelay == 1) {
		_len := StrLen(g_ZeroDelaySurface)
		Loop _len
		{
			SubSendOne(MnDown("BS"))
			SubSendOne(MnUp("BS"))
		}
	}
	g_ZeroDelaySurface := ""
	g_ZeroDelayOut := ""
}

;----------------------------------------------------------------------
; キーダウン・アップ時にSendする文字列を設定する
;----------------------------------------------------------------------
MnDown(_aStr) {
	return _aStr != "" ? "{" . _aStr . " down}" : ""
}

MnUp(_aStr) {
	return _aStr != "" ? "{" . _aStr . " up}" : ""
}

;----------------------------------------------------------------------
; キーをすぐさま出力
;----------------------------------------------------------------------
SendKey(_mode, _MojiOnHold) {
	global
	local _vOut, _nextKey, _aStr
	
	_vOut                 := kdn.Has(_mode . _MojiOnHold) ? kdn[_mode . _MojiOnHold] : ""
	kup_save[_MojiOnHold] := kup.Has(_mode . _MojiOnHold) ? kup[_mode . _MojiOnHold] : ""
	
	_nextKey := nextDakuten(_mode, _MojiOnHold)
	if(_nextKey != "") {
		g_LastKey["表層"] := _nextKey
		_aStr := "後" . g_LastKey["表層"]
		GenSendStr3(_mode, _aStr, &_down, &_up, &_status)
		_vOut                 := _down
		kup_save[_MojiOnHold] := _up
	} else {
		g_LastKey["表層"] := kLabel.Has(_mode . _MojiOnHold) ? kLabel[_mode . _MojiOnHold] : ""
	}
	SubSend(_vOut)
}

;----------------------------------------------------------------------
; 親指シフトと同時打鍵の零遅延モードの先行出力
;----------------------------------------------------------------------
SendZeroDelayOM()
{
	global
	local _cntM

	_cntM := countMoji()
	if(_cntM >= 1) {
		meta1 := g_MetaOnHold.Has(1) ? g_MetaOnHold[1] : ""
		meta2 := g_MetaOnHold.Has(2) ? g_MetaOnHold[2] : ""
		if(RegExMatch(meta1, "^[RLABCD]$") && meta2 == "M")
		{
			SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[2], g_ZeroDelay)
		} else if(meta1 == "M") {
			SendZeroDelay(g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1], g_MojiOnHold[1], g_ZeroDelay)
		}
	}
}

;----------------------------------------------------------------------
; 親指シフトと同時打鍵の零遅延モードの先行出力
;----------------------------------------------------------------------
SendZeroDelay(_mode, _MojiOnHold, _ZeroDelay)
{
	global
	local _MojiOnHoldLast, _nextKey, _aStr, _vOut

	if(_ZeroDelay == 1)
	{
		g_KeyOnHold := GetPushedKeys()
		_MojiOnHoldLast := SubStr(_MojiOnHold, StrLen(_MojiOnHold)-2)
		
		chkKeyA := _mode . g_KeyOnHold . _MojiOnHold
		if(StrLen(_MojiOnHold) == 3 && StrLen(g_KeyOnHold) == 6 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "") {
			_MojiOnHold := g_KeyOnHold . _MojiOnHold
		} else if(StrLen(_MojiOnHold) == 3 && StrLen(g_KeyOnHold) == 3 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "") {
			_MojiOnHold := g_KeyOnHold . _MojiOnHold
		} else if(StrLen(_MojiOnHold) == 6 && StrLen(g_KeyOnHold) == 3 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "") {
			_MojiOnHold := g_KeyOnHold . _MojiOnHold
		}
		
		g_ZeroDelaySurface := kLabel.Has(_mode . _MojiOnHold) ? kLabel[_mode . _MojiOnHold] : ""
		
		; 保留キーがあれば先行出力（零遅延モード）
		if((!kst.Has(_mode . _MojiOnHoldLast) || kst[_mode . _MojiOnHoldLast] == "")
		&& StrLen(g_ZeroDelaySurface) == 1 && (!ctrlKeyHash.Has(g_ZeroDelaySurface) || ctrlKeyHash[g_ZeroDelaySurface] == "")) {
			_vOut := kdn.Has(_mode . _MojiOnHold) ? kdn[_mode . _MojiOnHold] : ""
			kup_save[_MojiOnHoldLast] := kup.Has(_mode . _MojiOnHold) ? kup[_mode . _MojiOnHold] : ""
			
			_nextKey := nextDakuten(_mode, _MojiOnHold)
			if(_nextKey != "") {
				_aStr := "後" . _nextKey
				GenSendStr3(_mode, _aStr, &_down, &_up, &_status)
				_vOut                 := _down
				kup_save[_MojiOnHold] := _up
			}
			g_ZeroDelayOut := _vOut
			SubSend(_vOut)
		} else {
			g_ZeroDelaySurface := ""
		}
	}
	else
	{
		g_ZeroDelaySurface := ""
		g_ZeroDelayOut := ""
	}
}

;----------------------------------------------------------------------
; タイムアウト時間を設定
;----------------------------------------------------------------------
SetTimeout(_KeyInPtn)
{
	global
	local _mode, _Timeout

	_mode := g_RomajiOnHold[1] . g_OyaOnHold[1] . g_KoyubiOnHold[1]	
	
	if(_KeyInPtn == "") {
		_Timeout := 60000
	} else if(_KeyInPtn == "M") {
		if(g_OnHoldIdx == 0) {
			_Timeout := Min(Floor((g_Threshold * (100 - g_OverlapMO)) / g_OverlapMO), g_MaxTimeout)
		} else if(ksc.Has(_mode . g_MojiOnHold[g_OnHoldIdx]) && ksc[_mode . g_MojiOnHold[g_OnHoldIdx]] <= 1) {
			_Timeout := Min(Floor((g_Threshold * (100 - g_OverlapMO)) / g_OverlapMO), g_MaxTimeout)
			if(g_SimulMode.Count != 0) {
				_Timeout := Max(_Timeout, Min(Floor((g_ThresholdSS * (100 - g_OverlapSS)) / g_OverlapSS), g_MaxTimeout))
			}
		} else {
			_Timeout := 60000
		}
	} else if(_KeyInPtn == "MM") {
		if(g_OnHoldIdx <= 1) {
			_Timeout := Max(g_ThresholdSS, g_Threshold)
		} else {
			chkKey := _mode . g_MojiOnHold[g_OnHoldIdx] . g_MojiOnHold[g_OnHoldIdx - 1]
			if(ksc.Has(chkKey) && ksc[chkKey] <= 2) {
				_Timeout := Max(g_ThresholdSS, g_Threshold)
			} else {
				_Timeout := 60000
			}
		}
	} else if(_KeyInPtn == "MMm") {
		g_Interval["S12"]  := g_TDownOnHold[2] - g_TDownOnHold[1]
		g_Interval["S2_1"] := g_TUpOnHold[1] - g_TDownOnHold[2]
		_Timeout := Min(Floor((g_Interval["S2_1"] * (100 - g_OverlapSS)) / g_OverlapSS) - g_Interval["S12"], g_MaxTimeout)
	} else if(_KeyInPtn == "MMM") {
		_Timeout := 0
	} else if(RegExMatch(_KeyInPtn, "^[RLABCD]$")) {
		_Timeout := 60000
	} else if(RegExMatch(_KeyInPtn, "^[RLABCD]M$")) {
		if(g_OnHoldIdx == 2) {
			g_Interval[State.Oya . "M"] := g_TDownOnHold[g_OnHoldIdx] - g_OyaTick[State.Oya]
			_Timeout := Min(Floor(g_Interval[State.Oya . "M"] * g_OverlapOM / (100 - g_OverlapOM)), g_MaxTimeout)
		} else {
			_Timeout := Min(g_Threshold, g_MaxTimeout)
		}
	} else if(RegExMatch(_KeyInPtn, "^[RLABCD]M[RLABCD]$")) {
		g_Interval["M" . State.Oya] := g_OyaTick[State.Oya] - g_TDownOnHold[g_OnHoldIdx-1]
		_Timeout := Min(Floor(g_Interval["M" . State.Oya] * g_OverlapMO / (100 - g_OverlapMO)), g_MaxTimeout)
	} else if(RegExMatch(_KeyInPtn, "^M[RLABCD]$")) {
		g_Interval["M" . State.Oya] := g_OyaTick[State.Oya] - g_TDownOnHold[g_OnHoldIdx-1]
		_Timeout := Min(Floor(g_Interval["M" . State.Oya] * g_OverlapMO / (100 - g_OverlapMO)), g_MaxTimeout)
	} else if(RegExMatch(_KeyInPtn, "^[RLABCD]M[rlabcd]$")) {
		wOya := g_OyaOnHold[g_OnHoldIdx]
		g_Interval["M_" . wOya] := g_TDownOnHold[g_OnHoldIdx-1] - g_TUpOnHold[g_OnHoldIdx]
		_Timeout := Min(Floor((g_Interval["M_" . wOya] * (100 - g_OverlapOMO)) / g_OverlapOMO), g_MaxTimeout)
	} else if(RegExMatch(_KeyInPtn, "^[RLABCD]M[RLABCD][rlabcd]$")) {
		wOya := g_OyaOnHold[g_OnHoldIdx-1]
		g_Interval[wOya] := g_TDownOnHold[g_OnHoldIdx-1] - g_TUpOnHold[g_OnHoldIdx]
		_Timeout := Min(Floor((g_Interval[wOya] * (100 - g_OverlapOMO)) / g_OverlapOMO), g_MaxTimeout)
	} else {
		_Timeout := 60000
	}
	return _Timeout
}

;----------------------------------------------------------------------
; タイムアウト時間を設定
;----------------------------------------------------------------------
calcSendTick(_currentTick, _Timeout)
{
	if(_Timeout >= 60000) {
		return 2147483648 ; INFINITE の代わり
	} else {
		return _currentTick + _Timeout
	}
}

;----------------------------------------------------------------------
; 連続打鍵の判定
;----------------------------------------------------------------------
JudgePushedKeys(_mode, _MojiOnHold)
{
	global
	local _KeyInPtn := ""
	g_KeyOnHold := GetPushedKeys()
	chkKeyA := _mode . g_KeyOnHold . _MojiOnHold
	
	cond1 := (StrLen(g_KeyOnHold) == 6 && StrLen(_MojiOnHold) == 3 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "")
	cond2 := (StrLen(g_KeyOnHold) == 3 && StrLen(_MojiOnHold) == 3 && ksc.Has(_mode . _MojiOnHold) && ksc[_mode . _MojiOnHold] == 2 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "")
	cond3 := (StrLen(g_KeyOnHold) == 3 && StrLen(_MojiOnHold) == 6 && kdn.Has(chkKeyA) && kdn[chkKeyA] != "")
	
	if(cond1 || cond2 || cond3) {
		SendOnHold(_mode, g_KeyOnHold . _MojiOnHold, g_ZeroDelay)
		_KeyInPtn := clearQueue()
		State.Timeout := 60000
		State.SendTick := 2147483648 ; INFINITE
	}
	return _KeyInPtn
}

;-----------------------------------------------------------------------
; 押下キー取得
;-----------------------------------------------------------------------
GetPushedKeys()
{
	global
	local _pushedKeys := "", _cont

	for index, element in layoutArys
	{
		if(keyState.Has(element) && keyState[element] == 1) {
			kName := keyNameHash.Has(element) ? keyNameHash[element] : ""
			if(kName != "" && GetKeyState(kName, "P") == 0) {
				keyState[element] := 0
			} else {
				_cont := g_colPushedHash[SubStr(element, 1, 1)] . SubStr(element, 2, 2)
				_pushedKeys .= _cont
			}
		}
	}
	return _pushedKeys
}

;----------------------------------------------------------------------
; 濁点・半濁点の処理
;----------------------------------------------------------------------
nextDakuten(_mode, _MojiOnHold)
{
    global kLabel, DakuonSurfaceHash, HandakuonSurfaceHash, YouonSurfaceHash, CorrectSurfaceHash, g_LastKey
    local _nextKey := ""
    
    lbl := kLabel.Has(_mode . _MojiOnHold) ? kLabel[_mode . _MojiOnHold] : ""
    lastKey := g_LastKey.Has("表層") ? g_LastKey["表層"] : ""
    
    if (lbl == "゛" || lbl == "濁") {
        _nextKey := DakuonSurfaceHash.Has(lastKey) ? DakuonSurfaceHash[lastKey] : ""
    } else if (lbl == "゜" || lbl == "半") {
        _nextKey := HandakuonSurfaceHash.Has(lastKey) ? HandakuonSurfaceHash[lastKey] : ""
    } else if (lbl == "拗") {
        _nextKey := YouonSurfaceHash.Has(lastKey) ? YouonSurfaceHash[lastKey] : ""
    } else if (lbl == "修") {
        _nextKey := CorrectSurfaceHash.Has(lastKey) ? CorrectSurfaceHash[lastKey] : ""
    }
    return _nextKey
}
