;-----------------------------------------------------------------------
;	名称：ReadLayout6.ahk (AHK v2版)
;	機能：紅皿のキーレイアウトファイルの読み込み
;	ver.0.2.0.0.... 2026/3/28 (v2 modified)
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
ReadLayout()
{
	global
	
	g_colhash := Map()
	g_colhash[1] := "E"
	g_colhash[2] := "D"
	g_colhash[3] := "C"
	g_colhash[4] := "B"
	g_colhash[5] := "A"

	; キーオンを押されているキーのインデックスに変換
	g_colPushedHash := Map()
	g_colPushedHash["E"] := "5"
	g_colPushedHash["D"] := "4"
	g_colPushedHash["C"] := "3"
	g_colPushedHash["B"] := "2"
	g_colPushedHash["A"] := "1"

	g_rowhash := Map()
	g_rowhash[0] := "00"
	g_rowhash[1] := "01"
	g_rowhash[2] := "02"
	g_rowhash[3] := "03"
	g_rowhash[4] := "04"
	g_rowhash[5] := "05"
	g_rowhash[6] := "06"
	g_rowhash[7] := "07"
	g_rowhash[8] := "08"
	g_rowhash[9] := "09"
	g_rowhash[10]:= "10"
	g_rowhash[11]:= "11"
	g_rowhash[12]:= "12"
	g_rowhash[13]:= "13"
	g_rowhash[14]:= "14"
	g_rowhash[15]:= "15"
	g_rowhash[16]:= "16"
	g_rowhash[17]:= "17"
	g_rowhash[18]:= "18"
	g_rowhash[19]:= "19"
	g_rowhash[20]:= "20"
	
	layoutAry := "E01,E02,E03,E04,E05,E06,E07,E08,E09,E10,E11,E12,E13,E14"
	layoutAry .= ",D01,D02,D03,D04,D05,D06,D07,D08,D09,D10,D11,D12"
	layoutAry .= ",C01,C02,C03,C04,C05,C06,C07,C08,C09,C10,C11,C12"
	layoutAry .= ",B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11"
	layoutArys := StrSplit(layoutAry, ",")

	g_idx2Color := "FFC3E1,FFFFC3,FFFFC3,C3FFC3,C3FFC3,C3FFFF,C3FFFF,E1C3FF,E1C3FF,C0C0C0,C0C0C0,C0C0C0,C0C0C0,C0C0C0"
	g_idx2Color .= ",FFC3E1,FFFFC3,FFFFC3,C3FFC3,C3FFC3,C3FFFF,C3FFFF,E1C3FF,E1C3FF,C0C0C0,C0C0C0,C0C0C0"
	g_idx2Color .= ",FFC3E1,FFFFC3,FFFFC3,C3FFC3,C3FFC3,C3FFFF,C3FFFF,E1C3FF,E1C3FF,C0C0C0,C0C0C0,C0C0C0"
	g_idx2Color .= ",FFC3E1,FFFFC3,FFFFC3,C3FFC3,C3FFC3,C3FFFF,C3FFFF,E1C3FF,E1C3FF,C0C0C0,C0C0C0"
	g_idx2Colors := StrSplit(g_idx2Color, ",")
	
	g_pos2Colors := Map()
	g_keyState := Map()
	for index, element in layoutArys
	{
		g_pos2Colors[element] := g_idx2Colors[index]
		g_keyState[element] := 0
	}

	InitLayout2()
	g_error := ""
	ReadLayoutFile(g_LayoutFile)
	if(g_error != "")
	{
		MsgBox(g_error)
		LFA := ""
		LFN := ""
	}
	SetLayoutProperty()
}

; 各テーブルを読み込んだか否かの判定変数の初期化とデフォルトテーブル
InitLayout2()
{
	global
	
	kst := Map()	; キーの状態
	ksc := Map()	; 最大同時打鍵個数
	kup := Map()	; keyup したときの Send形式
	kdn := Map()	; keydown したときの Send形式
	
	DakuonSurfaceHash := MakeDakuonSurfaceHash()	; 濁音
	HandakuonSurfaceHash := MakeHanDakuonSurfaceHash()	; 半濁音
	YouonSurfaceHash := MakeYouonSurfaceHash()	; 拗音
	CorrectSurfaceHash := MakeCorrectSurfaceHash()	; 修正
	g_sansPos := ""

	g_Oya2Layout := Map()
	g_Oya2Layout["L"] := "A01"
	g_Oya2Layout["R"] := "A03"
	g_Oya2Layout["A"] := ""
	g_Oya2Layout["B"] := ""
	g_Oya2Layout["C"] := ""
	g_Oya2Layout["D"] := ""

	g_Oya2kName := Map()		; 機能キー名から親指コードへの変換
	g_Oya2kName["L"] := "無変換"
	g_Oya2kName["R"] := "変換"
	g_Oya2kName["A"] := "拡張1"
	g_Oya2kName["B"] := "拡張2"
	g_Oya2kName["C"] := "拡張3"
	g_Oya2kName["D"] := "拡張4"
	
	g_OyaName2Cd := Map()	; 機能キー名から親指コードへの変換
	g_OyaName2Cd["拡張1"] := "A"
	g_OyaName2Cd["拡張2"] := "B"
	g_OyaName2Cd["拡張3"] := "C"
	g_OyaName2Cd["拡張4"] := "D"

	g_oyakeyPos := Map()
	g_oyakeyPos["無変換"] := "A01"
	g_oyakeyPos["Space"]  := "A02"	;スペース
	g_oyakeyPos["変換"]   := "A03"

	roma3hash := MakeRoma3Hash()
	kanaInhash := MakeKanaInHash()
	layout2Hash := MakeLayout2Hash()
	z2hHash := MakeZ2hHash()
	keyNameHash := MakeKeyNameHash()
	vkeyHash := MakeVkeyHash(keyNameHash)
	vkeyStrHash := MakeVkeyStrHash(keyNameHash)
	ScanCodeHash := MakeScanCodeHash(keyNameHash)

	layoutPosHash := MakeLayoutPosHash(ScanCodeHash)
	fkeyPosHash := MakefkeyPosHash()	; 修飾キー読取用

	fkey2NameHash := Makefkey2NameHash()
	fkeyCodeHash := MakefkeyCodeHash(fkey2NameHash)
	fkeyVkeyHash := MakefkeyVkeyHash(fkey2NameHash)
	
	romaji2SurfaceHash := MakeRomaji2SurfaceHash()
	code2SimulPos := MakeCode2SimulPos()
	code2ContPos := MakeCode2ContPos()
	ctrlKeyHash := MakeCtrlKeyHash()
	ctrlvKeyHash := MakeCtrlvKeyHash()
	CtrlScHash := MakeCtrlScHash()
	modifierHash := MakeModifierHash()

	keyAttribute3 := MakeKeyAttribute3Hash()
	keyHook := MakeKeyHookHash()
	keyState := MakeKeyState()
	kLabel := MakeKeyLabelHash()
	tenkeyHash := MakeTenkeyHash()
	
	g_SimulMode := Map()

	g_layoutName := ""
	g_layoutVersion := ""
	g_layoutURL := ""

	LF := Map()
	; デフォルトテーブル
	LF["A_NE"] := "１,２,３,４,５,６,７,８,９,０,－,＾,￥,後"
	LF["A_ND"] := "ｑ,ｗ,ｅ,ｒ,ｔ,ｙ,ｕ,ｉ,ｏ,ｐ,＠,［"
	LF["A_NC"] := "ａ,ｓ,ｄ,ｆ,ｇ,ｈ,ｊ,ｋ,ｌ,；,：,］"
	LF["A_NB"] := "ｚ,ｘ,ｃ,ｖ,ｂ,ｎ,ｍ,，,．,／,￥"
	LF["A_NA"] := "換,空,変,日"
	SetkLabel("ANN","A_N")

	LF["A_KE"] := "！,”,＃,＄,％,＆,’, （,）,無,＝,～,｜,後"
	LF["A_KD"] := "Ｑ,Ｗ,Ｅ,Ｒ,Ｔ,Ｙ,Ｕ,Ｉ,Ｏ,Ｐ,‘,｛"
	LF["A_KC"] := "Ａ,Ｓ,Ｄ,Ｆ,Ｇ,Ｈ,Ｊ,Ｋ,Ｌ,＋,＊,｝"
	LF["A_KB"] := "Ｚ,Ｘ,Ｃ,Ｖ,Ｂ,Ｎ,Ｍ,＜,＞,？,＿"
	LF["A_KA"] := "換,空,変,日"
	SetkLabel("ANK","A_K")
	; NULLテーブル
	LF["NUL"] := "NULL"
	LF["NULE"] := "　,　,　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULD"] := "　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULC"] := "　,　,　,　,　,　,　,　,　,　,　,　"
	LF["NULB"] := "　,　,　,　,　,　,　,　,　,　,　"
	LF["NULA"] := "換,空,変,日"

	g_modeName := "[英数シフト無し]" 
	g_mode := layout2Hash[g_modeName]
	CopyColumns("A_N",g_mode)
	LF[g_mode] := g_modeName
	fMode2Key(g_mode,g_modeName)		; 親指シフトレイアウトの処理
	
	g_modeName := "[英数小指シフト]"
	g_mode := layout2Hash[g_modeName]
	CopyColumns("A_K",g_mode)
	LF[g_mode] := g_modeName
	fMode2Key(g_mode,g_modeName)		; 親指シフトレイアウトの処理

	g_modeName := "[ローマ字シフト無し]" 
	g_mode := layout2Hash[g_modeName]
	CopyColumns("A_N",g_mode)
	LF[g_mode] := g_modeName
	fMode2Key(g_mode,g_modeName)		; 親指シフトレイアウトの処理

	g_modeName := "[ローマ字小指シフト]" 
	g_mode := layout2Hash[g_modeName]
	CopyColumns("A_K",g_mode)
	LF[g_mode] := g_modeName
	fMode2Key(g_mode,g_modeName)		; 親指シフトレイアウトの処理
}

;----------------------------------------------------------------------
; 各モードのレイアウトを処理
;----------------------------------------------------------------------
SetkLabel(_modeDst, _modeSrc)
{
	global
	local _col, _keyArray

	_col := "E"
	_keyArray := StrSplit(LF.Has(_modeSrc . "E") ? LF[_modeSrc . "E"] : "", ",")
	Loop _keyArray.Length
	{
		kLabel[_modeDst . _col . g_rowhash[A_Index]] := _keyArray[A_Index]
	}
	_col := "D"
	_keyArray := StrSplit(LF.Has(_modeSrc . "D") ? LF[_modeSrc . "D"] : "", ",")
	Loop _keyArray.Length
	{
		kLabel[_modeDst . _col . g_rowhash[A_Index]] := _keyArray[A_Index]
	}
	_col := "C"
	_keyArray := StrSplit(LF.Has(_modeSrc . "C") ? LF[_modeSrc . "C"] : "", ",")
	Loop _keyArray.Length
	{
		kLabel[_modeDst . _col . g_rowhash[A_Index]] := _keyArray[A_Index]
	}
	_col := "B"
	_keyArray := StrSplit(LF.Has(_modeSrc . "B") ? LF[_modeSrc . "B"] : "", ",")
	Loop _keyArray.Length
	{
		kLabel[_modeDst . _col . g_rowhash[A_Index]] := _keyArray[A_Index]
	}
}

;----------------------------------------------------------------------
; キー配列ファイル読み込み
;----------------------------------------------------------------------
ReadLayoutFile(_LayoutFile)
{
	global

	SetWorkingDir(g_DataDir)
	if(!Path_FileExists(_LayoutFile))
	{
		g_error := "ファイルが存在しません " . _LayoutFile
		return
	}
	g_mode := ""
	g_modeName := ""
	g_Section := ""
	_spos := ""
	_mline := 0
	_mline2 := 0
	g_error := ""
	_lineCtr := 0
	g_layoutName := ""
	g_layoutVersion := ""
	g_layoutURL := ""
	g_keySequence := []
	
	_fileObj := FileOpen(_LayoutFile, "r")
	if(!_fileObj) {
		g_error := "ファイルが開けません " . _LayoutFile
		return
	}
	Loop
	{
		_lineCtr += 1
		if(_fileObj.AtEOF) {
			break
		}
		_line := _fileObj.ReadLine()
		; コメント部分の除去
	    cpos := InStr(_line, ";")
    	if(cpos == 1)
    	{
			_line2 := ""
		} else {
	    	_line2 := Trim(_line)
		    cpos := InStr(_line2, Chr(10))
		    if(cpos > 0) {
		    	_line2 := SubStr(_line2, 1, cpos-1)
		    }
		    cpos := InStr(_line2, Chr(13))
		    if(cpos > 0) {
		    	_line2 := SubStr(_line2, 1, cpos-1)
		    }
	    }
	    if(_line2 != "")
		{
			if(SubStr(_line2, 1, 1) == "[" && SubStr(_line2, StrLen(_line2), 1) == "]") {
				g_Section := _line2
			}
			if(layout2Hash.Has(_line2) && layout2Hash[_line2] != "") {
				g_mode := layout2Hash[_line2]
				_spos := ""
				if(g_mode != "")
				{
					g_modeSave := g_mode
					g_modeName := _line2
					_mline := 1
					_mline2 := 0
					CopyColumns("NUL", g_mode)
				}
				continue
			}
			if(g_mode != "") 
			{
				if(1 <= _mline && _mline <= 4)
				{
					LF[g_mode . g_colhash[_mline]] := _line2
					if(_mline == 4) {
						g_error := fMode2Key(g_mode, g_modeName)		; 親指シフトレイアウトの処理
						if(g_error != "")
						{
							g_error := _LayoutFile . ":" . g_modeName . ":" . g_error

							g_Section := ""
							g_mode := ""
							g_modeName := ""
							_spos := ""
							_mline2 := 0
							_mline := 0
							_fileObj.Close()
							return
						}
					}
					_spos := ""
					g_keySequence := []
					_mline2 := 0
					_mline  += 1
				}
				else if(_mline == 5) {
					if(_mline2 == 0) {
						g_keySequence := StrSplit(_line2, " ")
						if (CheckKeySequence(g_keySequence))
						{
							_mline2 := 1
							continue
						}
					}
					if(g_keySequence.Length != 0 && (1 <= _mline2 && _mline2 <= 4)) {
						Loop g_keySequence.Length
						{
							_spos := ParseSimulPos(g_keySequence[A_Index])		; 同時打鍵パターンがあるか
							if(_spos != "") {
								LF[g_mode . _spos . g_colhash[_mline2]] := _line2
							}
							_cpos := ParseContPos(g_keySequence[A_Index])		; 連続打鍵パターンがあるか
							if(_cpos != "") {
								LF[g_mode . _cpos . g_colhash[_mline2]] := _line2
							}
						}
						if(_mline2 == 4) {
							Loop g_keySequence.Length
							{
								_simulKeyStroke := g_keySequence[A_Index]
								_spos := ParseSimulPos(_simulKeyStroke)		; 同時打鍵パターンがあるか
								g_error := fMode3Key(g_mode, _spos, _simulKeyStroke)	; 同時打鍵レイアウトの処理
								if(g_error != "")
								{
									g_error := _LayoutFile . ":" . g_modeName . ":" . g_error
									g_Section := ""
									g_mode := ""
									g_keySequence := []
									_mline2 := 0
									_fileObj.Close()
									return
								}
								_simulKeyStroke := g_keySequence[A_Index]
								_spos := ParseContPos(_simulKeyStroke)	; 連続打鍵パターンがあるか
								g_error := fMode3Key(g_mode, _spos, _simulKeyStroke)	; 同時打鍵レイアウトの処理
								if(g_error != "")
								{
									g_error := _LayoutFile . ":" . g_modeName . ":" . g_error
									g_Section := ""
									g_mode := ""
									g_keySequence := []
									_mline2 := 0
									_fileObj.Close()
									return
								}
							}
							g_keySequence := []
							_spos := ""
							_mline2 := 0
						} else {
							_mline2 += 1
						}
						continue
					} else {
						_mline2 := 0
					}
					continue
				}
			}

			if(g_Section == "[配列]")
			{
				cpos2 := InStr(_line2, "=")
				_element := StrSplit(_line2, "=")
				if(_element.Length == 2)
				{
					if(_element[1] == "名称")
					{
						g_layoutName := _element[2]
					}
					else if(_element[1] == "バージョン")
					{
						g_layoutVersion := _element[2]
					}
					else if(_element[1] == "URL")
					{
						g_layoutURL := _element[2]
					}
					else if(_element[1] == "キーリピート")
					{
						if(_element[2] > g_MaxTimeout)
						{
							g_MaxTimeoutM := _element[2]
						}
					}
				}
				continue
			}
			else if(g_Section == "[機能キー]")
			{
				cpos2 := InStr(_line2, ",")
				_element := StrSplit(_line2, ",")
				if(_element.Length == 2)
				{
					_element[1] := Trim(_element[1])
					_element[2] := Trim(_element[2])
					s_layoutPosDst := fkeyPosHash.Has(_element[1]) ? fkeyPosHash[_element[1]] : ""
					s_layoutPosSrc := fkeyPosHash.Has(_element[2]) ? fkeyPosHash[_element[2]] : ""
					if(s_layoutPosDst == "") 
					{
						MsgBox("機能キー名が存在しません:" . _element[1])
					}
					if(s_layoutPosSrc == "") 
					{
						MsgBox("機能キー名が存在しません:" . _element[2])
					}
					if(s_layoutPosDst != "" && s_layoutPosSrc != "") 
					{
						keyNameHash[s_layoutPosDst] := fkeyCodeHash.Has(_element[2]) ? fkeyCodeHash[_element[2]] : ""
						if(g_oyakeyPos.Has(_element[2]) && g_oyakeyPos[_element[2]] != "")
						{
							g_oyakeyPos[_element[2]] := s_layoutPosDst
						}
						kLabel[s_layoutPosDst] := _element[2]
						keyAttribute3["AN" . s_layoutPosDst] := "X"
						keyAttribute3["AK" . s_layoutPosDst] := "X"
						keyAttribute3["AS" . s_layoutPosDst] := "X"
						keyAttribute3["RN" . s_layoutPosDst] := "X"
						keyAttribute3["RK" . s_layoutPosDst] := "X"
						keyAttribute3["RS" . s_layoutPosDst] := "X"
						
						if(_element[2] == "Space&Shift") {
							g_sansPos := s_layoutPosDst
						} else {
							_oyaCode := g_OyaName2Cd.Has(_element[2]) ? g_OyaName2Cd[_element[2]] : ""
							if(_oyaCode != "") {	; 拡張1～拡張4
								g_Oya2Layout[_oyaCode] := s_layoutPosDst
								keyAttribute3["AN" . s_layoutPosDst] := _oyaCode
								keyAttribute3["AK" . s_layoutPosDst] := _oyaCode
								keyAttribute3["AS" . s_layoutPosDst] := _oyaCode
								keyAttribute3["RN" . s_layoutPosDst] := _oyaCode
								keyAttribute3["RK" . s_layoutPosDst] := _oyaCode
								keyAttribute3["RS" . s_layoutPosDst] := _oyaCode
							}
						}
					}
				}
			}
		}
	}
	_fileObj.Close()
}

