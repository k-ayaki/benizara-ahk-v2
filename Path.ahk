;-----------------------------------------------------------------------
; ファイルパス関数群 (Path.ahk) (AHK v2版)
; SHLWAPI.DLL を使用したパス操作ライブラリ
;-----------------------------------------------------------------------
#Requires AutoHotkey v2.0
;=============================================================================
;   判定系 (存在チェック)
;=============================================================================
Path_FileExists(path) {
    return DllCall("shlwapi\PathFileExistsW", "Str", path, "Int")
}

Path_IsDirectory(path) {
    return DllCall("shlwapi\PathIsDirectoryW", "Str", path, "Int")
}

Path_IsUNCServerShare(path) {
    return DllCall("shlwapi\PathIsUNCServerShareW", "Str", path, "Int")
}

;=============================================================================
;   判定系 (文字列の記述ルール チェック)
;=============================================================================
Path_IsFileSpec(path) {
    return DllCall("shlwapi\PathIsFileSpecW", "Str", path, "Int")
}

Path_IsPrefix(prefix, path) {
    return DllCall("shlwapi\PathIsPrefixW", "Str", prefix, "Str", path, "Int")
}

Path_IsRelative(path) {
    return DllCall("shlwapi\PathIsRelativeW", "Str", path, "Int")
}

Path_IsRoot(path) {
    return DllCall("shlwapi\PathIsRootW", "Str", path, "Int")
}

Path_IsSameRoot(path1, path2) {
    return DllCall("shlwapi\PathIsSameRootW", "Str", path1, "Str", path2, "Int")
}

Path_IsURL(url) {
    return DllCall("shlwapi\PathIsURLW", "Str", url, "Int")
}

Path_IsUNC(path) {
    return DllCall("shlwapi\PathIsUNCW", "Str", path, "Int")
}

Path_IsUNCServer(path) {
    return DllCall("shlwapi\PathIsUNCServerW", "Str", path, "Int")
}

Path_MatchSpec(filename, spec) {
    return DllCall("shlwapi\PathMatchSpecW", "Str", filename, "Str", spec, "Int")
}

Path_GetCharType(c) {
    ; WCHAR は UShort型として扱い、Ord() で文字コードを渡します
    return DllCall("shlwapi\PathGetCharTypeW", "UShort", Ord(c), "UInt")
}

;=============================================================================
; 変換系 (Bufferオブジェクトを使用して安全にメモリ操作を行います)
;=============================================================================
Path_GetLongPathName(filePath) {
    buf := Buffer(1040, 0) ; 520文字 * 2バイト
    DllCall("GetLongPathNameW", "Str", filePath, "Ptr", buf, "UInt", 520)
    return StrGet(buf)
}

Path_GetShortPathName(filePath) {
    buf := Buffer(1040, 0)
    DllCall("GetShortPathNameW", "Str", filePath, "Ptr", buf, "UInt", 520)
    return StrGet(buf)
}

Path_SearchAndQualify(file) {
    buf := Buffer(1040, 0)
    DllCall("shlwapi\PathSearchAndQualifyW", "Str", file, "Ptr", buf, "UInt", 520)
    return StrGet(buf)
}

Path_AddBackslash(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathAddBackslashW", "Ptr", buf)
    return StrGet(buf)
}

Path_RemoveBackslash(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathRemoveBackslashW", "Ptr", buf)
    return StrGet(buf)
}

Path_RemoveBlanks(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathRemoveBlanksW", "Ptr", buf)
    return StrGet(buf)
}

Path_QuoteSpaces(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathQuoteSpacesW", "Ptr", buf)
    return StrGet(buf)
}

Path_UnquoteSpaces(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathUnquoteSpacesW", "Ptr", buf)
    return StrGet(buf)
}

Path_RenameExtension(path, ext) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    ext := ("." != SubStr(ext, 1, 1)) ? "." ext : ext
    DllCall("shlwapi\PathRenameExtensionW", "Ptr", buf, "Str", ext)
    return StrGet(buf)
}

;=============================================================================
; 抽出系
;=============================================================================
Path_StripToRoot(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathStripToRootW", "Ptr", buf)
    return StrGet(buf)
}

Path_GetDriveNumber(path) {
    return DllCall("shlwapi\PathGetDriveNumberW", "Str", path, "Int")
}

Path_FindFileName(path) {
    return DllCall("shlwapi\PathFindFileNameW", "Str", path, "Str")
}

Path_StripPath(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathStripPathW", "Ptr", buf)
    return StrGet(buf)
}

Path_RemoveFileSpec(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathRemoveFileSpecW", "Ptr", buf)
    return StrGet(buf)
}

Path_SkipRoot(path) {
    return DllCall("shlwapi\PathSkipRootW", "Str", path, "Str")
}

Path_FindExtension(path) {
    return DllCall("shlwapi\PathFindExtensionW", "Str", path, "Str")
}

Path_RemoveExtension(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathRemoveExtensionW", "Ptr", buf)
    return StrGet(buf)
}

Path_GetArgs(path) {
    return DllCall("shlwapi\PathGetArgsW", "Str", path, "Str")
}

Path_RemoveArgs(path) {
    buf := Buffer(1040, 0)
    StrPut(path, buf)
    DllCall("shlwapi\PathRemoveArgsW", "Ptr", buf)
    return StrGet(buf)
}

Path_CompactPathEx(path, maxLen) {
    buf := Buffer(1040, 0)
    DllCall("shlwapi\PathCompactPathExW", "Ptr", buf, "Str", path, "UInt", maxLen, "UInt", 0)
    return StrGet(buf)
}

Path_CommonPrefix(p1, p2) {
    buf := Buffer(1040, 0)
    DllCall("shlwapi\PathCommonPrefixW", "Str", p1, "Str", p2, "Ptr", buf)
    return StrGet(buf)
}

;=============================================================================
; 相対パス関連
;=============================================================================
Path_RelativePathTo(From, atrFrom, To, atrTo) {
    buf := Buffer(1040, 0)
    DllCall("shlwapi\PathRelativePathToW", "Ptr", buf, "Str", From, "UInt", atrFrom, "Str", To, "UInt", atrTo)
    return StrGet(buf)
}

Path_Combine(path, more) {
    buf := Buffer(1040, 0)
    DllCall("shlwapi\PathCombineW", "Ptr", buf, "Str", path, "Str", more)
    return StrGet(buf)
}

Path_Canonicalize(path) {
    buf := Buffer(1040, 0)
    DllCall("shlwapi\PathCanonicalizeW", "Ptr", buf, "Str", path)
    return StrGet(buf)
}

;=============================================================================
; AHKコマンド互換関数
;=============================================================================
; v2では参照渡しに & を使用します。また、UTF-16対応によりダメ文字問題は不要になりました。
Path_SplitPath(path, &OutFileName:="", &OutDir:="", &OutExtension:="", &OutNameNoExt:="", &OutDrive:="") {
    ; v2ネイティブのSplitPathを使用することで、完全かつ安全に処理できます
    SplitPath(path, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt, &OutDrive)
}