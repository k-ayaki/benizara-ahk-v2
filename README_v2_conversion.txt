# AutoHotkey v1 -> v2 変換メモ

このフォルダの .ahk は、アップロードされた一式をベースに機械変換した v2 たたき台です。
そのままでは未変換箇所が残る可能性があります。特に次を重点確認してください。

1. Gosub / GoSub / ラベル呼び出し
   - v2 では関数化が基本です。
   - 例: `Gosub, Init` -> `Init()`
   - `Menu, Tray, Add, ..., Settings` のようなラベル参照も、関数参照へ置換が必要です。

2. GUI
   - v1 の `Gui, Add, ...` / `GuiControl` / `Gui, Submit` は、v2 では `myGui := Gui()` と
     コントロールオブジェクトを使う書き方へ全面移行が必要です。
   - `Settings7.ahk` と `Logs1.ahk` は手作業比率が高いです。

3. コマンド構文
   - `TrayTip, ...`, `MsgBox, ...`, `Run *RunAs ...`, `Process, Exist, ...` などは
     v2 関数構文へ最終調整が必要です。

4. 旧 Object()
   - 機械的に `Map()` へ変換していますが、
     配列用途なら `[]` のほうが自然な箇所があります。

5. ErrorLevel 依存
   - v2 の `ProcessExist()` などは戻り値を見る形へ変更が必要です。
   - 例: `pid := ProcessExist("yamabuki.exe")` のようにする。

6. 式展開・文字列連結
   - v1 の `%var%` ベースの箇所は残りやすいので、式として見直してください。

推奨順:
- SendOnHold.ahk
- KeyQueue.ahk
- Path.ahk / Objects.ahk / PfCount.ahk
- benizara190817a.ahk
- Settings7.ahk
- Logs1.ahk
