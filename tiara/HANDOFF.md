# Tiara へのテスト依頼

**From**: David  
**Date**: 2026-05-20  
**Priority**: 高

---

## 概要

**カイダシ v3.7** の新UI実装が完了しました！
テストケースの確認・修繕とテスト実行をお願いします。

---

## 今回の変更点

### 1. トップページ（index.html）

#### 新機能
- **イラストエリア**: シーンに応じた絵文字がふわふわ浮かぶアニメーション
- **シーン選択チップ**: 
  - 日々の買い物（デフォルト）
  - BBQ
  - キャンプ
  - パーティー
  - ピクニック
  - その他
- **イベント作成後の遷移**: モーダルなしで直接イベントページへ

#### 変更点
- PC向けレスポンシブ対応（768px以上で拡大表示）
- フォント読み込み最適化（preconnect追加）
- `?reset=1` でlocalStorageクリア機能（テスト用）

### 2. イベントページ（app.html）

#### 新機能
- **ヘッダーメニュー**: `⋯`ボタンでドロップダウン
  - URLを共有
  - イベントを削除
- **イベントごとの名前入力**: 初めて参加するイベントでは名前入力モーダル表示（前回の名前がデフォルト）

#### 変更点
- 数量: デフォルト値「1」
- 単位: デフォルト「個」（選択肢: 個/g/ml）
- 削除・共有ボタンの重なり解消

---

## テスト対象シナリオ

### トップページ
1. [ ] シーン選択で絵文字が変わる
2. [ ] イベント名入力 → 作成 → イベントページへ遷移
3. [ ] 最近のイベント一覧から削除
4. [ ] 最近のイベントをタップで開く
5. [ ] PC表示でレイアウトが適切

### イベントページ - 名前入力
6. [ ] 初参加イベントで名前入力モーダル表示
7. [ ] 前回の名前がデフォルト入力されている
8. [ ] 参加済みイベントではモーダル非表示

### イベントページ - メニュー
9. [ ] `⋯`ボタンでメニュー表示
10. [ ] 「URLを共有」で共有/コピー
11. [ ] 「イベントを削除」で確認後削除

### イベントページ - 買い出しリスト
12. [ ] 品目追加（数量1、単位「個」がデフォルト）
13. [ ] チェックON/OFF
14. [ ] 削除
15. [ ] カテゴリ変更
16. [ ] ホシイ！投票

### イベントページ - 割り勘
17. [ ] 支払い追加
18. [ ] 精算計算
19. [ ] フィルター表示

---

## テスト環境

- **本番URL**: https://kaidashi-lime.vercel.app
- **リセットURL**: https://kaidashi-lime.vercel.app/?reset=1
- **バージョン**: v3.7

---

## 参照ファイル

- `products/kaidashi/index.html`
- `products/kaidashi/app.html`
- `products/kaidashi/sw.js`

---

## Agent Hub 連携

```powershell
$h = @{ "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlbWVwdW56eHJ2bXN2ampoc3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTk2NTcsImV4cCI6MjA5NDY3NTY1N30.AvfSOhXCQWk5TDzP0JaP_z54sonNpCwYlIOE2TXslCE"; "Content-Type" = "application/json" }

# 作業開始
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_status?agent_name=eq.tiara" -Method PATCH -Headers $h -Body '{"status":"busy"}'

# 作業完了
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_status?agent_name=eq.tiara" -Method PATCH -Headers $h -Body '{"status":"idle"}'
```

---

**よろしくお願いします！**

— David
