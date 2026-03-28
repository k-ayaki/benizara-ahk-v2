この版は AutoHotkey v2 用の「最小キーボードエンジン版」です。

実装済み
- 親指キー検出
  - 無変換(sc07B)
  - 変換(sc079)
  - Space
  - 設定の「無変換－変換 / 無変換－空白 / 空白－変換」を即時反映
- Pause / ScrollLock による一時停止切替
- 16ms タイマー監視
- トレイから状態表示

未実装
- 元の benizara190817a.ahk の本体入力変換ロジック
- SendOnHold / 文字同時打鍵 / レイアウト解釈本体
- GDI 配列プレビュー

主なファイル
- benizara190817a_v2.ahk : 最小エンジン版本体
- Settings7_v2.ahk      : v2 GUI 設定画面

補足
- 親指キー押下/解放や長押し状態は OutputDebug に出力します。
- Pause 中は親指キー状態をクリアします。
