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

## YW.inc 組織構成

| エージェント | 役割 | ディレクトリ |
|---|---|---|
| Sakura | 秘書 | sakura/ |
| Conner | コンサル | conner/ |
| David | 開発 | david/ |
| Tiara | テスト | tiara/ |
| Imai | 保守・インフラ | imai/ |
| Pino（予定） | 広告・Git関連 | pino/ |

## Products

### bbq-app
- パス: `products/bbq-app/`

#### Supabase
- URL: `https://jzyjarmagxvljraknbec.supabase.co`
- テーブル: `bbq_items`、`participants`、`bbq_config`

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