;----------------------------------------------------------------------
;	キーシーケンスのチェック
; <?> または {?} の形式であるか否かをチェック
;----------------------------------------------------------------------
CheckKeySequence(g_KeySequence)
{
	local _keyStroke
	
	Loop g_keySequence.Length
	{
		_keyStroke := g_keySequence[A_Index]
		if (StrLen(_keyStroke) == 3
		&& ((SubStr(_keyStroke, 1, 1) == "<" && SubStr(_keyStroke, 3, 1) == ">")
		|| (SubStr(_keyStroke, 1, 1) == "{" && SubStr(_keyStroke, 3, 1) == "}"))) {
		
		} else if (StrLen(_keyStroke) == 6
		&& ((SubStr(_keyStroke, 1, 1) == "<" && SubStr(_keyStroke, 3, 1) == ">")
		|| (SubStr(_keyStroke, 1, 1) == "{" && SubStr(_keyStroke, 3, 1) == "}"))
		&& ((SubStr(_keyStroke, 4, 1) == "<" && SubStr(_keyStroke, 6, 1) == ">")
		|| (SubStr(_keyStroke, 4, 1) == "{" && SubStr(_keyStroke, 6, 1) == "}"))) {

		} else if (StrLen(_keyStroke) == 9
		&& ((SubStr(_keyStroke, 1, 1) == "<" && SubStr(_keyStroke, 3, 1) == ">")
		|| (SubStr(_keyStroke, 1, 1) == "{" && SubStr(_keyStroke, 3, 1) == "}"))
		&& ((SubStr(_keyStroke, 4, 1) == "<" && SubStr(_keyStroke, 6, 1) == ">")
		|| (SubStr(_keyStroke, 4, 1) == "{" && SubStr(_keyStroke, 6, 1) == "}"))
		&& ((SubStr(_keyStroke, 7, 1) == "<" && SubStr(_keyStroke, 9, 1) == ">")
		|| (SubStr(_keyStroke, 7, 1) == "{" && SubStr(_keyStroke, 9, 1) == "}"))) {
		
		} else {
			return false
		}
	}
	return true
}

;----------------------------------------------------------------------
;	同時打鍵パターンのキー指定を解釈
;----------------------------------------------------------------------
ParseSimulPos(_key)
{
	global
	local _spos := ""
	if(StrLen(_key) >= 3 && SubStr(_key, 2, 1) != "*")
	{
		k := SubStr(_key, 1, 3)
		_spos .= code2SimulPos.Has(k) ? code2SimulPos[k] : ""
	}
	if(StrLen(_key) >= 6 && SubStr(_key, 5, 1) != "*")
	{
		k := SubStr(_key, 4, 3)
		_spos .= code2SimulPos.Has(k) ? code2SimulPos[k] : ""
	}
	if(StrLen(_key) >= 9 && SubStr(_key, 8, 1) != "*")
	{
		k := SubStr(_key, 7, 3)
		_spos .= code2SimulPos.Has(k) ? code2SimulPos[k] : ""
	}
	return _spos
}

;----------------------------------------------------------------------
; 連続打鍵パターンの指定を解釈
;----------------------------------------------------------------------
ParseContPos(_key)
{
	global
	local _cpos := ""
	if(StrLen(_key) >= 3 && SubStr(_key, 2, 1) != "*")
	{
		k := SubStr(_key, 1, 3)
		_cpos .= code2ContPos.Has(k) ? code2ContPos[k] : ""
	}
	if(StrLen(_key) >= 6 && SubStr(_key, 5, 1) != "*")
	{
		k := SubStr(_key, 4, 3)
		_cpos .= code2ContPos.Has(k) ? code2ContPos[k] : ""
	}
	if(StrLen(_key) >= 9 && SubStr(_key, 8, 1) != "*")
	{
		k := SubStr(_key, 7, 3)
		_cpos .= code2ContPos.Has(k) ? code2ContPos[k] : ""
	}
	return _cpos
}

;----------------------------------------------------------------------
; 文字同時打鍵のテーブル指定を解釈
;----------------------------------------------------------------------
ParseTableMode(_line)
{
	if(StrLen(_line) >= 3 && (SubStr(_line, 1, 3) == "<*>" || SubStr(_line, 1, 3) == "{*}"))
	{
		return SubStr(_line, 1, 3)
	}
	if(StrLen(_line) >= 6 && (SubStr(_line, 4, 3) == "<*>" || SubStr(_line, 4, 3) == "{*}"))
	{
		return SubStr(_line, 4, 3)
	}
	if(StrLen(_line) >= 9 && (SubStr(_line, 7, 3) == "<*>" || SubStr(_line, 7, 3) == "{*}"))
	{
		return SubStr(_line, 7, 3)
	}
	return "<*>"
}

