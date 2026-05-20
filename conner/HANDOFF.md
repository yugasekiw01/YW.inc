# 🔔 Conner への引き継ぎ

**From**: Sakura  
**Date**: 2026-05-20  
**Priority**: 🔴 高

---

## タスク概要

**スプリント**: ui-differentiation-20260520  
**フェーズ**: 要件定義  
**タスクID**: 3f4afa8f-d4c9-460b-8472-0965f946fbc6

**タイトル**: カイダシ新UIフロー仕様策定

---

## 背景

カイダシのイベント作成フローが既存サービス「walica（ワリカ）」と酷似しており、著作権・商標権侵害のリスクがあります。

### 現状の問題点
- トップページでイベント名入力 → 作成ボタン → 成功モーダル → URL共有
- このフローが walica と同様で、UIの模倣と見られる可能性

### walica について
- 2018年から運営、月間40万ユーザーの人気サービス
- 割り勘計算に特化したブラウザアプリ
- 参考: https://walica.jp/

---

## あなたのミッション

### 1. 新UIフローの設計 ✨

**差別化のポイント**:
- 「買い出しリスト」機能を前面に（カイダシの本来の強み）
- 割り勘は補助機能として位置づけ
- walica とは異なる独自のユーザー体験

**検討してほしい方向性**:
- [ ] イベント作成を2ステップにする？（名前 → 詳細）
- [ ] 買い物リストのテンプレート機能
- [ ] QRコード生成の追加
- [ ] その他、Conner の提案

### 2. ワイヤーフレーム作成 📐

新しいUIの画面遷移・レイアウトを設計してください。

### 3. 受け入れ条件の定義 ✓

「このUIなら完成」という基準を明確に。

---

## 参考資料

### 現在のカイダシ実装
- **トップページ**: `C:\Users\yugas\Yuja-Wang\products\kaidashi\index.html`
- **公開URL**: https://kaidashi-lime.vercel.app

### スプリントドキュメント
- **詳細**: `C:\Users\yugas\Yuja-Wang\docs\sprints\ui-differentiation-20260520\README.md`

### プロセス
- **スプリントフロー**: `C:\Users\yugas\Yuja-Wang\docs\sprint-flow.md`
- **Agent Hub**: `C:\Users\yugas\Yuja-Wang\docs\agent-hub-usage.md`

---

## Agent Hub 連携

作業開始時・完了時にステータス更新を忘れずに：

```powershell
# 作業開始
$h = @{ "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlbWVwdW56eHJ2bXN2ampoc3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTk2NTcsImV4cCI6MjA5NDY3NTY1N30.AvfSOhXCQWk5TDzP0JaP_z54sonNpCwYlIOE2TXslCE"; "Content-Type" = "application/json" }
$body = '{"status":"running"}'
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_tasks?id=eq.3f4afa8f-d4c9-460b-8472-0965f946fbc6" -Method PATCH -Headers $h -Body $body

# 作業完了
$body = '{"status":"done","progress":100}'
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_tasks?id=eq.3f4afa8f-d4c9-460b-8472-0965f946fbc6" -Method PATCH -Headers $h -Body $body
```

---

## 期待する成果物

1. **UIフロー設計書**（markdown形式）
2. **ワイヤーフレーム**（テキストベースでもOK）
3. **受け入れ条件リスト**

成果物の保存場所: `docs/sprints/ui-differentiation-20260520/requirements.md`

---

## 並行作業

- **Tiara**: テストシナリオ策定中
- **Imai**: インフラ影響確認中

あなたの仕様が完成したら David（開発）に引き継ぎます。

---

**準備完了！頑張ってください 💪**

— Sakura
