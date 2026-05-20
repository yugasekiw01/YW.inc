# YW.inc プロジェクト

## リモート開発環境

### スマホからアクセスする方法
- **Tailscale** が PC・スマホ両方にインストール済み（PC の Tailscale IP: `100.103.51.93`）
- **SSH**（再起動後に有効）でターミナル接続 → `claude` を実行
  - スマホアプリ: Termius 推奨
  - 接続先: `100.103.51.93`、ユーザー名: Windows ログインユーザー名
- **VS Code トンネル**（サービス登録済み・PC 起動で自動起動）
  - URL: https://vscode.dev/tunnel/yugapi/C:/Users/yugas/Yuja-Wang

### 再起動後にやること（初回のみ）
管理者 PowerShell で：
```powershell
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
```

## 開発フロー

機能単位のアジャイル × W モデル。詳細は [`docs/sprint-flow.md`](docs/sprint-flow.md) を参照。

## レート制限対策

Claude Code を長時間使うためのベストプラクティス：

- **定期的に `/compact` を実行**してコンテキストを圧縮
- **verbose mode off** で不要な出力を減らす（設定または `/config` で変更）
- 大きいファイルは `limit`/`offset` パラメータで部分読み込み
- 軽いタスクは Haiku や Sonnet を使う（Opus は重要な判断のみ）

## YW.inc 組織構成

| エージェント | 役割 | キャラクター | ディレクトリ |
|---|---|---|---|
| Sakura | 秘書 | - | sakura/ |
| Conner | コンサル | - | conner/ |
| David | 開発 | - | david/ |
| Tiara | テスト | - | tiara/ |
| Imai | 保守・インフラ | 26歳、ちょっとあほだけど信頼できる男友達 | imai/ |
| Pino（予定） | 広告・Git関連 | 子供のようなあどけなさがある弟的存在。好奇心を真っ直ぐに伝える子 | pino/ |

## Agent Hub（エージェント連携システム）

スマホからリアルタイムで全エージェントの進捗を確認できるダッシュボード。

- **アクセス**: claude-pwa-clientの📊ボタン
- **Supabase**: `pemepunzxrvmsvjjhsry` (yw-agent-hub)

### 必須ルール
各エージェントは作業時に以下を実行すること：
1. **作業開始時**: 自分のstatus → `busy`
2. **作業完了時**: 自分のstatus → `idle`
3. **タスク引き継ぎ時**: `agent_tasks`にレコード作成

詳細手順: [`docs/agent-hub-usage.md`](docs/agent-hub-usage.md)

## Products

### カイダシ（kaidashi）🛒
- パス: `products/kaidashi/`
- 公開URL: **https://kaidashi-lime.vercel.app**
- 用途: イベントごとの買い出しリスト＋ワリカン管理
- 特徴: リアルタイム更新、ログイン不要、誰でもイベント作成可能

#### Supabase
- Project Ref: `akovhthopauhmlbcjjfw`
- URL: `https://akovhthopauhmlbcjjfw.supabase.co`
- テーブル: `events`, `items`, `participants`, `warikan_entries`
- Realtime: 有効

#### デプロイ
- **本番**: Vercel（自動デプロイ）
- GitHub リポジトリ: https://github.com/yugasekiw01/YW.inc
- デプロイコマンド: `cd products/kaidashi && vercel --prod`

---

### bbq-app（ベータ版・非公開）
- パス: `products/bbq-app/`
- 用途: カイダシのベータ版（会社内BBQ用）

#### Supabase
- URL: `https://jzyjarmagxvljraknbec.supabase.co`
- テーブル: `bbq_items`, `participants`, `bbq_config`

#### デプロイ
- GitHub リポジトリ: https://github.com/yugasekiw01/YW.inc
- Netlify にデプロイ（products/bbq-app フォルダをドラッグ or GitHub 連携で自動）

## Git
```bash
cd C:\Users\yugas\Yuja-Wang
git add .
git commit -m "メッセージ"
git push
```