;----------------------------------------------------------------------
; 各モードのレイアウトを処理
;----------------------------------------------------------------------
fMode2Key(_mode, _modeName)
{
	global
	local _col, _keyArray
	
	g_error := ""
	LF[_mode] := _modeName
	_col := "E"
	_keyArray := SplitColumn(LF.Has(_mode . "E") ? LF[_mode . "E"] : "")
	if(_keyArray.Length < 13 || _keyArray.Length > 14)
	{
		g_error := g_Section . "のE段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	if(_keyArray.Length == 13) {
		keyAttribute3[SubStr(_mode, 1, 1) . SubStr(_mode, 3, 1) . "E14"] := "X"
		_keyArray.Push("後")
	}
	g_error := fSetKeyTable(_keyArray, _mode, _col)
	if(g_error != "") 
		return g_error
	
	_col := "D"
	_keyArray := SplitColumn(LF.Has(_mode . "D") ? LF[_mode . "D"] : "")
	if(_keyArray.Length != 12)
	{
		g_error := g_Section . "のD段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	g_error := fSetKeyTable(_keyArray, _mode, _col)
	if(g_error != "")
		return g_error
	
	_col := "C"
	_keyArray := SplitColumn(LF.Has(_mode . "C") ? LF[_mode . "C"] : "")
	if(_keyArray.Length != 12)
	{
		g_error := g_Section . "のC段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	g_error := fSetKeyTable(_keyArray, _mode, _col)
	if(g_error != "")
		return g_error

	_col := "B"
	_keyArray := SplitColumn(LF.Has(_mode . "B") ? LF[_mode . "B"] : "")
	if(_keyArray.Length != 11)
	{
		g_error := g_Section . "のB段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	g_error := fSetKeyTable(_keyArray, _mode, _col)
	if(g_error != "")
		return g_error
        
	_col := "A"
	_keyArray := SplitColumn(LF.Has(_mode . "A") ? LF[_mode . "A"] : "")
	g_error := fSetKeyTable(_keyArray, _mode, _col)
	if(g_error != "")
		return g_error
	return g_error
}

;----------------------------------------------------------------------
; カラム行をカンマで分割して配列に設定
;----------------------------------------------------------------------
SplitColumn(_lColumn) {
	global
	local _obj := []
	local _idx := 0, _cpos
	
	while(_lColumn != "") {
		_idx += 1
		_cl := SubStr(_lColumn, 1, 1)
		if (_cl == "'" || _cl == '"') {
			_cpos := 2
			_cpos := InStr(_lColumn, _cl, false, _cpos)
			if(_cpos != 0) {	; 対応する引用符があった
				_cpos := InStr(_lColumn, ",", false, _cpos + 1)
				if(_cpos != 0) {	; 次のカンマがあった
					_obj.Push(SubStr(_lColumn, 1, _cpos-1))
					_lColumn := SubStr(_lColumn, _cpos+1)
				} else {
					_obj.Push(_lColumn)
					_lColumn := ""
				}
			} else {
				_obj.Push(_lColumn)
				_lColumn := ""
			}
		} else {
			_cpos := InStr(_lColumn, ",")
			if(_cpos != 0) {	; 次のカンマがあった
				_obj.Push(SubStr(_lColumn, 1, _cpos-1))
				_lColumn := SubStr(_lColumn, _cpos+1)
			} else {
				_obj.Push(_lColumn)
				_lColumn := ""
			}
		}
	}
	return _obj
}

;----------------------------------------------------------------------
; 文字の同時打鍵のレイアウトを処理
;----------------------------------------------------------------------
fMode3Key(g_mode, _spos, _simulKeyStroke)
{
	global
	local _idx, _col, _keyArray, _lpos
	
	g_error := ""
	_idx := g_SimulMode.Count
	g_SimulMode[_idx + 1] := g_mode . _simulKeyStroke		; 同時打鍵テーブル

	_col := "E"
	_keyArray := SplitColumn(LF.Has(g_mode . _spos . "E") ? LF[g_mode . _spos . "E"] : "")
	if(_keyArray.Length < 13 || _keyArray.Length > 14)
	{
		g_error := _simulKeyStroke . "のE段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	if(_keyArray.Length == 13) {
		_keyArray.Push("無")
	}
	_lpos := Map()
	_lpos[1] := SubStr(_spos, 1, 3)
	if(StrLen(_spos) >= 6) {
		_lpos[2] := SubStr(_spos, 4, 3)
		fSetSimulKeyTable3(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	} else {
		fSetSimulKeyTable(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	}
	if(g_error != "")
		return g_error
	
	_col := "D"
	_keyArray := SplitColumn(LF.Has(g_mode . _spos . "D") ? LF[g_mode . _spos . "D"] : "")
	if(_keyArray.Length != 12)
	{
		g_error := _simulKeyStroke . "のD段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	_lpos := Map()
	_lpos[1] := SubStr(_spos, 1, 3)
	if(StrLen(_spos) >= 6) {
		_lpos[2] := SubStr(_spos, 4, 3)
		fSetSimulKeyTable3(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	} else {
		fSetSimulKeyTable(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	}
	if(g_error != "")
		return g_error
	
	_col := "C"
	_keyArray := SplitColumn(LF.Has(g_mode . _spos . "C") ? LF[g_mode . _spos . "C"] : "")
	if(_keyArray.Length != 12)
	{
		g_error := _simulKeyStroke . "のC段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	_lpos := Map()
	_lpos[1] := SubStr(_spos, 1, 3)
	if(StrLen(_spos) >= 6) {
		_lpos[2] := SubStr(_spos, 4, 3)
		fSetSimulKeyTable3(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	} else {
		fSetSimulKeyTable(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	}
	if(g_error != "")
		return g_error

	_col := "B"
	_keyArray := SplitColumn(LF.Has(g_mode . _spos . "B") ? LF[g_mode . _spos . "B"] : "")
	if(_keyArray.Length != 11)
	{
		g_error := _simulKeyStroke . "のB段目にエラーがあります。要素数が" . _keyArray.Length . "です。"
		return g_error
	}
	_lpos := Map()
	_lpos[1] := SubStr(_spos, 1, 3)
	if(StrLen(_spos) >= 6) {
		_lpos[2] := SubStr(_spos, 4, 3)
		fSetSimulKeyTable3(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	} else {
		fSetSimulKeyTable(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
	}
	return g_error
}

;----------------------------------------------------------------------
; レイアウトファイルの設定
;----------------------------------------------------------------------
SetLayoutProperty()
{
	global
	
	ShiftMode := Map()
	ShiftMode["A"] := ""
	if(LF.Has("ANN") && LF.Has("ALN") && LF.Has("ARN") && LF["ANN"] != "" && LF["ALN"] != "" && LF["ARN"] != "")
	{
		ShiftMode["A"] := "親指シフト"
		RemapOyaKey("A")
		
		if(LF.Has("ANK") && LF["ANK"] != "" && (!LF.Has("ALK") || LF["ALK"] == "")) {
			g_mode := "ALK"
			CopyColumns("ANK", "ALK")
			fSetE2AKeyTables(g_mode)
		}
		if(LF.Has("ANK") && LF["ANK"] != "" && (!LF.Has("ARK") || LF["ARK"] == "")) {
			g_mode := "ARK"
			CopyColumns("ANK", "ARK")
			fSetE2AKeyTables(g_mode)
		}
	} else if(LF.Has("ANN") && LF["ANN"] != "" && isPrefixShift("A"))
	{
		ShiftMode["A"] := "プレフィックスシフト"
	}
	else if(LF.Has("ANN") && LF["ANN"] != "" && listSimulMode("A") != "")
	{
		ShiftMode["A"] := "文字同時打鍵"
	}
	else if(LF.Has("ANN") && LF["ANN"] != "" && LF.Has("ANK") && LF["ANK"] != "")
	{
		ShiftMode["A"] := "小指シフト"
	}
	
	ShiftMode["R"] := ""
	if(LF.Has("RNN") && LF.Has("RRN") && LF.Has("RLN") && LF["RNN"] != "" && LF["RRN"] != "" && LF["RLN"] != "")
	{
		ShiftMode["R"] := "親指シフト"
		RemapOyaKey("R")

		if(LF.Has("RNK") && LF["RNK"] != "" && (!LF.Has("RLK") || LF["RLK"] == "")) {
			g_mode := "RLK"
			CopyColumns("RNK", "RLK")
			fSetE2AKeyTables(g_mode)
		}
		if(LF.Has("RNK") && LF["RNK"] != "" && (!LF.Has("RRK") || LF["RRK"] == "")) {
			g_mode := "RRK"
			CopyColumns("RNK", "RRK")
			fSetE2AKeyTables(g_mode)
		}
	} else if(LF.Has("RNN") && LF["RNN"] != "" && isPrefixShift("R"))
	{
		ShiftMode["R"] := "プレフィックスシフト"
	}
	else if(LF.Has("RNN") && LF["RNN"] != "" && listSimulMode("R") != "")
	{
		ShiftMode["R"] := "文字同時打鍵"
	}
	else if(LF.Has("RNN") && LF["RNN"] != "" && LF.Has("RNK") && LF["RNK"] != "")
	{
		ShiftMode["R"] := "小指シフト"
	}
	
	SetSansKey(g_sansPos)
	_oyacodes := "ABCD"
	Loop Parse, _oyacodes
	{
		if(g_Oya2Layout.Has(A_LoopField) && g_Oya2Layout[A_LoopField] != "")
		{
			if((!LF.Has("R" . A_LoopField . "N") || LF["R" . A_LoopField . "N"] == "")
			&& (!LF.Has("R" . A_LoopField . "K") || LF["R" . A_LoopField . "K"] == ""))
			{
				MsgBox("拡張配列が定義されていません。")
			}
			if(LF.Has("R" . A_LoopField . "N") && LF["R" . A_LoopField . "N"] != "")
			{
				g_mode := "RNN"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_N", g_mode)
					fSetE2AKeyTables(g_mode)
				}
				g_mode := "RNK"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_K", g_mode)
					fSetE2AKeyTables(g_mode)
				}
				g_mode := "A" . A_LoopField . "N"
				CopyColumns("R" . A_LoopField . "N", g_mode)
				fSetE2AKeyTables(g_mode)
				
				g_mode := "ANN"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_N", g_mode)
					fSetE2AKeyTables(g_mode)
				}
				g_mode := "ANK"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_K", g_mode)
					fSetE2AKeyTables(g_mode)
				}
			}
			if(LF.Has("R" . A_LoopField . "K") && LF["R" . A_LoopField . "K"] != "")
			{
				g_mode := "A" . A_LoopField . "K"
				CopyColumns("R" . A_LoopField . "K", g_mode)
				fSetE2AKeyTables(g_mode)

				g_mode := "ANN"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_N", g_mode)
					fSetE2AKeyTables(g_mode)
				}
				g_mode := "ANK"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_K", g_mode)
					fSetE2AKeyTables(g_mode)
				}
				g_mode := "R" . A_LoopField . "K"
				CopyColumns("R" . A_LoopField . "K", g_mode)
				fSetE2AKeyTables(g_mode)

				g_mode := "RNN"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_N", g_mode)
					fSetE2AKeyTables(g_mode)
				}
				g_mode := "RNK"
				if(!LF.Has(g_mode) || LF[g_mode] == "")
				{
					LF[g_mode] := g_mode
					CopyColumns("A_K", g_mode)
					fSetE2AKeyTables(g_mode)
				}
			}
		}
	}
}

;----------------------------------------------------------------------
; プレフィックスシフト
;----------------------------------------------------------------------
isPrefixShift(_Romaji)
{
	global
	
	Loop 10
	{
		if(LF.Has(_Romaji . Mod(A_Index, 10) . "N") && LF[_Romaji . Mod(A_Index, 10) . "N"] != "") {
			return true
		}
		if(LF.Has(_Romaji . Mod(A_Index, 10) . "K") && LF[_Romaji . Mod(A_Index, 10) . "K"] != "") {
			return true
		}
	}
	return false
}

;----------------------------------------------------------------------
; E段からA段までカラム列からキー配列表を設定
;----------------------------------------------------------------------
fSetE2AKeyTables(g_mode)
{
	global
	local _col, _keyArray
	
	_col := "E"
	_keyArray := StrSplit(LF.Has(g_mode . "E") ? LF[g_mode . "E"] : "", ",")
	g_error := fSetKeyTable(_keyArray, g_mode, _col)
	if(g_error != "") 
		return g_error
	
	_col := "D"
	_keyArray := StrSplit(LF.Has(g_mode . "D") ? LF[g_mode . "D"] : "", ",")
	g_error := fSetKeyTable(_keyArray, g_mode, _col)
	if(g_error != "")
		return g_error
	
	_col := "C"
	_keyArray := StrSplit(LF.Has(g_mode . "C") ? LF[g_mode . "C"] : "", ",")
	g_error := fSetKeyTable(_keyArray, g_mode, _col)
	if(g_error != "") 
		return g_error
	
	_col := "B"
	_keyArray := StrSplit(LF.Has(g_mode . "B") ? LF[g_mode . "B"] : "", ",")
	g_error := fSetKeyTable(_keyArray, g_mode, _col)
	if(g_error != "") 
		return g_error
	
	_col := "A"
	_keyArray := StrSplit(LF.Has(g_mode . "A") ? LF[g_mode . "A"] : "", ",")
	g_error := fSetKeyTable(_keyArray, g_mode, _col)
	return g_error
}

;----------------------------------------------------------------------
; 親指キー設定をキー属性配列に反映させる
;----------------------------------------------------------------------
RemapOyaKey(_Romaji) {
	global

	keyAttribute3[_Romaji . "N" . g_oyakeyPos["無変換"]] := "X"
	keyAttribute3[_Romaji . "N" . g_oyakeyPos["Space"]]  := "X"
	keyAttribute3[_Romaji . "N" . g_oyakeyPos["変換"]]   := "X"
	keyAttribute3[_Romaji . "K" . g_oyakeyPos["無変換"]] := "X"
	keyAttribute3[_Romaji . "K" . g_oyakeyPos["Space"]]  := "X"
	keyAttribute3[_Romaji . "K" . g_oyakeyPos["変換"]]   := "X"
	
	if(ShiftMode[_Romaji] != "親指シフト") {
		g_Oya2Layout["L"] := ""
		g_Oya2Layout["R"] := ""
		g_Oya2kName["L"]  := ""
		g_Oya2kName["R"]  := ""
		return
	}
	if(g_OyaKey == "無変換－空白") {
		g_Oya2kName["L"] := "無変換"
		g_Oya2kName["R"] := "Space"
	}
	else if(g_OyaKey == "空白－変換") {
		g_Oya2kName["L"] := "Space"
		g_Oya2kName["R"] := "変換"
	} else {
		g_Oya2kName["L"] := "無変換"
		g_Oya2kName["R"] := "変換"
	}
	g_Oya2Layout["L"] := g_oyakeyPos[g_Oya2kName["L"]]
	g_Oya2Layout["R"] := g_oyakeyPos[g_Oya2kName["R"]]
	keyAttribute3[_Romaji . "N" . g_Oya2Layout["L"]] := "L"
	keyAttribute3[_Romaji . "K" . g_Oya2Layout["L"]] := "L"
	keyAttribute3[_Romaji . "N" . g_Oya2Layout["R"]] := "R"
	keyAttribute3[_Romaji . "K" . g_Oya2Layout["R"]] := "R"
}

;----------------------------------------------------------------------
; スペース＆シフトの設定
;----------------------------------------------------------------------
SetSansKey(_sansPos)
{
	global
	if(_sansPos != "") {
		keyAttribute3["AN" . _sansPos] := "S"
		keyAttribute3["AK" . _sansPos] := "S"
		keyAttribute3["AS" . _sansPos] := "S"
		keyAttribute3["RN" . _sansPos] := "S"
		keyAttribute3["RK" . _sansPos] := "S"
		keyAttribute3["RS" . _sansPos] := "S"
	}
}

;----------------------------------------------------------------------
; ローマ字・英数のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
fSetKeyTable(_keyArray, g_mode, _col)
{
	global
	local _lpos2, _down, _up, _status

	kdn[g_mode . "0"] := _keyArray.Length
	kup[g_mode . "0"] := _keyArray.Length
	Loop _keyArray.Length
	{
		_lpos2 := _col . g_rowhash[A_Index]
		if(!ksc.Has(g_mode . _lpos2) || ksc[g_mode . _lpos2] < 1) {
			ksc[g_mode . _lpos2] := 1	; 最大同時打鍵数を１に初期化
			ksc[g_mode . _lpos2 . _lpos2] := 0
			ksc[g_mode . _lpos2 . _lpos2 . _lpos2] := 0
		}

		; 月配列などのプレフィックスシフトキー
		if(_keyArray[A_Index] == " 1" || _keyArray[A_Index] == " 2" || _keyArray[A_Index] == " 3" || _keyArray[A_Index] == " 4" || _keyArray[A_Index] == " 5"
		|| _keyArray[A_Index] == " 6" || _keyArray[A_Index] == " 7" || _keyArray[A_Index] == " 8" || _keyArray[A_Index] == " 9" || _keyArray[A_Index] == " 0")
		{
			kdn[g_mode . _lpos2] := ""
			kup[g_mode . _lpos2] := ""

			kLabel[g_mode . _lpos2] := SubStr(_keyArray[A_Index], 2, 1)

			g_mode2 := SubStr(g_mode, 1, 1) . SubStr(g_mode, 3, 1)
			keyAttribute3[g_mode2 . _lpos2] := SubStr(_keyArray[A_Index], 2, 1)
			continue
		}
		
		; 無の指定ならば，元のキーそのもののスキャンコードとする
		if(_keyArray[A_Index] == "無") {
			kLabel[g_mode . _lpos2] := _keyArray[A_Index]
			if(CtrlScHash.Has(ScanCodeHash[_lpos2]) && CtrlScHash[ScanCodeHash[_lpos2]] != "") {
				kst[g_mode . _lpos2] := "c"	; 制御コード
			}
			kdn[g_mode . _lpos2] := "{" . ScanCodeHash[_lpos2] . " down}"
			kup[g_mode . _lpos2] := "{" . ScanCodeHash[_lpos2] . " up}"
			continue
		}
		
		GenSendStr3(g_mode, _keyArray[A_Index], &_down, &_up, &_status)
		if(g_error != "") {
			g_error := _lpos2 . ":" . g_error
			break
		}
		
		prevKstN := kst.Has(SubStr(g_mode, 1, 1) . "N" . SubStr(g_mode, 3, 1) . _lpos2) ? kst[SubStr(g_mode, 1, 1) . "N" . SubStr(g_mode, 3, 1) . _lpos2] : ""
		kst[SubStr(g_mode, 1, 1) . "N" . SubStr(g_mode, 3, 1) . _lpos2] := MergeStatus(prevKstN . _status)
		
		prevKstR := kst.Has(SubStr(g_mode, 1, 1) . "R" . SubStr(g_mode, 3, 1) . _lpos2) ? kst[SubStr(g_mode, 1, 1) . "R" . SubStr(g_mode, 3, 1) . _lpos2] : ""
		kst[SubStr(g_mode, 1, 1) . "R" . SubStr(g_mode, 3, 1) . _lpos2] := MergeStatus(prevKstR . _status)
		
		prevKstL := kst.Has(SubStr(g_mode, 1, 1) . "L" . SubStr(g_mode, 3, 1) . _lpos2) ? kst[SubStr(g_mode, 1, 1) . "L" . SubStr(g_mode, 3, 1) . _lpos2] : ""
		kst[SubStr(g_mode, 1, 1) . "L" . SubStr(g_mode, 3, 1) . _lpos2] := MergeStatus(prevKstL . _status)
		
		if(SubStr(g_mode, 1, 1) == "R")
		{
			kLabel[g_mode . _lpos2] := Romaji2Surface(_keyArray[A_Index])
		}
		else
		{
			kLabel[g_mode . _lpos2] := _keyArray[A_Index]
		}
		kdn[g_mode . _lpos2] := _down
		kup[g_mode . _lpos2] := _up
	}
	return g_error
}

;----------------------------------------------------------------------
; ローマ字＋文字同時打鍵のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
fSetSimulKeyTable(_keyArray, g_mode, _col, _simulKeyStroke, _lpos)
{
	global
	local _row2, _down, _up, _status

	Loop _keyArray.Length
	{
		if(_keyArray[A_Index] == "無") {
			continue
		}
		_row2 := g_rowhash[A_Index]
		_lpos[0] := _col . _row2
		_tmode := ParseTableMode(_simulKeyStroke)
		if(_tmode == "{*}") {
			_lpos[0] := g_colPushedHash[_col] . _row2
		}
		
		if(vkeyHash.Has(_lpos[0]) && vkeyHash[_lpos[0]] > 0) {	; キーオンか
			if(!ksc.Has(g_mode . _lpos[0]) || ksc[g_mode . _lpos[0]] < 2) {
				ksc[g_mode . _lpos[0]] := 2	; 最大同時打鍵数を設定
			}
		}
		if(vkeyHash.Has(_lpos[1]) && vkeyHash[_lpos[1]] > 0) {	; キーオンか
			if(!ksc.Has(g_mode . _lpos[1]) || ksc[g_mode . _lpos[1]] < 2) {
				ksc[g_mode . _lpos[1]] := 2	; 最大同時打鍵数を設定
			}
		}
		if(!ksc.Has(g_mode . _lpos[0] . _lpos[1]) || ksc[g_mode . _lpos[0] . _lpos[1]] < 2) {
			ksc[g_mode . _lpos[0] . _lpos[1]] := 2	; 最大同時打鍵数を設定
		}
		if(!ksc.Has(g_mode . _lpos[1] . _lpos[0]) || ksc[g_mode . _lpos[1] . _lpos[0]] < 2) {
			ksc[g_mode . _lpos[1] . _lpos[0]] := 2	; 最大同時打鍵数を設定
		}
		
		; 送信形式に変換・・・なお、文字同時打鍵は小指シフトしない
		GenSendStr3(g_mode, _keyArray[A_Index], &_down, &_up, &_status)
		if(g_error != "") {
			g_error := _lpos[0] . ":" . g_error
			break
		}
		
		if(vkeyHash.Has(_lpos[0]) && vkeyHash[_lpos[0]] > 0) {
			prevKst := kst.Has(g_mode . _lpos[0]) ? kst[g_mode . _lpos[0]] : ""
			kst[g_mode . _lpos[0]] := MergeStatus(prevKst . _status)
		}
		if(vkeyHash.Has(_lpos[1]) && vkeyHash[_lpos[1]] > 0) {
			prevKst := kst.Has(g_mode . _lpos[1]) ? kst[g_mode . _lpos[1]] : ""
			kst[g_mode . _lpos[1]] := MergeStatus(prevKst . _status)
		}
		
		kst[g_mode . _simulKeyStroke . _lpos[0]] := MergeStatus(_status)
		kst[g_mode . _lpos[1] . _lpos[0]] := MergeStatus(_status)
		kst[g_mode . _lpos[0] . _lpos[1]] := MergeStatus(_status)
		
		if(SubStr(g_mode, 1, 1) == "R") {
			surface := Romaji2Surface(_keyArray[A_Index])
			kLabel[g_mode . _simulKeyStroke . _lpos[0]] := surface
			kLabel[g_mode . _lpos[1] . _lpos[0]] := surface
			kLabel[g_mode . _lpos[0] . _lpos[1]] := surface
		} else {
			kLabel[g_mode . _simulKeyStroke . _lpos[0]] := _keyArray[A_Index]			
			kLabel[g_mode . _lpos[1] . _lpos[0]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[0] . _lpos[1]] := _keyArray[A_Index]
		}
		
		kdn[g_mode . _lpos[1] . _lpos[0]] := _down
		kdn[g_mode . _lpos[0] . _lpos[1]] := _down
		kup[g_mode . _lpos[1] . _lpos[0]] := _up
		kup[g_mode . _lpos[0] . _lpos[1]] := _up
	}
}

;----------------------------------------------------------------------
; ローマ字＋文字同時打鍵のときのキーダウン・キーアップの際に送信する内容を作成
;----------------------------------------------------------------------
fSetSimulKeyTable3(_keyArray, g_mode,  _col, _simulKeyStroke, _lpos)
{
	global
	local _row2, _down, _up, _status

	Loop _keyArray.Length
	{
		if(_keyArray[A_Index] == "無") {
			continue
		}
		_row2 := g_rowhash[A_Index]
		_lpos[0] := _col . _row2
		_tmode := ParseTableMode(_simulKeyStroke)
		if(_tmode == "{*}") {
			_lpos[0] := g_colPushedHash[_col] . _row2
		}
		if(vkeyHash.Has(_lpos[0]) && vkeyHash[_lpos[0]] > 0) {
			ksc[g_mode . _lpos[0]] := 3
		}
		if(vkeyHash.Has(_lpos[1]) && vkeyHash[_lpos[1]] > 0) {
			ksc[g_mode . _lpos[1]] := 3
		}
		if(vkeyHash.Has(_lpos[2]) && vkeyHash[_lpos[2]] > 0) {
			ksc[g_mode . _lpos[2]] := 3
		}
		if((vkeyHash.Has(_lpos[0]) && vkeyHash[_lpos[0]] > 0) || (vkeyHash.Has(_lpos[1]) && vkeyHash[_lpos[1]] > 0)) {
			ksc[g_mode . _lpos[0] . _lpos[1]] := 3
			ksc[g_mode . _lpos[1] . _lpos[0]] := 3
		}
		if((vkeyHash.Has(_lpos[0]) && vkeyHash[_lpos[0]] > 0) || (vkeyHash.Has(_lpos[2]) && vkeyHash[_lpos[2]] > 0)) {
			ksc[g_mode . _lpos[0] . _lpos[2]] := 3
			ksc[g_mode . _lpos[2] . _lpos[0]] := 3
		}
		if((vkeyHash.Has(_lpos[1]) && vkeyHash[_lpos[1]] > 0) || (vkeyHash.Has(_lpos[2]) && vkeyHash[_lpos[2]] > 0)) {
			ksc[g_mode . _lpos[1] . _lpos[2]] := 3
			ksc[g_mode . _lpos[2] . _lpos[1]] := 3
		}
		
		ksc[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := 3
		ksc[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := 3
		ksc[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := 3
		ksc[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := 3
		ksc[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := 3
		ksc[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := 3
		
		GenSendStr3(g_mode, _keyArray[A_Index], &_down, &_up, &_status)
		if(g_error != "") {
			g_error := _lpos[0] . ":" . g_error
			break
		}
		
		if(vkeyHash.Has(_lpos[0]) && vkeyHash[_lpos[0]] > 0) {
			prevKst := kst.Has(g_mode . _lpos[0]) ? kst[g_mode . _lpos[0]] : ""
			kst[g_mode . _lpos[0]] := MergeStatus(prevKst . _status)
		}
		if(vkeyHash.Has(_lpos[1]) && vkeyHash[_lpos[1]] > 0) {
			prevKst := kst.Has(g_mode . _lpos[1]) ? kst[g_mode . _lpos[1]] : ""
			kst[g_mode . _lpos[1]] := MergeStatus(prevKst . _status)
		}
		if(vkeyHash.Has(_lpos[2]) && vkeyHash[_lpos[2]] > 0) {
			prevKst := kst.Has(g_mode . _lpos[2]) ? kst[g_mode . _lpos[2]] : ""
			kst[g_mode . _lpos[2]] := MergeStatus(prevKst . _status)
		}
		
		kst[g_mode . _simulKeyStroke . _lpos[0]] := MergeStatus(_status)
		kst[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := MergeStatus(_status)
		kst[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := MergeStatus(_status)
		kst[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := MergeStatus(_status)
		kst[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := MergeStatus(_status)
		kst[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := MergeStatus(_status)
		kst[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := MergeStatus(_status)
		
		if(SubStr(g_mode, 1, 1) == "R") {
			surface := Romaji2Surface(_keyArray[A_Index])
			kLabel[g_mode . _simulKeyStroke . _lpos[0]] := surface
			kLabel[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := surface
			kLabel[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := surface
			kLabel[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := surface
			kLabel[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := surface
			kLabel[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := surface
			kLabel[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := surface
		} else {
			kLabel[g_mode . _simulKeyStroke . _lpos[0]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := _keyArray[A_Index]
			kLabel[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := _keyArray[A_Index]
		}
		
		kdn[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := _down
		kdn[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := _down
		kdn[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := _down
		kdn[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := _down
		kdn[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := _down
		kdn[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := _down

		kup[g_mode . _lpos[1] . _lpos[2] . _lpos[0]] := _up
		kup[g_mode . _lpos[0] . _lpos[2] . _lpos[1]] := _up
		kup[g_mode . _lpos[0] . _lpos[1] . _lpos[2]] := _up
		kup[g_mode . _lpos[1] . _lpos[0] . _lpos[2]] := _up
		kup[g_mode . _lpos[2] . _lpos[0] . _lpos[1]] := _up
		kup[g_mode . _lpos[2] . _lpos[1] . _lpos[0]] := _up
	}
}

;----------------------------------------------------------------------
; 修飾キー＋文字キーの出力の際に送信する内容を作成
;----------------------------------------------------------------------
GetOnKeyPos(_pushedKeys)
{
	local _OnKeyPos
	_OnKeyPos := _pushedKeys
	pos := InStr("54321", SubStr(_pushedKeys, 1, 1))
	if(pos != 0) {
		_OnKeyPos := SubStr("EDBCA", pos, 1) . SubStr(_pushedKeys, 2, 2)
	}
	return _OnKeyPos
}

;----------------------------------------------------------------------
; カラム配列の複写
;----------------------------------------------------------------------
CopyColumns(_mdsrc, _mddst)
{
	global
	if (LF.Has(_mdsrc . "E"))
		LF[_mddst . "E"] := LF[_mdsrc . "E"]
	if (LF.Has(_mdsrc . "D"))
		LF[_mddst . "D"] := LF[_mdsrc . "D"]
	if (LF.Has(_mdsrc . "C"))
		LF[_mddst . "C"] := LF[_mdsrc . "C"]
	if (LF.Has(_mdsrc . "B"))
		LF[_mddst . "B"] := LF[_mdsrc . "B"]
	if (LF.Has(_mdsrc . "A"))
		LF[_mddst . "A"] := LF[_mdsrc . "A"]
}

;----------------------------------------------------------------------
; ローマ字を仮名に変換する
;----------------------------------------------------------------------
Romaji2Surface(aStr)
{
	global
	if(romaji2SurfaceHash.Has(aStr) && romaji2SurfaceHash[aStr] != "")
	{
		return romaji2SurfaceHash[aStr]
	}
	return aStr
}

;----------------------------------------------------------------------
; 通常のキーdown時にSendする引数の文字列を設定する
;----------------------------------------------------------------------
GenSendStr3(_mode, aStr, &_dn, &_up, &_status)
{
	global
	local _modifier, _len
	local _qstr, _c1, _c2, _idx
	local _a1, _a2, _a3

	g_error := ""
	_status := ""
	_modifier := ""
	_dn := ""
	_up := ""
	_len := StrLen(aStr)
	
	if(_len == 0)
	{
		return ""
	}
	
	_c1 := ""
	_c2 := ""
	_idx := 1
	while(_idx <= _len)
	{
		_a1 := SubStr(aStr, _idx, 1)
		_a2 := SubStr(aStr, _idx, 2)
		if(StrLen(_a2) != 2) {
			_a2 := ""
		}
		_a3 := SubStr(aStr, _idx, 3)
		if(StrLen(_a3) != 3) {
			_a3 := ""
		}
		
		if(modifierHash.Has(_a1) && modifierHash[_a1] != "") {
			if(_c2 != "") {
				_modifier := ""
				_c2 := ""
			}
			_dn .= modifierHash[_a1]
			_modifier .= modifierHash[_a1]
			_status .= "m"			; 修飾キーがあった
			_idx += 1
		} else if(_a1 == "'" || _a1 == '"') {	; 引用符のマーク
			_idx += 1
			_c1 := SubStr(aStr, _idx)
			Loop Parse, _c1
			{
				_idx++
				if (A_LoopField == _a1)
				{
					break
				}
				_dn .= "{" . A_LoopField . "}" . Chr(9)
			}
			_c1 := ""
			_c2 := ""
			_status .= "Q"		; 引用があった
			_modifier := ""
		} else if((_a1 == "v" || _a1 == "V") && StrLen(_a3) == 3) {	; 仮想キーコードのマーク
			if(InStr("0123456789ABCDEFabcdef", SubStr(_a3, 2, 1)) == 0
			|| InStr("0123456789ABCDEFabcdef", SubStr(_a3, 3, 1)) == 0) {
				g_error := "仮想キーコードの記載が誤っています"
			}
			_c2 .= "vk" . SubStr(_a3, 2, 2)
			_dn .= "{" . _c2 . " }" . Chr(9)
			_idx += 3
			if(ctrlvKeyHash.Has("vk" . SubStr(_a3, 2, 2)) && ctrlvKeyHash["vk" . SubStr(_a3, 2, 2)] != "") {
				_status .= "c"		; 制御キー
			}
		} else {
			if(ctrlKeyHash.Has(_a3) && ctrlKeyHash[_a3] != "") {
				_c2 := z2hHash[_a3]
				_dn .= "{" . _c2 . "}" . Chr(9)
				_status .= "c"
				_idx += 3
			} else if(ctrlKeyHash.Has(_a2) && ctrlKeyHash[_a2] != "") {
				_c2 := z2hHash[_a2]
				_dn .= "{" . _c2 . "}" . Chr(9)
				_status .= "c"
				_idx += 2
			} else if(ctrlKeyHash.Has(_a1) && ctrlKeyHash[_a1] != "") {
				_c2 := z2hHash[_a1]
				_dn .= "{" . _c2 . "}" . Chr(9)
				if(_a1 == "入" && SubStr(_mode, 1, 1) == "R" 
				&& (SubStr(_status, StrLen(_status), 1) == "Q" || SubStr(_status, StrLen(_status), 1) == "D")) {
					;ローマ字モードで確定のエンターは制御キーとして扱わない
				} else {
					_status .= "c"
				}
				_idx += 1
			}
			else if(SubStr(_mode, 1, 1) == "A")
			{
				_idx += 1
				_c2 := z2hHash.Has(_a1) ? z2hHash[_a1] : _a1
				_dn .= "{" . _c2 . "}" . Chr(9)
				_c1 := ""
			} else {
				if(true) {	; ローマ字変換モード
					if(roma3Hash.Has(_a2) && roma3Hash[_a2] != "") {
						_c1 := roma3Hash[_a2]
						_idx += 2
					} else if(roma3Hash.Has(_a1) && roma3Hash[_a1] != "") {
						_c1 := roma3Hash[_a1]
						_idx += 1
					} else {
						_c1 := _a1
						_idx += 1
					}
					Loop Parse, _c1
					{
						_c2 := z2hHash.Has(A_LoopField) ? z2hHash[A_LoopField] : A_LoopField
						_dn .= "{" . _c2 . "}" . Chr(9)
					}
					_c1 := ""
				} else {	; カナ変換モード
					if(kanaInHash.Has(_a1) && kanaInHash[_a1] != "") {
						_c1 := kanaInHash[_a1]
						_idx += 1
						Loop Parse, _c1
						{
							if(modifierHash.Has(A_LoopField) && modifierHash[A_LoopField] != "") {
								if(_c2 != "") {
									_modifier := ""
									_c2 := ""
								}
								_dn .= modifierHash[A_LoopField]
								_modifier .= modifierHash[A_LoopField]
							} else {
								_c2 := z2hHash.Has(A_LoopField) ? z2hHash[A_LoopField] : A_LoopField
								_dn .= "{" . _c2 . "}" . Chr(9)
							}
						}
					}
					else if (InStr("無濁半拗修", _a1) == 0)
					{
						_dn .= "{" . _a1 . "}" . Chr(9)
						_c2 := ""
						_modifier := ""
						_idx += 1
					} else {
						_idx += 1
					}
				}
				_status .= "D"
			}
		}
	}
	if(_c2 != "") {
		_dn := SubStr(_dn, 1, StrLen(_dn) - 2) . " down}"
		_up := _modifier . "{" . _c2 . " up}"
		_modifier := ""
		_c2 := ""
	}
	else if (StrLen(_dn) > 0)
	{
		_dn := SubStr(_dn, 1, StrLen(_dn) - 1)
	}
	_status := MergeStatus(_status)
	return _dn
}

;----------------------------------------------------------------------
; ステータスを合わせる
;----------------------------------------------------------------------
MergeStatus(_status)
{
	local _status2 := ""
	if(InStr(_status, "S") > 0)
		_status2 .= "S"
	if(InStr(_status, "v") > 0)
		_status2 .= "v"
	if(InStr(_status, "c") > 0) 
		_status2 .= "c"
	if(InStr(_status, "m") > 0)
		_status2 .= "m"
	if(InStr(_status, "f") > 0)
		_status2 .= "f"
	return _status2
}

;=============================================================================
; 各種ハッシュマップ作成関数
;=============================================================================

MakeLayout2Hash() {
	hash := Map()
	hash["[英数シフト無し]"] := "ANN"
	hash["[英数左親指シフト]"] := "ALN"
	hash["[英数右親指シフト]"] := "ARN"
	hash["[英数小指シフト]"] := "ANK"
	hash["[英数小指左親指シフト]"] := "ALK"
	hash["[英数小指右親指シフト]"] := "ARK"
	hash["[英数スペースシフト]"] := "ANS"
	hash["[ローマ字シフト無し]"] := "RNN"
	hash["[ローマ字左親指シフト]"] := "RLN"
	hash["[ローマ字右親指シフト]"] := "RRN"
	hash["[ローマ字小指シフト]"] := "RNK"
	hash["[ローマ字小指左親指シフト]"] := "RRK"
	hash["[ローマ字小指右親指シフト]"] := "RLK"
	hash["[ローマ字スペースシフト]"] := "RNS"

	hash["[英数１プリフィックスシフト]"] := "A1N"
	hash["[英数２プリフィックスシフト]"] := "A2N"
	hash["[英数３プリフィックスシフト]"] := "A3N"
	hash["[英数４プリフィックスシフト]"] := "A4N"
	hash["[英数５プリフィックスシフト]"] := "A5N"
	hash["[英数６プリフィックスシフト]"] := "A6N"
	hash["[英数７プリフィックスシフト]"] := "A7N"
	hash["[英数８プリフィックスシフト]"] := "A8N"
	hash["[英数９プリフィックスシフト]"] := "A9N"
	hash["[英数０プリフィックスシフト]"] := "A0N"
	hash["[英数小指１プリフィックスシフト]"] := "A1K"
	hash["[英数小指２プリフィックスシフト]"] := "A2K"
	hash["[英数小指３プリフィックスシフト]"] := "A3K"
	hash["[英数小指４プリフィックスシフト]"] := "A4K"
	hash["[英数小指５プリフィックスシフト]"] := "A5K"
	hash["[英数小指６プリフィックスシフト]"] := "A6K"
	hash["[英数小指７プリフィックスシフト]"] := "A7K"
	hash["[英数小指８プリフィックスシフト]"] := "A8K"
	hash["[英数小指９プリフィックスシフト]"] := "A9K"
	hash["[英数小指０プリフィックスシフト]"] := "A0K"
    
	hash["[ローマ字１プリフィックスシフト]"] := "R1N"
	hash["[ローマ字２プリフィックスシフト]"] := "R2N"
	hash["[ローマ字３プリフィックスシフト]"] := "R3N"
	hash["[ローマ字４プリフィックスシフト]"] := "R4N"
	hash["[ローマ字５プリフィックスシフト]"] := "R5N"
	hash["[ローマ字６プリフィックスシフト]"] := "R6N"
	hash["[ローマ字７プリフィックスシフト]"] := "R7N"
	hash["[ローマ字８プリフィックスシフト]"] := "R8N"
	hash["[ローマ字９プリフィックスシフト]"] := "R9N"
	hash["[ローマ字０プリフィックスシフト]"] := "R0N"
	hash["[ローマ字小指１プリフィックスシフト]"] := "R1K"
	hash["[ローマ字小指２プリフィックスシフト]"] := "R2K"
	hash["[ローマ字小指３プリフィックスシフト]"] := "R3K"
	hash["[ローマ字小指４プリフィックスシフト]"] := "R4K"
	hash["[ローマ字小指５プリフィックスシフト]"] := "R5K"
	hash["[ローマ字小指６プリフィックスシフト]"] := "R6K"
	hash["[ローマ字小指７プリフィックスシフト]"] := "R7K"
	hash["[ローマ字小指８プリフィックスシフト]"] := "R8K"
	hash["[ローマ字小指９プリフィックスシフト]"] := "R9K"
	hash["[ローマ字小指０プリフィックスシフト]"] := "R0K"
	
	; やまぶき互換
	hash["[1英数シフト無し]"] := "A1N"
	hash["[2英数シフト無し]"] := "A2N"
	hash["[3英数シフト無し]"] := "A3N"
	hash["[4英数シフト無し]"] := "A4N"
	hash["[5英数シフト無し]"] := "A5N"
	hash["[6英数シフト無し]"] := "A6N"
	hash["[7英数シフト無し]"] := "A7N"
	hash["[8英数シフト無し]"] := "A8N"
	hash["[9英数シフト無し]"] := "A9N"
	hash["[0英数シフト無し]"] := "A0N"
	hash["[1英数小指シフト]"] := "A1K"
	hash["[2英数小指シフト]"] := "A2K"
	hash["[3英数小指シフト]"] := "A3K"
	hash["[4英数小指シフト]"] := "A4K"
	hash["[5英数小指シフト]"] := "A5K"
	hash["[6英数小指シフト]"] := "A6K"
	hash["[7英数小指シフト]"] := "A7K"
	hash["[8英数小指シフト]"] := "A8K"
	hash["[9英数小指シフト]"] := "A9K"
	hash["[0英数小指シフト]"] := "A0K"

	hash["[1ローマ字シフト無し]"] := "R1N"
	hash["[2ローマ字シフト無し]"] := "R2N"
	hash["[3ローマ字シフト無し]"] := "R3N"
	hash["[4ローマ字シフト無し]"] := "R4N"
	hash["[5ローマ字シフト無し]"] := "R5N"
	hash["[6ローマ字シフト無し]"] := "R6N"
	hash["[7ローマ字シフト無し]"] := "R7N"
	hash["[8ローマ字シフト無し]"] := "R8N"
	hash["[9ローマ字シフト無し]"] := "R9N"
	hash["[0ローマ字シフト無し]"] := "R0N"
	hash["[1ローマ字小指シフト]"] := "R1K"
	hash["[2ローマ字小指シフト]"] := "R2K"
	hash["[3ローマ字小指シフト]"] := "R3K"
	hash["[4ローマ字小指シフト]"] := "R4K"
	hash["[5ローマ字小指シフト]"] := "R5K"
	hash["[6ローマ字小指シフト]"] := "R6K"
	hash["[7ローマ字小指シフト]"] := "R7K"
	hash["[8ローマ字小指シフト]"] := "R8K"
	hash["[9ローマ字小指シフト]"] := "R9K"
	hash["[0ローマ字小指シフト]"] := "R0K"
	
	hash["[拡張親指シフト1]"] := "RAN"
	hash["[拡張親指シフト2]"] := "RBN"
	hash["[拡張親指シフト3]"] := "RCN"
	hash["[拡張親指シフト4]"] := "RDN"
	hash["[小指拡張親指シフト1]"] := "RAK"
	hash["[小指拡張親指シフト2]"] := "RBK"
	hash["[小指拡張親指シフト3]"] := "RCK"
	hash["[小指拡張親指シフト4]"] := "RDK"
	return hash
}

MakeZ2hHash() {
	hash := Map()
	hash["後"] := "Backspace"
	hash["逃"] := "Escape"
	hash["入"] := "Enter"
	hash["空"] := "Space"
	hash["消"] := "Delete"
	hash["挿"] := "Insert"
	hash["上"] := "Up"
	hash["左"] := "Left"
	hash["右"] := "Right"
	hash["下"] := "Down"
	hash["家"] := "Home"
	hash["終"] := "End"
	hash["前"] := "PgUp"
	hash["次"] := "PgDn"
	hash["表"] := "tab"
	hash["日"] := "vkF2sc070"
	hash["英"] := "vkF0sc03A"
	hash["変"] := "vk1Csc079"
	hash["換"] := "vk1Dsc07B"
	hash["無"] := ""
	hash["濁"] := ""
	hash["半"] := ""
	hash["拗"] := ""
	hash["修"] := ""
	hash["円"] := "vkDCsc07D"
	hash["゛"] := "vkC0sc01A"
	hash["゜"] := "vkDBsc01B"
	hash[Chr(65509)] := "\"
	hash[Chr(8220)]  := '"'
	hash[Chr(8221)]  := '"'
	hash[Chr(8217)]  := "'"
	hash[Chr(8216)]  := "``"
	hash[Chr(12288)] := " "
	hash["機1"] := "sc03B"
	hash["機2"] := "sc03C"
	hash["機3"] := "sc03D"
	hash["機4"] := "sc03E"
	hash["機5"] := "sc03F"
	hash["機6"] := "sc040"
	hash["機7"] := "sc041"
	hash["機8"] := "sc042"
	hash["機9"] := "sc043"
	hash["機10"] := "sc044"
	hash["機11"] := "sc057"
	hash["機12"] := "sc058"
	hash["　"] := "Space"
	hash["！"] := "!"
	hash["”"] := '"'
	hash["“"] := '"'
	hash["＃"] := "#"
	hash["＄"] := "$"
	hash["％"] := "%"
	hash["＆"] := "&"
	hash["’"] := "'"
	hash["′"] := "'"
	hash["（"] := "("
	hash["）"] := ")"
	hash["＊"] := "*"
	hash["＋"] := "+"
	hash["，"] := ","
	hash["－"] := "-"
	hash["．"] := "."
	hash["／"] := "/"
	hash["０"] := "0"
	hash["１"] := "1"
	hash["２"] := "2"
	hash["３"] := "3"
	hash["４"] := "4"
	hash["５"] := "5"
	hash["６"] := "6"
	hash["７"] := "7"
	hash["８"] := "8"
	hash["９"] := "9"
	hash["："] := ":"
	hash["；"] := ";"
	hash["＜"] := "<"
	hash["＝"] := "="
	hash["＞"] := ">"
	hash["？"] := "?"
	hash["＠"] := "@"
	hash["Ａ"] := "A"
	hash["Ｂ"] := "B"
	hash["Ｃ"] := "C"
	hash["Ｄ"] := "D"
	hash["Ｅ"] := "E"
	hash["Ｆ"] := "F"
	hash["Ｇ"] := "G"
	hash["Ｈ"] := "H"
	hash["Ｉ"] := "I"
	hash["Ｊ"] := "J"
	hash["Ｋ"] := "K"
	hash["Ｌ"] := "L"
	hash["Ｍ"] := "M"
	hash["Ｎ"] := "N"
	hash["Ｏ"] := "O"
	hash["Ｐ"] := "P"
	hash["Ｑ"] := "Q"
	hash["Ｒ"] := "R"
	hash["Ｓ"] := "S"
	hash["Ｔ"] := "T"
	hash["Ｕ"] := "U"
	hash["Ｖ"] := "V"
	hash["Ｗ"] := "W"
	hash["Ｘ"] := "X"
	hash["Ｙ"] := "Y"
	hash["Ｚ"] := "Z"
	hash["［"] := "["
	hash["￥"] := "\"
	hash["］"] := "]"
	hash["＾"] := "^"
	hash["＿"] := "_"
	hash["｀"] := "``"
	hash["ａ"] := "a"
	hash["ｂ"] := "b"
	hash["ｃ"] := "c"
	hash["ｄ"] := "d"
	hash["ｅ"] := "e"
	hash["ｆ"] := "f"
	hash["ｇ"] := "g"
	hash["ｈ"] := "h"
	hash["ｉ"] := "i"
	hash["ｊ"] := "j"
	hash["ｋ"] := "k"
	hash["ｌ"] := "l"
	hash["ｍ"] := "m"
	hash["ｎ"] := "n"
	hash["ｏ"] := "o"
	hash["ｐ"] := "p"
	hash["ｑ"] := "q"
	hash["ｒ"] := "r"
	hash["ｓ"] := "s"
	hash["ｔ"] := "t"
	hash["ｕ"] := "u"
	hash["ｖ"] := "v"
	hash["ｗ"] := "w"
	hash["ｘ"] := "x"
	hash["ｙ"] := "y"
	hash["ｚ"] := "z"
	hash["｛"] := "{"
	hash["｜"] := "|"
	hash["｝"] := "}"
	hash["～"] := "~"
	return hash
}

MakeRoma3Hash() {
	hash := Map()
	hash["ぁ"] := "ｌａ", hash["あ"] := "ａ", hash["ぃ"] := "ｌｉ", hash["い"] := "ｉ"
	hash["ぅ"] := "ｌｕ", hash["う"] := "ｕ", hash["ぇ"] := "ｌｅ", hash["え"] := "ｅ"
	hash["ぉ"] := "ｌｏ", hash["お"] := "ｏ", hash["か"] := "ｋａ", hash["が"] := "ｇａ"
	hash["き"] := "ｋｉ", hash["ぎ"] := "ｇｉ", hash["く"] := "ｋｕ", hash["ぐ"] := "ｇｕ"
	hash["け"] := "ｋｅ", hash["げ"] := "ｇｅ", hash["こ"] := "ｋｏ", hash["ご"] := "ｇｏ"
	hash["さ"] := "ｓａ", hash["ざ"] := "ｚａ", hash["し"] := "ｓｉ", hash["じ"] := "ｚｉ"
	hash["す"] := "ｓｕ", hash["ず"] := "ｚｕ", hash["せ"] := "ｓｅ", hash["ぜ"] := "ｚｅ"
	hash["そ"] := "ｓｏ", hash["ぞ"] := "ｚｏ", hash["た"] := "ｔａ", hash["だ"] := "ｄａ"
	hash["ち"] := "ｔｉ", hash["ぢ"] := "ｄｉ", hash["っ"] := "ｌｔｕ", hash["つ"] := "ｔｕ"
	hash["づ"] := "ｄｕ", hash["て"] := "ｔｅ", hash["で"] := "ｄｅ", hash["と"] := "ｔｏ"
	hash["ど"] := "ｄｏ", hash["な"] := "ｎａ", hash["に"] := "ｎｉ", hash["ぬ"] := "ｎｕ"
	hash["ね"] := "ｎｅ", hash["の"] := "ｎｏ", hash["は"] := "ｈａ", hash["ば"] := "ｂａ"
	hash["ぱ"] := "ｐａ", hash["ひ"] := "ｈｉ", hash["び"] := "ｂｉ", hash["ぴ"] := "ｐｉ"
	hash["ふ"] := "ｆｕ", hash["ぶ"] := "ｂｕ", hash["ぷ"] := "ｐｕ", hash["へ"] := "ｈｅ"
	hash["べ"] := "ｂｅ", hash["ぺ"] := "ｐｅ", hash["ほ"] := "ｈｏ", hash["ぼ"] := "ｂｏ"
	hash["ぽ"] := "ｐｏ", hash["ま"] := "ｍａ", hash["み"] := "ｍｉ", hash["む"] := "ｍｕ"
	hash["め"] := "ｍｅ", hash["も"] := "ｍｏ", hash["ゃ"] := "ｌｙａ", hash["や"] := "ｙａ"
	hash["ゅ"] := "ｌｙｕ", hash["ゆ"] := "ｙｕ", hash["ょ"] := "ｌｙｏ", hash["よ"] := "ｙｏ"
	hash["ら"] := "ｒａ", hash["り"] := "ｒｉ", hash["る"] := "ｒｕ", hash["れ"] := "ｒｅ"
	hash["ろ"] := "ｒｏ", hash["ゎ"] := "ｌｗａ", hash["わ"] := "ｗａ", hash["ゐ"] := "ｗｙｉ"
	hash["ゑ"] := "ｗｙｅ", hash["を"] := "ｗｏ", hash["ん"] := "ｎｎ", hash["ゔ"] := "ｖｕ"
	hash["ヴ"] := "ｖｕ", hash["ゕ"] := "ｌｋａ", hash["ゖ"] := "ｌｋｅ"
	hash["うぃ"] := "ｗｉ", hash["うぇ"] := "ｗｅ"
	hash["ふぁ"] := "ｆａ", hash["ふぃ"] := "ｆｉ", hash["ふぇ"] := "ｆｅ", hash["ふぉ"] := "ｆｏ"
	hash["くぁ"] := "ｑａ", hash["くぃ"] := "ｑｉ", hash["くぇ"] := "ｑｅ", hash["くぉ"] := "ｑｏ"
	hash["きゃ"] := "ｋｙａ", hash["きぃ"] := "ｋｙｉ", hash["きゅ"] := "ｋｙｕ", hash["きぇ"] := "ｋｙｅ", hash["きょ"] := "ｋｙｏ"
	hash["ぎゃ"] := "ｇｙａ", hash["ぎぃ"] := "ｇｙｉ", hash["ぎゅ"] := "ｇｙｕ", hash["ぎぇ"] := "ｇｙｅ", hash["ぎょ"] := "ｇｙｏ"
	hash["しゃ"] := "ｓｙａ", hash["しぃ"] := "ｓｙｉ", hash["しゅ"] := "ｓｙｕ", hash["しぇ"] := "ｓｙｅ", hash["しょ"] := "ｓｙｏ"
	hash["じゃ"] := "ｚｙａ", hash["じぃ"] := "ｚｙｉ", hash["じゅ"] := "ｚｙｕ", hash["じぇ"] := "ｚｙｅ", hash["じょ"] := "ｚｙｏ"
	hash["てゃ"] := "ｔｈａ", hash["てぃ"] := "ｔｈｉ", hash["てゅ"] := "ｔｈｕ", hash["てぇ"] := "ｔｈｅ", hash["てょ"] := "ｔｈｏ"
	hash["ちゃ"] := "ｔｙａ", hash["ちぃ"] := "ｔｙｉ", hash["ちゅ"] := "ｔｙｕ", hash["ちぇ"] := "ｔｙｅ", hash["ちょ"] := "ｔｙｏ"
	hash["ぢゃ"] := "ｄｙａ", hash["ぢぃ"] := "ｄｙｉ", hash["ぢゅ"] := "ｄｙｕ", hash["ぢぇ"] := "ｄｙｅ", hash["ぢょ"] := "ｄｙｏ"
	hash["にゃ"] := "ｎｙａ", hash["にぃ"] := "ｎｙｉ", hash["にゅ"] := "ｎｙｕ", hash["にぇ"] := "ｎｙｅ", hash["にょ"] := "ｎｙｏ"
	hash["でゃ"] := "ｄｈａ", hash["でぃ"] := "ｄｈｉ", hash["でゅ"] := "ｄｈｕ", hash["でぇ"] := "ｄｈｅ", hash["でょ"] := "ｄｈｏ"
	hash["びゃ"] := "ｂｙａ", hash["びぃ"] := "ｂｙｉ", hash["びゅ"] := "ｂｙｕ", hash["びぇ"] := "ｂｙｅ", hash["びょ"] := "ｂｙｏ"
	hash["ひゃ"] := "ｈｙａ", hash["ひぃ"] := "ｈｙｉ", hash["ひゅ"] := "ｈｙｕ", hash["ひぇ"] := "ｈｙｅ", hash["ひょ"] := "ｈｙｏ"
	hash["ぴゃ"] := "ｐｙａ", hash["ぴぃ"] := "ｐｙｉ", hash["ぴゅ"] := "ｐｙｕ", hash["ぴぇ"] := "ｐｙｅ", hash["ぴょ"] := "ｐｙｏ"
	hash["みゃ"] := "ｍｙａ", hash["みぃ"] := "ｍｙｉ", hash["みゅ"] := "ｍｙｕ", hash["みぇ"] := "ｍｙｅ", hash["みょ"] := "ｍｙｏ"
	hash["りゃ"] := "ｒｙａ", hash["りぃ"] := "ｒｙｉ", hash["りゅ"] := "ｒｙｕ", hash["りぇ"] := "ｒｙｅ", hash["りょ"] := "ｒｙｏ"
	hash["とぁ"] := "ｔｗａ", hash["とぃ"] := "ｔｗｉ", hash["とぅ"] := "ｔｗｕ", hash["とぇ"] := "ｔｗｅ", hash["とぉ"] := "ｔｗｏ"
	hash["どぁ"] := "ｄｗａ", hash["どぃ"] := "ｄｗｉ", hash["どぅ"] := "ｄｗｕ", hash["どぇ"] := "ｄｗｅ", hash["どぉ"] := "ｄｗｏ"
	hash["、"] := "，", hash["，"] := "，", hash["．"] := "．"
	hash["ァ"] := "ｌａ", hash["ア"] := "ａ", hash["ィ"] := "ｌｉ", hash["イ"] := "ｉ"
	hash["ゥ"] := "ｌｕ", hash["ウ"] := "ｕ", hash["ェ"] := "ｌｅ", hash["エ"] := "ｅ"
	hash["ォ"] := "ｌｏ", hash["オ"] := "ｏ", hash["カ"] := "ｋａ", hash["ガ"] := "ｇａ"
	hash["キ"] := "ｋｉ", hash["ギ"] := "ｇｉ", hash["ク"] := "ｋｕ", hash["グ"] := "ｇｕ"
	hash["ケ"] := "ｋｅ", hash["ゲ"] := "ｇｅ", hash["コ"] := "ｋｏ", hash["ゴ"] := "ｇｏ"
	hash["サ"] := "ｓａ", hash["ザ"] := "ｚａ", hash["シ"] := "ｓｉ", hash["ジ"] := "ｚｉ"
	hash["ス"] := "ｓｕ", hash["ズ"] := "ｚｕ", hash["セ"] := "ｓｅ", hash["ゼ"] := "ｚｅ"
	hash["ソ"] := "ｓｏ", hash["ゾ"] := "ｚｏ", hash["タ"] := "ｔａ", hash["ダ"] := "ｄａ"
	hash["チ"] := "ｔｉ", hash["ヂ"] := "ｄｉ", hash["ッ"] := "ｌｔｕ", hash["ツ"] := "ｔｕ"
	hash["ヅ"] := "ｄｕ", hash["テ"] := "ｔｅ", hash["デ"] := "ｄｅ", hash["ト"] := "ｔｏ"
	hash["ド"] := "ｄｏ", hash["ナ"] := "ｎａ", hash["ニ"] := "ｎｉ", hash["ヌ"] := "ｎｕ"
	hash["ネ"] := "ｎｅ", hash["ノ"] := "ｎｏ", hash["ハ"] := "ｈａ", hash["バ"] := "ｂａ"
	hash["パ"] := "ｐａ", hash["ヒ"] := "ｈｉ", hash["ビ"] := "ｂｉ", hash["ピ"] := "ｐｉ"
	hash["フ"] := "ｆｕ", hash["ブ"] := "ｂｕ", hash["プ"] := "ｐｕ", hash["ヘ"] := "ｈｅ"
	hash["ベ"] := "ｂｅ", hash["ペ"] := "ｐｅ", hash["ホ"] := "ｈｏ", hash["ボ"] := "ｂｏ"
	hash["ポ"] := "ｐｏ", hash["マ"] := "ｍａ", hash["ミ"] := "ｍｉ", hash["ム"] := "ｍｕ"
	hash["メ"] := "ｍｅ", hash["モ"] := "ｍｏ", hash["ャ"] := "ｌｙａ", hash["ヤ"] := "ｙａ"
	hash["ュ"] := "ｌｙｕ", hash["ユ"] := "ｙｕ", hash["ョ"] := "ｌｙｏ", hash["ヨ"] := "ｙｏ"
	hash["ラ"] := "ｒａ", hash["リ"] := "ｒｉ", hash["ル"] := "ｒｕ", hash["レ"] := "ｒｅ"
	hash["ロ"] := "ｒｏ", hash["ヮ"] := "ｌｗａ", hash["ワ"] := "ｗａ", hash["ヰ"] := "ｗｙｉ"
	hash["ヱ"] := "ｗｙｅ", hash["ヲ"] := "ｗｏ", hash["ン"] := "ｎｎ", hash["ヴ"] := "ｖｕ"
	hash["ヵ"] := "ｌｋａ", hash["ヶ"] := "ｌｋｅ"
	hash["ウィ"] := "ｗｉ", hash["ウェ"] := "ｗｅ"
	hash["ファ"] := "ｆａ", hash["フィ"] := "ｆｉ", hash["フェ"] := "ｆｅ", hash["フォ"] := "ｆｏ"
	hash["クァ"] := "ｑａ", hash["クィ"] := "ｑｉ", hash["クェ"] := "ｑｅ", hash["クォ"] := "ｑｏ"
	hash["キャ"] := "ｋｙａ", hash["キィ"] := "ｋｙｉ", hash["キュ"] := "ｋｙｕ", hash["キェ"] := "ｋｙｅ", hash["キョ"] := "ｋｙｏ"
	hash["ギャ"] := "ｇｙａ", hash["ギィ"] := "ｇｙｉ", hash["ギュ"] := "ｇｙｕ", hash["ギェ"] := "ｇｙｅ", hash["ギョ"] := "ｇｙｏ"
	hash["シャ"] := "ｓｙａ", hash["シィ"] := "ｓｙｉ", hash["シュ"] := "ｓｙｕ", hash["シェ"] := "ｓｙｅ", hash["ショ"] := "ｓｙｏ"
	hash["ジャ"] := "ｚｙａ", hash["ジィ"] := "ｚｙｉ", hash["ジュ"] := "ｚｙｕ", hash["ジェ"] := "ｚｙｅ", hash["ジョ"] := "ｚｙｏ"
	hash["テャ"] := "ｔｈａ", hash["ティ"] := "ｔｈｉ", hash["テュ"] := "ｔｈｕ", hash["テェ"] := "ｔｈｅ", hash["テョ"] := "ｔｈｏ"
	hash["チャ"] := "ｔｙａ", hash["チィ"] := "ｔｙｉ", hash["チュ"] := "ｔｙｕ", hash["チェ"] := "ｔｙｅ", hash["チョ"] := "ｔｙｏ"
	hash["ヂャ"] := "ｄｙａ", hash["ヂィ"] := "ｄｙｉ", hash["ヂュ"] := "ｄｙｕ", hash["ヂェ"] := "ｄｙｅ", hash["ヂョ"] := "ｄｙｏ"
	hash["ニャ"] := "ｎｙａ", hash["ニィ"] := "ｎｙｉ", hash["ニュ"] := "ｎｙｕ", hash["ニェ"] := "ｎｙｅ", hash["ニョ"] := "ｎｙｏ"
	hash["デャ"] := "ｄｈａ", hash["ディ"] := "ｄｈｉ", hash["デュ"] := "ｄｈｕ", hash["デェ"] := "ｄｈｅ", hash["デョ"] := "ｄｈｏ"
	hash["ビャ"] := "ｂｙａ", hash["ビィ"] := "ｂｙｉ", hash["ビュ"] := "ｂｙｕ", hash["ビェ"] := "ｂｙｅ", hash["ビョ"] := "ｂｙｏ"
	hash["ヒャ"] := "ｈｙａ", hash["ヒィ"] := "ｈｙｉ", hash["ヒュ"] := "ｈｙｕ", hash["ヒェ"] := "ｈｙｅ", hash["ヒョ"] := "ｈｙｏ"
	hash["ピャ"] := "ｐｙａ", hash["ピィ"] := "ｐｙｉ", hash["ピュ"] := "ｐｙｕ", hash["ピェ"] := "ｐｙｅ", hash["ピョ"] := "ｐｙｏ"
	hash["ミャ"] := "ｍｙａ", hash["ミィ"] := "ｍｙｉ", hash["ミュ"] := "ｍｙｕ", hash["ミェ"] := "ｍｙｅ", hash["ミョ"] := "ｍｙｏ"
	hash["リャ"] := "ｒｙａ", hash["リィ"] := "ｒｙｉ", hash["リュ"] := "ｒｙｕ", hash["リェ"] := "ｒｙｅ", hash["リョ"] := "ｒｙｏ"
	hash["トァ"] := "ｔｗａ", hash["トィ"] := "ｔｗｉ", hash["トゥ"] := "ｔｗｕ", hash["トェ"] := "ｔｗｅ", hash["トォ"] := "ｔｗｏ"
	hash["ドァ"] := "ｄｗａ", hash["ドィ"] := "ｄｗｉ", hash["ドゥ"] := "ｄｗｕ", hash["ドェ"] := "ｄｗｅ", hash["ドォ"] := "ｄｗｏ"
	return hash
}

MakeKanaInHash() {
	hash := Map()
	hash["ぁ"] := "s３", hash["あ"] := "３", hash["ぃ"] := "sｅ", hash["い"] := "ｅ"
	hash["ぅ"] := "s４", hash["う"] := "４", hash["ぇ"] := "s５", hash["え"] := "５"
	hash["ぉ"] := "s６", hash["お"] := "６", hash["か"] := "ｔ", hash["が"] := "ｔ゛"
	hash["き"] := "ｇ", hash["ぎ"] := "ｇ゛", hash["く"] := "ｈ", hash["ぐ"] := "ｈ゛"
	hash["け"] := "：", hash["げ"] := "：゛", hash["こ"] := "ｂ", hash["ご"] := "ｂ゛"
	hash["さ"] := "ｘ", hash["ざ"] := "ｘ゛", hash["し"] := "ｄ", hash["じ"] := "ｄ゛"
	hash["す"] := "ｒ", hash["ず"] := "ｒ゛", hash["せ"] := "ｐ", hash["ぜ"] := "ｐ゛"
	hash["そ"] := "ｃ", hash["ぞ"] := "ｃ゛", hash["た"] := "ｑ", hash["だ"] := "ｑ゛"
	hash["ち"] := "ａ", hash["ぢ"] := "ａ゛", hash["っ"] := "sｚ", hash["つ"] := "ｚ"
	hash["づ"] := "ｚ゛", hash["て"] := "ｗ", hash["で"] := "ｗ゛", hash["と"] := "ｓ"
	hash["ど"] := "ｓ゛", hash["な"] := "ｕ", hash["に"] := "ｉ", hash["ぬ"] := "１"
	hash["ね"] := "，", hash["の"] := "ｋ", hash["は"] := "ｆ", hash["ば"] := "ｆ゛"
	hash["ぱ"] := "ｆ゜", hash["ひ"] := "ｖ", hash["び"] := "ｖ゛", hash["ぴ"] := "ｖ゜"
	hash["ふ"] := "２", hash["ぶ"] := "２゛", hash["ぷ"] := "２゜", hash["へ"] := "＾"
	hash["べ"] := "＾゛", hash["ぺ"] := "＾゜", hash["ほ"] := "－", hash["ぼ"] := "－゛"
	hash["ぽ"] := "－゜", hash["ま"] := "ｊ", hash["み"] := "ｎ", hash["む"] := "］"
	hash["め"] := "／", hash["も"] := "ｍ", hash["ゃ"] := "s７", hash["や"] := "７"
	hash["ゅ"] := "s８", hash["ゆ"] := "８", hash["ょ"] := "s９", hash["よ"] := "９"
	hash["ら"] := "ｏ", hash["り"] := "ｌ", hash["る"] := "．", hash["れ"] := "；"
	hash["ろ"] := "￥", hash["わ"] := "０", hash["を"] := "s０", hash["ん"] := "ｙ"
	hash["ゔ"] := "４゛", hash["、"] := "s，", hash["。"] := "s．", hash["．"] := "s．"
	hash["・"] := "s／", hash["「"] := "s゜", hash["」"] := "s］"
	hash["ァ"] := "s３", hash["ア"] := "３", hash["ィ"] := "sｅ", hash["イ"] := "ｅ"
	hash["ゥ"] := "s４", hash["ウ"] := "４", hash["ェ"] := "s５", hash["エ"] := "５"
	hash["ォ"] := "s６", hash["オ"] := "６", hash["カ"] := "ｔ", hash["ガ"] := "ｔ゛"
	hash["キ"] := "ｇ", hash["ギ"] := "ｇ゛", hash["ク"] := "ｈ", hash["グ"] := "ｈ゛"
	hash["ケ"] := "：", hash["ゲ"] := "：゛", hash["コ"] := "ｂ", hash["ゴ"] := "ｂ゛"
	hash["サ"] := "ｘ", hash["ザ"] := "ｘ゛", hash["シ"] := "ｄ", hash["ジ"] := "ｄ゛"
	hash["ス"] := "ｒ", hash["ズ"] := "ｒ゛", hash["セ"] := "ｐ", hash["ゼ"] := "ｐ゛"
	hash["ソ"] := "ｃ", hash["ゾ"] := "ｃ゛", hash["タ"] := "ｑ", hash["ダ"] := "ｑ゛"
	hash["チ"] := "ａ", hash["ヂ"] := "ａ゛", hash["ッ"] := "sｚ", hash["ツ"] := "ｚ"
	hash["ヅ"] := "ｚ゛", hash["テ"] := "ｗ", hash["デ"] := "ｗ゛", hash["ト"] := "ｓ"
	hash["ド"] := "ｓ゛", hash["ナ"] := "ｕ", hash["ニ"] := "ｉ", hash["ヌ"] := "１"
	hash["ネ"] := "，", hash["ノ"] := "ｋ", hash["ハ"] := "ｆ", hash["バ"] := "ｆ゛"
	hash["パ"] := "ｆ゜", hash["ヒ"] := "ｖ", hash["ビ"] := "ｖ゛", hash["ピ"] := "ｖ゜"
	hash["フ"] := "２", hash["ブ"] := "２゛", hash["プ"] := "２゜", hash["ヘ"] := "＾"
	hash["ベ"] := "＾゛", hash["ペ"] := "＾゜", hash["ホ"] := "－", hash["ボ"] := "－゛"
	hash["ポ"] := "－゜", hash["マ"] := "ｊ", hash["ミ"] := "ｎ", hash["ム"] := "］"
	hash["メ"] := "／", hash["モ"] := "ｍ", hash["ャ"] := "s７", hash["ヤ"] := "７"
	hash["ュ"] := "s８", hash["ユ"] := "８", hash["ョ"] := "s９", hash["ヨ"] := "９"
	hash["ラ"] := "ｏ", hash["リ"] := "ｌ", hash["ル"] := "．", hash["レ"] := "；"
	hash["ロ"] := "￥", hash["ワ"] := "０", hash["ヲ"] := "s０", hash["ン"] := "ｙ"
	hash["ヴ"] := "４゛"
	return hash
}

MakeDakuonSurfaceHash() {
	hash := Map()
	hash["う"] := "ゔ", hash["ぅ"] := "ゔ", hash["か"] := "が", hash["き"] := "ぎ"
	hash["く"] := "ぐ", hash["け"] := "げ", hash["こ"] := "ご", hash["さ"] := "ざ"
	hash["し"] := "じ", hash["す"] := "ず", hash["せ"] := "ぜ", hash["そ"] := "ぞ"
	hash["た"] := "だ", hash["ち"] := "ぢ", hash["つ"] := "づ", hash["っ"] := "づ"
	hash["て"] := "で", hash["と"] := "ど", hash["は"] := "ば", hash["ひ"] := "び"
	hash["ふ"] := "ぶ", hash["へ"] := "べ", hash["ほ"] := "ぼ", hash["ぱ"] := "ば"
	hash["ぴ"] := "び", hash["ぷ"] := "ぶ", hash["ぺ"] := "べ", hash["ぽ"] := "ぼ"
	hash["ゔ"] := "う", hash["が"] := "か", hash["ぎ"] := "き", hash["ぐ"] := "く"
	hash["げ"] := "け", hash["ご"] := "こ", hash["ざ"] := "さ", hash["じ"] := "し"
	hash["ず"] := "す", hash["ぜ"] := "せ", hash["ぞ"] := "そ", hash["だ"] := "た"
	hash["ぢ"] := "ち", hash["づ"] := "つ", hash["で"] := "て", hash["ど"] := "と"
	hash["ば"] := "は", hash["び"] := "ひ", hash["ぶ"] := "ふ", hash["べ"] := "へ"
	hash["ぼ"] := "ほ"
	return hash
}

MakeHanDakuonSurfaceHash() {
	hash := Map()
	hash["は"] := "ぱ", hash["ひ"] := "ぴ", hash["ふ"] := "ぷ", hash["へ"] := "ぺ", hash["ほ"] := "ぽ"
	hash["ば"] := "ぱ", hash["び"] := "ぴ", hash["ぶ"] := "ぷ", hash["べ"] := "ぺ", hash["ぼ"] := "ぽ"
	hash["ぱ"] := "は", hash["ぴ"] := "ひ", hash["ぷ"] := "ふ", hash["ぺ"] := "へ", hash["ぽ"] := "ほ"
	return hash
}

MakeYouonSurfaceHash() {
	hash := Map()
	hash["あ"] := "ぁ", hash["い"] := "ぃ", hash["う"] := "ぅ", hash["ゔ"] := "ぅ"
	hash["え"] := "ぇ", hash["お"] := "ぉ", hash["か"] := "ゕ", hash["が"] := "ゕ"
	hash["け"] := "ゖ", hash["げ"] := "ゖ", hash["つ"] := "っ", hash["づ"] := "っ"
	hash["や"] := "ゃ", hash["ゆ"] := "ゅ", hash["よ"] := "ょ", hash["わ"] := "ゎ"
	hash["ぁ"] := "あ", hash["ぃ"] := "い", hash["ぅ"] := "う", hash["ぇ"] := "え"
	hash["ぉ"] := "お", hash["ゕ"] := "か", hash["ゖ"] := "け", hash["っ"] := "つ"
	hash["ゃ"] := "や", hash["ゅ"] := "ゆ", hash["ょ"] := "よ", hash["ゎ"] := "わ"
	return hash
}

MakeCorrectSurfaceHash() {
	hash := Map()
	hash["あ"] := "ぁ", hash["ぁ"] := "あ", hash["い"] := "ぃ", hash["ぃ"] := "い"
	hash["う"] := "ゔ", hash["ゔ"] := "ぅ", hash["ぅ"] := "う", hash["ぇ"] := "え"
	hash["え"] := "ぇ", hash["ぉ"] := "お", hash["お"] := "ぉ", hash["か"] := "が"
	hash["が"] := "ゕ", hash["ゕ"] := "か", hash["き"] := "ぎ", hash["ぎ"] := "き"
	hash["く"] := "ぐ", hash["ぐ"] := "く", hash["け"] := "げ", hash["げ"] := "ゖ"
	hash["ゖ"] := "け", hash["こ"] := "ご", hash["ご"] := "こ", hash["さ"] := "ざ"
	hash["ざ"] := "さ", hash["し"] := "じ", hash["じ"] := "し", hash["す"] := "ず"
	hash["ず"] := "す", hash["せ"] := "ぜ", hash["ぜ"] := "せ", hash["そ"] := "ぞ"
	hash["ぞ"] := "そ", hash["た"] := "だ", hash["だ"] := "た", hash["ち"] := "ぢ"
	hash["ぢ"] := "ち", hash["つ"] := "づ", hash["づ"] := "っ", hash["っ"] := "つ"
	hash["て"] := "で", hash["で"] := "て", hash["と"] := "ど", hash["ど"] := "と"
	hash["は"] := "ぱ", hash["ぱ"] := "ば", hash["ば"] := "は", hash["ひ"] := "ぴ"
	hash["ぴ"] := "び", hash["び"] := "ひ", hash["ふ"] := "ぷ", hash["ぷ"] := "ぶ"
	hash["ぶ"] := "ふ", hash["へ"] := "ぺ", hash["ぺ"] := "べ", hash["べ"] := "へ"
	hash["ほ"] := "ぽ", hash["ぽ"] := "ぼ", hash["ぼ"] := "ほ", hash["や"] := "ゃ"
	hash["ゃ"] := "や", hash["ゆ"] := "ゅ", hash["ゅ"] := "ゆ", hash["よ"] := "ょ"
	hash["ょ"] := "よ", hash["ゎ"] := "わ", hash["わ"] := "ゎ"
	return hash
}

MakeRomaji2SurfaceHash() {
	hash := Map()
	hash["ｌａ"] := "ぁ", hash["ｘａ"] := "ぁ", hash["ａ"] := "あ", hash["ｌｉ"] := "ぃ"
	hash["ｘｉ"] := "ぃ", hash["ｉ"] := "い", hash["ｌｕ"] := "ぅ", hash["ｘｕ"] := "ぅ"
	hash["ｕ"] := "う", hash["ｌｅ"] := "ぇ", hash["ｘｅ"] := "ぇ", hash["ｅ"] := "え"
	hash["ｌｏ"] := "ぉ", hash["ｘｏ"] := "ぉ", hash["ｏ"] := "お", hash["ｋａ"] := "か"
	hash["ｇａ"] := "が", hash["ｋｉ"] := "き", hash["ｇｉ"] := "ぎ", hash["ｋｕ"] := "く"
	hash["ｇｕ"] := "ぐ", hash["ｋｅ"] := "け", hash["ｇｅ"] := "げ", hash["ｋｏ"] := "こ"
	hash["ｇｏ"] := "ご", hash["ｓａ"] := "さ", hash["ｚａ"] := "ざ", hash["ｓｉ"] := "し"
	hash["ｚｉ"] := "じ", hash["ｓｕ"] := "す", hash["ｚｕ"] := "ず", hash["ｓｅ"] := "せ"
	hash["ｚｅ"] := "ぜ", hash["ｓｏ"] := "そ", hash["ｚｏ"] := "ぞ", hash["ｔａ"] := "た"
	hash["ｄａ"] := "だ", hash["ｔｉ"] := "ち", hash["ｄｉ"] := "ぢ", hash["ｌｔｕ"] := "っ"
	hash["ｘｔｕ"] := "っ", hash["ｔｕ"] := "つ", hash["ｄｕ"] := "づ", hash["ｔｅ"] := "て"
	hash["ｄｅ"] := "で", hash["ｔｏ"] := "と", hash["ｄｏ"] := "ど", hash["ｎａ"] := "な"
	hash["ｎｉ"] := "に", hash["ｎｕ"] := "ぬ", hash["ｎｅ"] := "ね", hash["ｎｏ"] := "の"
	hash["ｈａ"] := "は", hash["ｂａ"] := "ば", hash["ｐａ"] := "ぱ", hash["ｈｉ"] := "ひ"
	hash["ｂｉ"] := "び", hash["ｐｉ"] := "ぴ", hash["ｆｕ"] := "ふ", hash["ｈｕ"] := "ふ"
	hash["ｂｕ"] := "ぶ", hash["ｐｕ"] := "ぷ", hash["ｈｅ"] := "へ", hash["ｂｅ"] := "べ"
	hash["ｐｅ"] := "ぺ", hash["ｈｏ"] := "ほ", hash["ｂｏ"] := "ぼ", hash["ｐｏ"] := "ぽ"
	hash["ｍａ"] := "ま", hash["ｍｉ"] := "み", hash["ｍｕ"] := "む", hash["ｍｅ"] := "め"
	hash["ｍｏ"] := "も", hash["ｌｙａ"] := "ゃ", hash["ｘｙａ"] := "ゃ", hash["ｙａ"] := "や"
	hash["ｌｙｕ"] := "ゅ", hash["ｘｙｕ"] := "ゅ", hash["ｙｕ"] := "ゆ", hash["ｌｙｏ"] := "ょ"
	hash["ｘｙｏ"] := "ょ", hash["ｙｏ"] := "よ", hash["ｒａ"] := "ら", hash["ｒｉ"] := "り"
	hash["ｒｕ"] := "る", hash["ｒｅ"] := "れ", hash["ｒｏ"] := "ろ", hash["ｌｗａ"] := "ゎ"
	hash["ｘｗａ"] := "ゎ", hash["ｗａ"] := "わ", hash["ｗｉ"] := "うぃ", hash["ｗｙｉ"] := "ゐ"
	hash["ｗｅ"] := "うぇ", hash["ｗｙｅ"] := "ゑ", hash["ｗｏ"] := "を", hash["ｎｎ"] := "ん"
	hash["ｖｕ"] := "ヴ", hash["ｌｋａ"] := "ゕ", hash["ｘｋｅ"] := "ゖ"
	hash["ｆａ"] := "ふぁ", hash["ｆｉ"] := "ふぃ", hash["ｆｅ"] := "ふぇ", hash["ｆｏ"] := "ふぉ"
	hash["ｑａ"] := "くぁ", hash["ｑｉ"] := "くぃ", hash["ｑｕ"] := "く", hash["ｑｅ"] := "くぇ", hash["ｑｏ"] := "くぉ"
	hash["ｃａ"] := "か", hash["ｃｉ"] := "し", hash["ｃｕ"] := "く", hash["ｃｅ"] := "せ", hash["ｃｏ"] := "こ"
	hash["ｋｙａ"] := "きゃ", hash["ｋｙｉ"] := "きぃ", hash["ｋｙｕ"] := "きゅ", hash["ｋｙｅ"] := "きぇ", hash["ｋｙｏ"] := "きょ"
	hash["ｇｙａ"] := "ぎゃ", hash["ｇｙｉ"] := "ぎぃ", hash["ｇｙｕ"] := "ぎゅ", hash["ｇｙｅ"] := "ぎぇ", hash["ｇｙｏ"] := "ぎょ"
	hash["ｓｙａ"] := "しゃ", hash["ｓｙｉ"] := "しぃ", hash["ｓｙｕ"] := "しゅ", hash["ｓｙｅ"] := "しぇ", hash["ｓｙｏ"] := "しょ"
	hash["ｓｈａ"] := "しゃ", hash["ｓｈｉ"] := "し", hash["ｓｈｕ"] := "しゅ", hash["ｓｈｅ"] := "しぇ", hash["ｓｈｏ"] := "しょ"
	hash["ｚｙａ"] := "じゃ", hash["ｚｙｉ"] := "じぃ", hash["ｚｙｕ"] := "じゅ", hash["ｚｙｅ"] := "じぇ", hash["ｚｙｏ"] := "じょ"
	hash["ｊｙａ"] := "じゃ", hash["ｊｙｉ"] := "じぃ", hash["ｊｙｕ"] := "じゅ", hash["ｊｙｅ"] := "じぇ", hash["ｊｙｏ"] := "じょ"
	hash["ｔｈａ"] := "てゃ", hash["ｔｈｉ"] := "てぃ", hash["ｔｈｕ"] := "てゅ", hash["ｔｈｅ"] := "てぇ", hash["ｔｈｏ"] := "てょ"
	hash["ｔｙａ"] := "ちゃ", hash["ｔｙｉ"] := "ちぃ", hash["ｔｙｕ"] := "ちゅ", hash["ｔｙｅ"] := "ちぇ", hash["ｔｙｏ"] := "ちょ"
	hash["ｄｙａ"] := "ぢゃ", hash["ｄｙｉ"] := "ぢぃ", hash["ｄｙｕ"] := "ぢゅ", hash["ｄｙｅ"] := "ぢぇ", hash["ｄｙｏ"] := "ぢょ"
	hash["ｎｙａ"] := "にゃ", hash["ｎｙｉ"] := "にぃ", hash["ｎｙｕ"] := "にゅ", hash["ｎｙｅ"] := "にぇ", hash["ｎｙｏ"] := "にょ"
	hash["ｄｈａ"] := "でゃ", hash["ｄｈｉ"] := "でぃ", hash["ｄｈｕ"] := "でゅ", hash["ｄｈｅ"] := "でぇ", hash["ｄｈｏ"] := "でょ"
	hash["ｂｙａ"] := "びゃ", hash["ｂｙｉ"] := "びぃ", hash["ｂｙｕ"] := "びゅ", hash["ｂｙｅ"] := "びぇ", hash["ｂｙｏ"] := "びょ"
	hash["ｈｙａ"] := "ひゃ", hash["ｈｙｉ"] := "ひぃ", hash["ｈｙｕ"] := "ひゅ", hash["ｈｙｅ"] := "ひぇ", hash["ｈｙｏ"] := "ひょ"
	hash["ｐｙａ"] := "ぴゃ", hash["ｐｙｉ"] := "ぴぃ", hash["ｐｙｕ"] := "ぴゅ", hash["ｐｙｅ"] := "ぴぇ", hash["ｐｙｏ"] := "ぴょ"
	hash["ｍｙａ"] := "みゃ", hash["ｍｙｉ"] := "みぃ", hash["ｍｙｕ"] := "みゅ", hash["ｍｙｅ"] := "みぇ", hash["ｍｙｏ"] := "みょ"
	hash["ｒｙａ"] := "りゃ", hash["ｒｙｉ"] := "りぃ", hash["ｒｙｕ"] := "りゅ", hash["ｒｙｅ"] := "りぇ", hash["ｒｙｏ"] := "りょ"
	hash["ｔｗａ"] := "とぁ", hash["ｔｗｉ"] := "とぃ", hash["ｔｗｕ"] := "とぅ", hash["ｔｗｅ"] := "とぇ", hash["ｔｗｏ"] := "とぉ"
	hash["ｄｗａ"] := "どぁ", hash["ｄｗｉ"] := "どぃ", hash["ｄｗｕ"] := "どぅ", hash["ｄｗｅ"] := "どぇ", hash["ｄｗｏ"] := "どぉ"
	hash["．"] := "。", hash["［"] := "「", hash["］"] := "」", hash["／"] := "・"
	return hash
}

MakeKeyAttribute3Hash() {
	keyAttribute3 := Map()
	Loop 16 {
		id := Format("H{:02d}", A_Index)
		keyAttribute3["AN" . id] := "T", keyAttribute3["AK" . id] := "T", keyAttribute3["AS" . id] := "T"
		keyAttribute3["RN" . id] := "T", keyAttribute3["RK" . id] := "T", keyAttribute3["RS" . id] := "T"
	}
	Loop 13 {
		id := Format("G{:02d}", A_Index)
		keyAttribute3["AN" . id] := "X", keyAttribute3["AK" . id] := "X", keyAttribute3["AS" . id] := "X"
		keyAttribute3["RN" . id] := "X", keyAttribute3["RK" . id] := "X", keyAttribute3["RS" . id] := "X"
	}
	keyAttribute3["ANF00"] := "X", keyAttribute3["AKF00"] := "X", keyAttribute3["ASF00"] := "X"
	keyAttribute3["RNF00"] := "X", keyAttribute3["RKF00"] := "X", keyAttribute3["RSF00"] := "X"
	Loop 12 {
		id := Format("F{:02d}", A_Index)
		keyAttribute3["AN" . id] := "", keyAttribute3["AK" . id] := "", keyAttribute3["AS" . id] := ""
		keyAttribute3["RN" . id] := "", keyAttribute3["RK" . id] := "", keyAttribute3["RS" . id] := ""
	}
	
	keyAttribute3["ANE00"] := "X", keyAttribute3["AKE00"] := "X", keyAttribute3["ASE00"] := "X"
	keyAttribute3["RNE00"] := "X", keyAttribute3["RKE00"] := "X", keyAttribute3["RSE00"] := "X"
	Loop 14 {
		if (A_Index == 14) {
			id := "E14"
		} else {
			id := Format("E{:02d}", A_Index)
			keyAttribute3["AN" . id] := "M", keyAttribute3["AK" . id] := "M", keyAttribute3["AS" . id] := "M"
			keyAttribute3["RN" . id] := "M", keyAttribute3["RK" . id] := "M", keyAttribute3["RS" . id] := "M"
		}
	}
	keyAttribute3["ANE14"] := "M", keyAttribute3["AKE14"] := "M", keyAttribute3["ASE14"] := "M"
	keyAttribute3["RNE14"] := "M", keyAttribute3["RKE14"] := "M", keyAttribute3["RSE14"] := "M"

	keyAttribute3["AND00"] := "X", keyAttribute3["AKD00"] := "X", keyAttribute3["ASD00"] := "X"
	keyAttribute3["RND00"] := "X", keyAttribute3["RKD00"] := "X", keyAttribute3["RSD00"] := "X"
	Loop 12 {
		id := Format("D{:02d}", A_Index)
		keyAttribute3["AN" . id] := "M", keyAttribute3["AK" . id] := "M", keyAttribute3["AS" . id] := "M"
		keyAttribute3["RN" . id] := "M", keyAttribute3["RK" . id] := "M", keyAttribute3["RS" . id] := "M"
	}
	
	Loop 12 {
		id := Format("C{:02d}", A_Index)
		keyAttribute3["AN" . id] := "M", keyAttribute3["AK" . id] := "M", keyAttribute3["AS" . id] := "M"
		keyAttribute3["RN" . id] := "M", keyAttribute3["RK" . id] := "M", keyAttribute3["RS" . id] := "M"
	}
	keyAttribute3["ANC13"] := "X", keyAttribute3["AKC13"] := "X", keyAttribute3["ASC13"] := "X"
	keyAttribute3["RNC13"] := "X", keyAttribute3["RKC13"] := "X", keyAttribute3["RSC13"] := "X"
	
	Loop 11 {
		id := Format("B{:02d}", A_Index)
		keyAttribute3["AN" . id] := "M", keyAttribute3["AK" . id] := "M", keyAttribute3["AS" . id] := "M"
		keyAttribute3["RN" . id] := "M", keyAttribute3["RK" . id] := "M", keyAttribute3["RS" . id] := "M"
	}

	keyAttribute3["ANA00"] := "X", keyAttribute3["AKA00"] := "X", keyAttribute3["ASA00"] := "X"
	keyAttribute3["RNA00"] := "X", keyAttribute3["RKA00"] := "X", keyAttribute3["RSA00"] := "X"
	keyAttribute3["ANA01"] := "X", keyAttribute3["AKA01"] := "X", keyAttribute3["ASA01"] := "X"
	keyAttribute3["RNA01"] := "X", keyAttribute3["RKA01"] := "X", keyAttribute3["RSA01"] := "X"
	keyAttribute3["ANA02"] := "X", keyAttribute3["AKA02"] := "X", keyAttribute3["ASA02"] := "X"
	keyAttribute3["RNA02"] := "X", keyAttribute3["RKA02"] := "X", keyAttribute3["RSA02"] := "X"
	keyAttribute3["ANA03"] := "X", keyAttribute3["AKA03"] := "X", keyAttribute3["ASA03"] := "X"
	keyAttribute3["RNA03"] := "X", keyAttribute3["RKA03"] := "X", keyAttribute3["RSA03"] := "X"
	keyAttribute3["ANA04"] := "X", keyAttribute3["AKA04"] := "X", keyAttribute3["ASA04"] := "X"
	keyAttribute3["RNA04"] := "X", keyAttribute3["RKA04"] := "X", keyAttribute3["RSA04"] := "X"
	keyAttribute3["ANA05"] := "X", keyAttribute3["AKA05"] := "X", keyAttribute3["ASA05"] := "X"
	keyAttribute3["RNA05"] := "X", keyAttribute3["RKA05"] := "X", keyAttribute3["RSA05"] := "X"
	keyAttribute3["ANA06"] := "X", keyAttribute3["AKA06"] := "X", keyAttribute3["ASA06"] := "X"
	keyAttribute3["RNA06"] := "X", keyAttribute3["RKA06"] := "X", keyAttribute3["RSA06"] := "X"
	keyAttribute3["ANA07"] := "",  keyAttribute3["AKA07"] := "",  keyAttribute3["ASA07"] := ""
	keyAttribute3["RNA07"] := "",  keyAttribute3["RKA07"] := "",  keyAttribute3["RSA07"] := ""
	keyAttribute3["ANA08"] := "",  keyAttribute3["AKA08"] := "",  keyAttribute3["ASA08"] := ""
	keyAttribute3["RNA08"] := "",  keyAttribute3["RKA08"] := "",  keyAttribute3["RSA08"] := ""
	keyAttribute3["ANA09"] := "",  keyAttribute3["AKA09"] := "",  keyAttribute3["ASA09"] := ""
	keyAttribute3["RNA09"] := "",  keyAttribute3["RKA09"] := "",  keyAttribute3["RSA09"] := ""
	keyAttribute3["ANA10"] := "",  keyAttribute3["AKA10"] := "",  keyAttribute3["ASA10"] := ""
	keyAttribute3["RNA10"] := "",  keyAttribute3["RKA10"] := "",  keyAttribute3["RSA10"] := ""
	keyAttribute3["ANA11"] := "",  keyAttribute3["AKA11"] := "",  keyAttribute3["ASA11"] := ""
	keyAttribute3["RNA11"] := "",  keyAttribute3["RKA11"] := "",  keyAttribute3["RSA11"] := ""
	keyAttribute3["ANA12"] := "X", keyAttribute3["AKA12"] := "X", keyAttribute3["ASA12"] := "X"
	keyAttribute3["RNA12"] := "X", keyAttribute3["RKA12"] := "X", keyAttribute3["RSA12"] := "X"
	keyAttribute3["ANA13"] := "A", keyAttribute3["AKA13"] := "A", keyAttribute3["ASA13"] := "A"
	keyAttribute3["RNA13"] := "A", keyAttribute3["RKA13"] := "A", keyAttribute3["RSA13"] := "A"
	keyAttribute3["ANA14"] := "B", keyAttribute3["AKA14"] := "B", keyAttribute3["ASA14"] := "B"
	keyAttribute3["RNA14"] := "B", keyAttribute3["RKA14"] := "B", keyAttribute3["RSA14"] := "B"
	keyAttribute3["ANA15"] := "C", keyAttribute3["AKA15"] := "C", keyAttribute3["ASA15"] := "C"
	keyAttribute3["RNA15"] := "C", keyAttribute3["RKA15"] := "C", keyAttribute3["RSA15"] := "C"
	keyAttribute3["ANA16"] := "D", keyAttribute3["AKA16"] := "D", keyAttribute3["ASA16"] := "D"
	keyAttribute3["RNA16"] := "D", keyAttribute3["RKA16"] := "D", keyAttribute3["RSA16"] := "D"
	return keyAttribute3
}

MakeKeyHookHash() {
	keyHook := Map()
	Loop 16
		keyHook[Format("H{:02d}", A_Index)] := "Off"
	Loop 13
		keyHook[Format("G{:02d}", A_Index)] := "Off"
	keyHook["F00"] := "Off"
	Loop 12
		keyHook[Format("F{:02d}", A_Index)] := "Off"
	keyHook["E00"] := "Off"
	Loop 14
		keyHook[Format("E{:02d}", A_Index)] := "Off"
	keyHook["D00"] := "Off"
	Loop 12
		keyHook[Format("D{:02d}", A_Index)] := "Off"
	Loop 13
		keyHook[Format("C{:02d}", A_Index)] := "Off"
	Loop 11
		keyHook[Format("B{:02d}", A_Index)] := "Off"
	keyHook["A00"] := "Off"
	Loop 16
		keyHook[Format("A{:02d}", A_Index)] := "Off"
	return keyHook
}

MakeKeyState() {
	keyState := Map()
	Loop 16
		keyState[Format("H{:02d}", A_Index)] := 0
	Loop 13
		keyState[Format("G{:02d}", A_Index)] := 0
	keyState["F00"] := 0
	Loop 12
		keyState[Format("F{:02d}", A_Index)] := 0
	keyState["E00"] := 0
	Loop 14
		keyState[Format("E{:02d}", A_Index)] := 0
	keyState["D00"] := 0
	Loop 12
		keyState[Format("D{:02d}", A_Index)] := 0
	Loop 13
		keyState[Format("C{:02d}", A_Index)] := 0
	Loop 11
		keyState[Format("B{:02d}", A_Index)] := 0
	keyState["A00"] := 0
	Loop 16
		keyState[Format("A{:02d}", A_Index)] := 0
	return keyState
}

MakekeyNameHash() {
	hash := Map()
	hash["H01"] := sc2scstr(GetKeySC("NumpadDiv")), hash["H02"] := sc2scstr(GetKeySC("NumpadMult"))
	hash["H03"] := sc2scstr(GetKeySC("NumpadAdd")), hash["H04"] := sc2scstr(GetKeySC("NumpadSub"))
	hash["H05"] := sc2scstr(GetKeySC("NumpadEnter")), hash["H06"] := sc2scstr(GetKeySC("Numpad0"))
	hash["H07"] := sc2scstr(GetKeySC("Numpad1")), hash["H08"] := sc2scstr(GetKeySC("Numpad2"))
	hash["H09"] := sc2scstr(GetKeySC("Numpad3")), hash["H10"] := sc2scstr(GetKeySC("Numpad4"))
	hash["H11"] := sc2scstr(GetKeySC("Numpad5")), hash["H12"] := sc2scstr(GetKeySC("Numpad6"))
	hash["H13"] := sc2scstr(GetKeySC("Numpad7")), hash["H14"] := sc2scstr(GetKeySC("Numpad8"))
	hash["H15"] := sc2scstr(GetKeySC("Numpad9")), hash["H16"] := sc2scstr(GetKeySC("NumpadDot"))

	hash["G01"] := "PrintScreen", hash["G02"] := "ScrollLock", hash["G03"] := "Pause"
	hash["G04"] := "Insert", hash["G05"] := "Home", hash["G06"] := "PgUp"
	hash["G07"] := "Delete", hash["G08"] := "End", hash["G09"] := "PgDn"
	hash["G10"] := "Up", hash["G11"] := "Left", hash["G12"] := "Down", hash["G13"] := "Right"

	hash["F00"] := "Esc", hash["F01"] := "F1", hash["F02"] := "F2", hash["F03"] := "F3"
	hash["F04"] := "F4", hash["F05"] := "F5", hash["F06"] := "F6", hash["F07"] := "F7"
	hash["F08"] := "F8", hash["F09"] := "F9", hash["F10"] := "F10", hash["F11"] := "F11"
	hash["F12"] := "F12"

	hash["E00"] := "sc029", hash["E01"] := "1", hash["E02"] := "2", hash["E03"] := "3"
	hash["E04"] := "4", hash["E05"] := "5", hash["E06"] := "6", hash["E07"] := "7"
	hash["E08"] := "8", hash["E09"] := "9", hash["E10"] := "0", hash["E11"] := "-"
	hash["E12"] := "^", hash["E13"] := "\", hash["E14"] := "Backspace"

	hash["D00"] := "Tab", hash["D01"] := "q", hash["D02"] := "w", hash["D03"] := "e"
	hash["D04"] := "r", hash["D05"] := "t", hash["D06"] := "y", hash["D07"] := "u"
	hash["D08"] := "i", hash["D09"] := "o", hash["D10"] := "p", hash["D11"] := "@", hash["D12"] := "["
	
	hash["C01"] := "a", hash["C02"] := "s", hash["C03"] := "d", hash["C04"] := "f"
	hash["C05"] := "g", hash["C06"] := "h", hash["C07"] := "j", hash["C08"] := "k"
	hash["C09"] := "l", hash["C10"] := ";", hash["C11"] := ":", hash["C12"] := "]"
	hash["C13"] := "Enter"

	hash["B01"] := "z", hash["B02"] := "x", hash["B03"] := "c", hash["B04"] := "v"
	hash["B05"] := "b", hash["B06"] := "n", hash["B07"] := "m", hash["B08"] := ","
	hash["B09"] := ".", hash["B10"] := "/", hash["B11"] := "\"
	
	hash["A00"] := "LCtrl", hash["A01"] := "sc07B", hash["A02"] := "Space"
	hash["A03"] := "sc079", hash["A04"] := "sc070", hash["A05"] := "RCtrl"
	hash["A06"] := "LShift", hash["A07"] := "LWin", hash["A08"] := "LAlt"
	hash["A09"] := "RAlt", hash["A10"] := "RWin", hash["A11"] := "AppsKey"
	hash["A12"] := "RShift"
	return hash
}

MakeVkeyHash(_keyName) {
	hash := Map()
	for k, v in _keyName {
		hash[k] := GetKeyVK(v)
	}
	return hash
}

MakeVkeyStrHash(_keyName) {
	hash := Map()
	for k, v in _keyName {
		hash[k] := vk2vkstr(GetKeyVK(v))
	}
	return hash
}

vk2vkstr(_vk) {
	if(_vk < 0x100) {
		return Format("vk{:02X}", _vk)
	}
	return ""
}

MakeScanCodeHash(_keyName) {
	hash := Map()
	hash["H01"] := sc2scstr(GetKeySC("NumpadDiv")), hash["H02"] := sc2scstr(GetKeySC("NumpadMult"))
	hash["H03"] := sc2scstr(GetKeySC("NumpadAdd")), hash["H04"] := sc2scstr(GetKeySC("NumpadSub"))
	hash["H05"] := sc2scstr(GetKeySC("NumpadEnter")), hash["H06"] := sc2scstr(GetKeySC("Numpad0"))
	hash["H07"] := sc2scstr(GetKeySC("Numpad1")), hash["H08"] := sc2scstr(GetKeySC("Numpad2"))
	hash["H09"] := sc2scstr(GetKeySC("Numpad3")), hash["H10"] := sc2scstr(GetKeySC("Numpad4"))
	hash["H11"] := sc2scstr(GetKeySC("Numpad5")), hash["H12"] := sc2scstr(GetKeySC("Numpad6"))
	hash["H13"] := sc2scstr(GetKeySC("Numpad7")), hash["H14"] := sc2scstr(GetKeySC("Numpad8"))
	hash["H15"] := sc2scstr(GetKeySC("Numpad9")), hash["H16"] := sc2scstr(GetKeySC("NumpadDot"))

	hash["G01"] := sc2scstr(GetKeySC("PrintScreen")), hash["G02"] := sc2scstr(GetKeySC("ScrollLock"))
	hash["G03"] := sc2scstr(GetKeySC("Pause")), hash["G04"] := sc2scstr(GetKeySC("Insert"))
	hash["G05"] := sc2scstr(GetKeySC("Home")), hash["G06"] := sc2scstr(GetKeySC("PgUp"))
	hash["G07"] := sc2scstr(GetKeySC("Delete")), hash["G08"] := sc2scstr(GetKeySC("End"))
	hash["G09"] := sc2scstr(GetKeySC("PgDn")), hash["G10"] := sc2scstr(GetKeySC("Up"))
	hash["G11"] := sc2scstr(GetKeySC("Left")), hash["G12"] := sc2scstr(GetKeySC("Down"))
	hash["G13"] := sc2scstr(GetKeySC("Right"))
	
	hash["F00"] := "sc001", hash["F01"] := "sc03B", hash["F02"] := "sc03C", hash["F03"] := "sc03D"
	hash["F04"] := "sc03E", hash["F05"] := "sc03F", hash["F06"] := "sc040", hash["F07"] := "sc041"
	hash["F08"] := "sc042", hash["F09"] := "sc043", hash["F10"] := "sc044", hash["F11"] := "sc057"
	hash["F12"] := "sc058"

	hash["E00"] := "sc029", hash["E01"] := "sc002", hash["E02"] := "sc003", hash["E03"] := "sc004"
	hash["E04"] := "sc005", hash["E05"] := "sc006", hash["E06"] := "sc007", hash["E07"] := "sc008"
	hash["E08"] := "sc009", hash["E09"] := "sc00A", hash["E10"] := "sc00B", hash["E11"] := "sc00C"
	hash["E12"] := "sc00D", hash["E13"] := "sc07D", hash["E14"] := "sc00E"

	hash["D00"] := "sc00F", hash["D01"] := "sc010", hash["D02"] := "sc011", hash["D03"] := "sc012"
	hash["D04"] := "sc013", hash["D05"] := "sc014", hash["D06"] := "sc015", hash["D07"] := "sc016"
	hash["D08"] := "sc017", hash["D09"] := "sc018", hash["D10"] := "sc019", hash["D11"] := "sc01A"
	hash["D12"] := "sc01B"
	
	hash["C01"] := "sc01E", hash["C02"] := "sc01F", hash["C03"] := "sc020", hash["C04"] := "sc021"
	hash["C05"] := "sc022", hash["C06"] := "sc023", hash["C07"] := "sc024", hash["C08"] := "sc025"
	hash["C09"] := "sc026", hash["C10"] := "sc027", hash["C11"] := "sc028", hash["C12"] := "sc02B"
	hash["C13"] := "sc01C"
	
	hash["B01"] := "sc02C", hash["B02"] := "sc02D", hash["B03"] := "sc02E", hash["B04"] := "sc02F"
	hash["B05"] := "sc030", hash["B06"] := "sc031", hash["B07"] := "sc032", hash["B08"] := "sc033"
	hash["B09"] := "sc034", hash["B10"] := "sc035", hash["B11"] := "sc073"

	hash["A00"] := "sc01D", hash["A01"] := "sc07B", hash["A02"] := "sc039"
	hash["A03"] := "sc079", hash["A04"] := "sc070", hash["A05"] := "sc11D"
	hash["A06"] := "sc02A", hash["A07"] := "sc15B", hash["A08"] := "sc038"
	hash["A09"] := "sc138", hash["A10"] := "sc15C", hash["A11"] := "sc15D"
	hash["A12"] := "sc136"
	return hash
}

MakeCode2SimulPos() {
	hash := Map()
	hash["<1>"] := "E01", hash["<2>"] := "E02", hash["<3>"] := "E03", hash["<4>"] := "E04"
	hash["<5>"] := "E05", hash["<6>"] := "E06", hash["<7>"] := "E07", hash["<8>"] := "E08"
	hash["<9>"] := "E09", hash["<0>"] := "E10", hash["<->"] := "E11", hash["<^>"] := "E12", hash["<\>"] := "E13"

	hash["<q>"] := "D01", hash["<w>"] := "D02", hash["<e>"] := "D03", hash["<r>"] := "D04"
	hash["<t>"] := "D05", hash["<y>"] := "D06", hash["<u>"] := "D07", hash["<i>"] := "D08"
	hash["<o>"] := "D09", hash["<p>"] := "D10", hash["<@>"] := "D11", hash["<[>"] := "D12"

	hash["<a>"] := "C01", hash["<s>"] := "C02", hash["<d>"] := "C03", hash["<f>"] := "C04"
	hash["<g>"] := "C05", hash["<h>"] := "C06", hash["<j>"] := "C07", hash["<k>"] := "C08"
	hash["<l>"] := "C09", hash["<;>"] := "C10", hash["<:>"] := "C11", hash["<]>"] := "C12"

	hash["<z>"] := "B01", hash["<x>"] := "B02", hash["<c>"] := "B03", hash["<v>"] := "B04"
	hash["<b>"] := "B05", hash["<n>"] := "B06", hash["<m>"] := "B07", hash["<,>"] := "B08"
	hash["<.>"] := "B09", hash["</>"] := "B10", hash["<\>"] := "B11"

	hash["{1}"] := "E01", hash["{2}"] := "E02", hash["{3}"] := "E03", hash["{4}"] := "E04"
	hash["{5}"] := "E05", hash["{6}"] := "E06", hash["{7}"] := "E07", hash["{8}"] := "E08"
	hash["{9}"] := "E09", hash["{0}"] := "E10", hash["{-}"] := "E11", hash["{^}"] := "E12", hash["{\}"] := "E13"

	hash["{q}"] := "D01", hash["{w}"] := "D02", hash["{e}"] := "D03", hash["{r}"] := "D04"
	hash["{t}"] := "D05", hash["{y}"] := "D06", hash["{u}"] := "D07", hash["{i}"] := "D08"
	hash["{o}"] := "D09", hash["{p}"] := "D10", hash["{@}"] := "D11", hash["{[}"] := "D12"

	hash["{a}"] := "C01", hash["{s}"] := "C02", hash["{d}"] := "C03", hash["{f}"] := "C04"
	hash["{g}"] := "C05", hash["{h}"] := "C06", hash["{j}"] := "C07", hash["{k}"] := "C08"
	hash["{l}"] := "C09", hash["{;}"] := "C10", hash["{:}"] := "C11", hash["{]}"] := "C12"

	hash["{z}"] := "B01", hash["{x}"] := "B02", hash["{c}"] := "B03", hash["{v}"] := "B04"
	hash["{b}"] := "B05", hash["{n}"] := "B06", hash["{m}"] := "B07", hash["{,}"] := "B08"
	hash["{.}"] := "B09", hash["{/}"] := "B10", hash["{\}"] := "B11"
	return hash
}

MakeCode2ContPos() {
	hash := Map()
	hash["<1>"] := "E01", hash["<2>"] := "E02", hash["<3>"] := "E03", hash["<4>"] := "E04"
	hash["<5>"] := "E05", hash["<6>"] := "E06", hash["<7>"] := "E07", hash["<8>"] := "E08"
	hash["<9>"] := "E09", hash["<0>"] := "E10", hash["<->"] := "E11", hash["<^>"] := "E12", hash["<\>"] := "E13"

	hash["<q>"] := "D01", hash["<w>"] := "D02", hash["<e>"] := "D03", hash["<r>"] := "D04"
	hash["<t>"] := "D05", hash["<y>"] := "D06", hash["<u>"] := "D07", hash["<i>"] := "D08"
	hash["<o>"] := "D09", hash["<p>"] := "D10", hash["<@>"] := "D11", hash["<[>"] := "D12"

	hash["<a>"] := "C01", hash["<s>"] := "C02", hash["<d>"] := "C03", hash["<f>"] := "C04"
	hash["<g>"] := "C05", hash["<h>"] := "C06", hash["<j>"] := "C07", hash["<k>"] := "C08"
	hash["<l>"] := "C09", hash["<;>"] := "C10", hash["<:>"] := "C11", hash["<]>"] := "C12"

	hash["<z>"] := "B01", hash["<x>"] := "B02", hash["<c>"] := "B03", hash["<v>"] := "B04"
	hash["<b>"] := "B05", hash["<n>"] := "B06", hash["<m>"] := "B07", hash["<,>"] := "B08"
	hash["<.>"] := "B09", hash["</>"] := "B10", hash["<\>"] := "B11"

	hash["{1}"] := "501", hash["{2}"] := "502", hash["{3}"] := "503", hash["{4}"] := "504"
	hash["{5}"] := "505", hash["{6}"] := "506", hash["{7}"] := "507", hash["{8}"] := "508"
	hash["{9}"] := "509", hash["{0}"] := "510", hash["{-}"] := "511", hash["{^}"] := "512", hash["{\}"] := "513"

	hash["{q}"] := "401", hash["{w}"] := "402", hash["{e}"] := "403", hash["{r}"] := "404"
	hash["{t}"] := "405", hash["{y}"] := "406", hash["{u}"] := "407", hash["{i}"] := "408"
	hash["{o}"] := "409", hash["{p}"] := "410", hash["{@}"] := "411", hash["{[}"] := "412"

	hash["{a}"] := "301", hash["{s}"] := "302", hash["{d}"] := "303", hash["{f}"] := "304"
	hash["{g}"] := "305", hash["{h}"] := "306", hash["{j}"] := "307", hash["{k}"] := "308"
	hash["{l}"] := "309", hash["{;}"] := "310", hash["{:}"] := "311", hash["{]}"] := "312"

	hash["{z}"] := "201", hash["{x}"] := "202", hash["{c}"] := "203", hash["{v}"] := "204"
	hash["{b}"] := "205", hash["{n}"] := "206", hash["{m}"] := "207", hash["{,}"] := "208"
	hash["{.}"] := "209", hash["{/}"] := "210", hash["{\}"] := "211"
	return hash
}

sc2scstr(_sc) {
	if(_sc < 0x1000) {
		return Format("sc{:03X}", _sc)
	}
	return ""
}

MakeKeyLabelHash() {
	hash := Map()
	hash["A01"] := "無変換"
	hash["A02"] := " 空白 "
	hash["A03"] := " 変換 "
	hash["A04"] := "カ/ひ "
	return hash
}

MakeLayoutPosHash(scHash) {
	hash := Map()
	for k, v in scHash {
		hash["*" . v] := k
		hash["*" . v . " up"] := k
	}
	return hash
}

MakefkeyPosHash() {
	hash := Map()
	hash["Esc"] := "F00", hash["半角/全角"] := "E00", hash["BackSpace"] := "E14"
	hash["Tab"] := "D00", hash["Enter"] := "C13", hash["左Ctrl"] := "A00"
	hash["無変換"] := "A01", hash["Space"] := "A02", hash["Space&Shift"] := "A02"
	hash["変換"] := "A03", hash["カタカナ/ひらがな"] := "A04", hash["右Ctrl"] := "A05"
	hash["左Shift"] := "A06", hash["左Win"] := "A07", hash["左Alt"] := "A08"
	hash["右Alt"] := "A09", hash["右Win"] := "A10", hash["Applications"] := "A11"
	hash["右Shift"] := "A12"
	hash["F1"] := "F01", hash["F2"] := "F02", hash["F3"] := "F03", hash["F4"] := "F04"
	hash["F5"] := "F05", hash["F6"] := "F06", hash["F7"] := "F07", hash["F8"] := "F08"
	hash["F9"] := "F09", hash["F10"] := "F10", hash["F11"] := "F11", hash["F12"] := "F12"
	hash["PrintScreen"] := "G01", hash["ScrollLock"] := "G02", hash["Pause"] := "G03"
	hash["Insert"] := "G04", hash["Home"] := "G05", hash["PageUp"] := "G06"
	hash["Delete"] := "G07", hash["End"] := "G08", hash["PageDown"] := "G09"
	hash["上"] := "G10", hash["左"] := "G11", hash["下"] := "G12", hash["右"] := "G13"
	hash["NumpadDiv"] := "H01", hash["NumpadMult"] := "H02", hash["NumpadAdd"] := "H03"
	hash["NumpadSub"] := "H04", hash["NumpadEnter"] := "H05", hash["Numpad0"] := "H06"
	hash["Numpad1"] := "H07", hash["Numpad2"] := "H08", hash["Numpad3"] := "H09"
	hash["Numpad4"] := "H10", hash["Numpad5"] := "H11", hash["Numpad6"] := "H12"
	hash["Numpad7"] := "H13", hash["Numpad8"] := "H14", hash["Numpad9"] := "H15"
	hash["NumpadDot"] := "H16", hash["NumpadIns"] := "H06", hash["NumpadEnd"] := "H07"
	hash["NumpadDown"] := "H08", hash["NumpadPgUp"] := "H09", hash["NumpadLeft"] := "H10"
	hash["NumpadClear"] := "H11", hash["NumpadRight"] := "H12", hash["NumpadHome"] := "H13"
	hash["NumpadUp"] := "H14", hash["NumpadPgUp"] := "H15", hash["NumpadDel"] := "H16"
	hash["拡張1"] := "A13", hash["拡張2"] := "A14", hash["拡張3"] := "A15", hash["拡張4"] := "A16"
	return hash
}

Makefkey2NameHash() {
	hash := Map()
	hash["Esc"] := "Escape", hash["半角/全角"] := "sc029", hash["BackSpace"] := "Backspace"
	hash["Tab"] := "Tab", hash["Enter"] := "Enter", hash["左Ctrl"] := "LCtrl"
	hash["無変換"] := "sc07B", hash["Space"] := "Space", hash["Space&Shift"] := "Space"
	hash["変換"] := "sc079", hash["カタカナ/ひらがな"] := "sc070", hash["右Ctrl"] := "RCtrl"
	hash["左Shift"] := "LShift", hash["左Win"] := "LWin", hash["左Alt"] := "LAlt"
	hash["右Alt"] := "RAlt", hash["右Win"] := "RWin", hash["Applications"] := "AppsKey"
	hash["右Shift"] := "RShift"
	hash["F1"] := "F1", hash["F2"] := "F2", hash["F3"] := "F3", hash["F4"] := "F4"
	hash["F5"] := "F5", hash["F6"] := "F6", hash["F7"] := "F7", hash["F8"] := "F8"
	hash["F9"] := "F9", hash["F10"] := "F10", hash["F11"] := "F11", hash["F12"] := "F12"
	hash["PrintScreen"] := "PrintScreen", hash["ScrollLock"] := "ScrollLock", hash["Pause"] := "Pause"
	hash["Insert"] := "Insert", hash["Home"] := "Home", hash["PageUp"] := "PgUp"
	hash["Delete"] := "Delete", hash["End"] := "End", hash["PageDown"] := "PgDn"
	hash["上"] := "Up", hash["左"] := "Left", hash["下"] := "Down", hash["右"] := "Right"
	hash["NumpadDiv"] := "NumpadDiv", hash["NumpadMult"] := "NumpadMult", hash["NumpadAdd"] := "NumpadAdd"
	hash["NumpadSub"] := "NumpadSub", hash["NumpadEnter"] := "NumpadEnter", hash["Numpad0"] := "Numpad0"
	hash["Numpad1"] := "Numpad1", hash["Numpad2"] := "Numpad2", hash["Numpad3"] := "Numpad3"
	hash["Numpad4"] := "Numpad4", hash["Numpad5"] := "Numpad5", hash["Numpad6"] := "Numpad6"
	hash["Numpad7"] := "Numpad7", hash["Numpad8"] := "Numpad8", hash["Numpad9"] := "Numpad9"
	hash["NumpadDot"] := "NumpadDot", hash["NumpadIns"] := "NumpadIns", hash["NumpadEnd"] := "NumpadEnd"
	hash["NumpadDown"] := "NumpadDown", hash["NumpadPgUp"] := "NumpadPgUp", hash["NumpadLeft"] := "NumpadLeft"
	hash["NumpadClear"] := "NumpadClear", hash["NumpadRight"] := "NumpadRight", hash["NumpadHome"] := "NumpadHome"
	hash["NumpadUp"] := "NumpadUp", hash["NumpadPgUp"] := "NumpadPgUp", hash["NumpadDel"] := "NumpadDel"
	return hash
}

MakefkeyCodeHash(fkey2Name) {
	hash := Map()
	for k, v in fkey2Name {
		hash[k] := sc2scstr(GetKeySC(v))
	}
	return hash
}

MakefkeyVkeyHash(fkey2Name) {
	hash := Map()
	for k, v in fkey2Name {
		hash[k] := vk2vkstr(GetKeyVK(v))
	}
	return hash
}

MakeChr2vkeyHash() {
	hash := Map()
	hash["逃"] := "vk1B", hash["機1"] := "vk70", hash["機2"] := "vk71", hash["機3"] := "vk72"
	hash["機4"] := "vk73", hash["機5"] := "vk74", hash["機6"] := "vk75", hash["機7"] := "vk76"
	hash["機8"] := "vk77", hash["機9"] := "vk78", hash["機10"] := "vk79", hash["機11"] := "vk7A"
	hash["機12"] := "vk7B", hash["全"] := "vkF3", hash["１"] := "vk31", hash["２"] := "vk32"
	hash["３"] := "vk33", hash["４"] := "vk34", hash["５"] := "vk35", hash["６"] := "vk36"
	hash["７"] := "vk37", hash["８"] := "vk38", hash["９"] := "vk39", hash["０"] := "vk30"
	hash["－"] := "vkBD", hash["＾"] := "vkDE", hash["￥"] := "vkDC", hash["後"] := "vk08"
	hash["表"] := "vk09", hash["ｑ"] := "vk51", hash["ｗ"] := "vk57", hash["ｅ"] := "vk45"
	hash["ｒ"] := "vk52", hash["ｔ"] := "vk54", hash["ｙ"] := "vk59", hash["ｕ"] := "vk55"
	hash["ｉ"] := "vk49", hash["ｏ"] := "vk4F", hash["ｐ"] := "vk50", hash["＠"] := "vkC0"
	hash["［"] := "vkDB", hash["ａ"] := "vk41", hash["ｓ"] := "vk53", hash["ｄ"] := "vk44"
	hash["ｆ"] := "vk46", hash["ｇ"] := "vk47", hash["ｈ"] := "vk48", hash["ｊ"] := "vk4A"
	hash["ｋ"] := "vk4B", hash["ｌ"] := "vk4C", hash["；"] := "vkBB", hash["："] := "vkBA"
	hash["］"] := "vkDD", hash["入"] := "vk0D", hash["ｚ"] := "vk5A", hash["ｘ"] := "vk58"
	hash["ｃ"] := "vk43", hash["ｖ"] := "vk56", hash["ｂ"] := "vk42", hash["ｎ"] := "vk4E"
	hash["ｍ"] := "vk4D", hash["，"] := "vkBC", hash["．"] := "vkBE", hash["／"] := "vkBF"
	hash["￥"] := "vkE2", hash["空"] := "vk20", hash["日"] := "vkF2", hash["！"] := "vk31"
	hash["”"] := "vk32", hash["＃"] := "vk33", hash["＄"] := "vk34", hash["％"] := "vk35"
	hash["＆"] := "vk36", hash["’"] := "vk37", hash["（"] := "vk38", hash["）"] := "vk39"
	hash["＝"] := "vkBD", hash["～"] := "vkDE", hash["｜"] := "vkDC", hash["Ｑ"] := "vk51"
	hash["Ｗ"] := "vk57", hash["Ｅ"] := "vk45", hash["Ｒ"] := "vk52", hash["Ｔ"] := "vk54"
	hash["Ｙ"] := "vk59", hash["Ｕ"] := "vk55", hash["Ｉ"] := "vk49", hash["Ｏ"] := "vk4F"
	hash["Ｐ"] := "vk50", hash["‘"] := "vkC0", hash["｛"] := "vkDB", hash["Ａ"] := "vk41"
	hash["Ｓ"] := "vk53", hash["Ｄ"] := "vk44", hash["Ｆ"] := "vk46", hash["Ｇ"] := "vk47"
	hash["Ｈ"] := "vk48", hash["Ｊ"] := "vk4A", hash["Ｋ"] := "vk4B", hash["Ｌ"] := "vk4C"
	hash["＋"] := "vkBB", hash["＊"] := "vkBA", hash["｝"] := "vkDD", hash["Ｚ"] := "vk5A"
	hash["Ｘ"] := "vk58", hash["Ｃ"] := "vk43", hash["Ｖ"] := "vk56", hash["Ｂ"] := "vk42"
	hash["Ｎ"] := "vk4E", hash["Ｍ"] := "vk4D", hash["＜"] := "vkBC", hash["＞"] := "vkBE"
	hash["？"] := "vkBF", hash["＿"] := "vkE2"
	return hash
}

MakeTenkeyHash() {
	hash := Map()
	hash["1" . sc2scstr(GetKeySC("NumpadDiv"))] := "NumpadDiv", hash["1" . sc2scstr(GetKeySC("NumpadMult"))] := "NumpadMult"
	hash["1" . sc2scstr(GetKeySC("NumpadAdd"))] := "NumpadAdd", hash["1" . sc2scstr(GetKeySC("NumpadSub"))] := "NumpadSub"
	hash["1" . sc2scstr(GetKeySC("NumpadEnter"))] := "HNumpadEnter", hash["1" . sc2scstr(GetKeySC("Numpad0"))] := "Numpad0"
	hash["1" . sc2scstr(GetKeySC("Numpad1"))] := "Numpad1", hash["1" . sc2scstr(GetKeySC("Numpad2"))] := "Numpad2"
	hash["1" . sc2scstr(GetKeySC("Numpad3"))] := "Numpad3", hash["1" . sc2scstr(GetKeySC("Numpad4"))] := "Numpad4"
	hash["1" . sc2scstr(GetKeySC("Numpad5"))] := "Numpad5", hash["1" . sc2scstr(GetKeySC("Numpad6"))] := "Numpad6"
	hash["1" . sc2scstr(GetKeySC("Numpad7"))] := "Numpad7", hash["1" . sc2scstr(GetKeySC("Numpad8"))] := "Numpad8"
	hash["1" . sc2scstr(GetKeySC("Numpad9"))] := "Numpad9", hash["1" . sc2scstr(GetKeySC("NumpadDot"))] := "NumpadDot"
	hash["0" . sc2scstr(GetKeySC("NumpadDiv"))] := "NumpadDiv", hash["0" . sc2scstr(GetKeySC("NumpadMult"))] := "NumpadMult"
	hash["0" . sc2scstr(GetKeySC("NumpadAdd"))] := "NumpadAdd", hash["0" . sc2scstr(GetKeySC("NumpadSub"))] := "NumpadSub"
	hash["0" . sc2scstr(GetKeySC("NumpadEnter"))] := "HNumpadEnter", hash["0" . sc2scstr(GetKeySC("NumpadIns"))] := "NumpadIns"
	hash["0" . sc2scstr(GetKeySC("NumpadEnd"))] := "NumpadEnd", hash["0" . sc2scstr(GetKeySC("NumpadDown"))] := "NumpadDown"
	hash["0" . sc2scstr(GetKeySC("NumpadPgUp"))] := "NumpadPgUp", hash["0" . sc2scstr(GetKeySC("NumpadLeft"))] := "NumpadLeft"
	hash["0" . sc2scstr(GetKeySC("NumpadClear"))] := "NumpadClear", hash["0" . sc2scstr(GetKeySC("NumpadRight"))] := "NumpadRight"
	hash["0" . sc2scstr(GetKeySC("NumpadHome"))] := "NumpadHome", hash["0" . sc2scstr(GetKeySC("NumpadUp"))] := "NumpadUp"
	hash["0" . sc2scstr(GetKeySC("NumpadPgUp"))] := "NumpadPgUp", hash["0" . sc2scstr(GetKeySC("NumpadDel"))] := "NumpadDel"
	return hash
}

MakeCtrlKeyHash() {
	hash := Map()
	hash["後"] := "Backspace", hash["逃"] := "Escape", hash["入"] := "Enter"
	hash["空"] := "Space", hash["消"] := "Delete", hash["挿"] := "Insert"
	hash["上"] := "Up", hash["左"] := "Left", hash["右"] := "Right", hash["下"] := "Down"
	hash["家"] := "Home", hash["終"] := "End", hash["前"] := "PgUp", hash["次"] := "PgDn"
	hash["表"] := "tab", hash["日"] := "vkF2sc070", hash["英"] := "vkF0sc03A"
	hash["変"] := "vk1Csc079", hash["換"] := "vk1Dsc07B"
	hash["機1"] := "sc03B", hash["機2"] := "sc03C", hash["機3"] := "sc03D", hash["機4"] := "sc03E"
	hash["機5"] := "sc03F", hash["機6"] := "sc040", hash["機7"] := "sc041", hash["機8"] := "sc042"
	hash["機9"] := "sc043", hash["機10"] := "sc044", hash["機11"] := "sc057", hash["機12"] := "sc058"
	return hash
}

MakeCtrlvKeyHash() {
	hash := Map()
	hash["vk03"] := "VK_CANCEL", hash["vk08"] := "VK_BACK", hash["vk09"] := "VK_TAB"
	hash["vk0D"] := "VK_RETURN", hash["vk10"] := "VK_SHIFT", hash["vk11"] := "VK_CONTROL"
	hash["vk12"] := "VK_MENU", hash["vk13"] := "VK_PAUSE", hash["vk14"] := "VK_CAPITAL"
	hash["vk15"] := "VK_KANA", hash["vk17"] := "VK_JUNJA", hash["vk18"] := "VK_FINAL"
	hash["vk19"] := "VK_KANJI", hash["vk1B"] := "VK_ESCAPE", hash["vk1C"] := "VK_CONVERT"
	hash["vk1D"] := "VK_NONCONVERT", hash["vk1E"] := "VK_ACCEPT", hash["vk1F"] := "VK_MODECHANGE"
	hash["vk21"] := "VK_PRIOR", hash["vk22"] := "VK_NEXT", hash["vk23"] := "VK_END"
	hash["vk24"] := "VK_HOME", hash["vk25"] := "VK_LEFT", hash["vk26"] := "VK_UP"
	hash["vk27"] := "VK_RIGHT", hash["vk28"] := "VK_DOWN", hash["vk29"] := "VK_SELECT"
	hash["vk2A"] := "VK_PRINT", hash["vk2B"] := "VK_EXECUTE", hash["vk2C"] := "VK_SNAPSHOT"
	hash["vk2D"] := "VK_INSERT", hash["vk2E"] := "VK_DELETE", hash["vk2F"] := "VK_HELP"
	hash["vk5B"] := "VK_LWIN", hash["vk5C"] := "VK_RWIN", hash["vk5D"] := "VK_APPS"
	hash["vk5F"] := "VK_SLEEP", hash["vk70"] := "VK_F1", hash["vk71"] := "VK_F2"
	hash["vk72"] := "VK_F3", hash["vk73"] := "VK_F4", hash["vk74"] := "VK_F5"
	hash["vk75"] := "VK_F6", hash["vk76"] := "VK_F7", hash["vk77"] := "VK_F8"
	hash["vk78"] := "VK_F9", hash["vk79"] := "VK_F10", hash["vk7A"] := "VK_F11"
	hash["vk7B"] := "VK_F12", hash["vk7C"] := "VK_F13", hash["vk7D"] := "VK_F14"
	hash["vk7E"] := "VK_F15", hash["vk7F"] := "VK_F16", hash["vk80"] := "VK_F17"
	hash["vk81"] := "VK_F18", hash["vk82"] := "VK_F19", hash["vk83"] := "VK_F20"
	hash["vk84"] := "VK_F21", hash["vk85"] := "VK_F22", hash["vk86"] := "VK_F23"
	hash["vk87"] := "VK_F24", hash["vk90"] := "VK_NUMLOCK", hash["vk91"] := "VK_SCROLL"
	hash["vkA0"] := "VK_LSHIFT", hash["vkA1"] := "VK_RSHIFT", hash["vkA2"] := "VK_LCONTROL"
	hash["vkA3"] := "VK_RCONTROL", hash["vkA4"] := "VK_LMENU", hash["vkA5"] := "VK_RMENU"
	hash["vkF0"] := "VK_OEM_ATTN", hash["vkF2"] := "VK_OEM_COPY", hash["vkF3"] := "VK_OEM_AUTO"
	hash["vkF5"] := "VK_OEM_BACKTAB"
	return hash
}

MakeCtrlScHash() {
	hash := Map()
	hash["sc00E"] := "Backspace", hash["sc00F"] := "Tab", hash["sc03A"] := "CapsLock"
	hash["sc01C"] := "Enter", hash["sc02A"] := "LSHIFT", hash["sc136"] := "RSHIFT"
	hash["sc01D"] := "LCTRL", hash["sc038"] := "LALT", hash["sc138"] := "RALT"
	hash["sc11D"] := "RCTRL", hash["sc152"] := "Insert", hash["sc153"] := "Delete"
	hash["sc14B"] := "L Arrow", hash["sc147"] := "Home", hash["sc14F"] := "End"
	hash["sc148"] := "Up Arrow", hash["sc150"] := "Dn Arrow", hash["sc149"] := "Page Up"
	hash["sc151"] := "Page Down", hash["sc14D"] := "R Arrow", hash["sc145"] := "Num Lock"
	hash["sc11C"] := "Numeric Enter", hash["sc001"] := "Esc", hash["sc03B"] := "F1"
	hash["sc03C"] := "F2", hash["sc03D"] := "F3", hash["sc03E"] := "F4"
	hash["sc03F"] := "F5", hash["sc040"] := "F6", hash["sc041"] := "F7"
	hash["sc042"] := "F8", hash["sc043"] := "F9", hash["sc044"] := "F10"
	hash["sc057"] := "F11", hash["sc058"] := "F12", hash["sc137"] := "PrintScreen"
	hash["sc046"] := "Scroll Lock", hash["sc045"] := "Pause", hash["sc15B"] := "Left Win"
	hash["sc05B"] := "Right Win", hash["sc15D"] := "Application", hash["sc070"] := "DBE_KATAKANA"
	hash["sc077"] := "DBE_SBCSCHAR", hash["sc079"] := "CONVERT", hash["sc07B"] := "NONCONVERT"
	return hash
}

MakeModifierHash() {
	hash := Map()
	hash["c"] := "^", hash["C"] := "^", hash["a"] := "!"
	hash["A"] := "!", hash["s"] := "+", hash["S"] := "+"
	hash["w"] := "#", hash["W"] := "#"
	return hash
}