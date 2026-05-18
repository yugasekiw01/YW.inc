# エージェント連携システム インフラ要件

**担当**: Imai（保守・インフラ）  
**作成日**: 2026-05-18  
**対象**: `01_requirements.md`（David）、`01_requirements_conner.md`（Conner）

---

## 1. Supabaseプロジェクト判断: 新規プロジェクト推奨

### 現状

| プロジェクト | Ref | 用途 |
|---|---|---|
| kaidashi | `akovhthopauhmlbcjjfw` | 本番・ユーザー公開 |
| bbq-app | `jzyjarmagxvljraknbec` | ベータ・社内非公開 |

> Supabase 無料プランは **アクティブプロジェクト 2 個まで**。現在 2 個使用中。

### 判断: 新規プロジェクト作成 + bbq-app を pause

**理由:**

- エージェント連携は全プロダクトに横断するインフラ。kaidashi の DB に混在させると  
  「プロダクト用テーブル」と「社内インフラ用テーブル」が混在して管理が煩雑になる
- bbq-app は非公開ベータ段階なので pause しても実害がない
- 新規プロジェクトにすれば RLS・API キー・Realtime 設定が独立管理できる

**作業手順:**
```
1. Supabase ダッシュボードで bbq-app プロジェクトを pause
2. 新規プロジェクト「yw-agent-hub」を作成
3. .env に SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY を設定
```

---

## 2. テーブル設計レビュー

### 2-1. `agent_tasks` テーブル（改訂案）

Davidの原案 + Connerのフィードバック + Imaiの追加提案を統合。

| カラム | 型 | 変更 | 説明 |
|--------|-----|------|------|
| id | uuid | 原案通り | PK、`gen_random_uuid()` デフォルト |
| sprint_name | text | 原案通り | 例: `agent-orchestration-v1` |
| phase | text | 原案通り | W字フェーズ名 |
| from_agent | text | 原案通り | 依頼元（`user` も許容） |
| to_agent | text | 原案通り | 依頼先エージェント名 |
| task_type | text | 原案通り | `dev` / `test` / `deploy` / `review` |
| title | text | 原案通り | |
| description | text | 原案通り | 仕様書・テスト結果なども貼る |
| **priority** | text | **Conner追加** | `urgent` / `normal`、デフォルト `normal` |
| status | text | **`cancelled` 追加** | `pending` / `running` / `done` / `failed` / `cancelled` |
| progress | int | 原案通り | 0〜100 |
| output | text | 原案通り | 実行ログ |
| **error_message** | text | **Conner追加** | failed時の理由 |
| **parent_task_id** | uuid | **Imai追加** | W字の自動引き継ぎタスクで使う |
| **metadata** | jsonb | **Imai追加** | 添付ファイルパス等の拡張フィールド |
| created_at | timestamptz | 原案通り | `now()` デフォルト |
| updated_at | timestamptz | 原案通り | トリガーで自動更新 |

**推奨インデックス:**
```sql
CREATE INDEX ON agent_tasks (to_agent, status);      -- 担当エージェントのキュー取得
CREATE INDEX ON agent_tasks (sprint_name, phase);    -- ダッシュボードのフィルタリング
CREATE INDEX ON agent_tasks (created_at DESC);       -- 履歴表示
```

### 2-2. `agent_status` テーブル（改訂案）

Connerの `stale` 提案を採用し、判定ロジックを明確化。

| カラム | 型 | 変更 | 説明 |
|--------|-----|------|------|
| agent_name | text | 原案通り | PK |
| status | text | **`offline` → `stale` に変更** | `idle` / `busy` / `stale` |
| current_task_id | uuid | 原案通り | 実行中タスクへの FK |
| last_seen | timestamptz | 原案通り | エージェントの最終ハートビート |
| **updated_at** | timestamptz | **Imai追加** | status 変更日時 |

**`stale` の定義（実装時に決定）:**  
`last_seen` が **10 分以上**更新されない場合を `stale` とする（ダッシュボードで警告表示）。  
Supabase pg_cron で定期チェックするか、ダッシュボード側でクライアント判定する。

### 2-3. RLS ポリシー方針

| 操作 | 主体 | キー種別 |
|---|---|---|
| 読み取り（ダッシュボード表示） | 全員 | `anon key`（公開）|
| タスク作成・更新 | エージェント・ユーザー | `service_role key`（サーバーサイドのみ） |

> フロントエンドから直接更新する場合は anon key + RLS で行レベル制御。  
> エージェントからの更新は環境変数経由の service_role key を使う。

---

## 3. エージェント自動起動の実現方法

### 前提条件

- エージェントの実体 = `claude` CLI（セッション型、常駐しない）
- 起動環境 = Windows 11 PC（Tailscale 経由でスマホから接続可能）
- Connerの推奨通り、自動起動は **MVP-B（次スプリント）** で実装

### 方式比較

| 方式 | 仕組み | 遅延 | 難易度 | 推奨 |
|------|--------|------|--------|------|
| **A: Node.js daemon + Realtime** | Supabase Realtime を常時監視、タスク検知で `claude` 起動 | ほぼゼロ | 中 | **★ 推奨** |
| B: Windows Task Scheduler（ポーリング） | 30秒〜1分間隔で Supabase を polling | 30秒〜1分 | 低 | MVP-B の暫定案として |
| C: Supabase Edge Function + Webhook | DB trigger → Edge Function → PC の HTTP エンドポイント | ほぼゼロ | 高 | 不要 |
| D: GitHub Actions | DB trigger → Actions 起動 → cloud で実行 | 30秒〜2分 | 高 | 対象外（ローカルFS非対応） |

### 推奨: 方式A（Node.js daemon）の設計

**配置場所:** `imai/orchestrator/`

```
imai/orchestrator/
├── index.js          # Supabase Realtime subscriber
├── agent-runner.js   # claude CLI 呼び出し
├── package.json
└── .env              # SUPABASE_URL, SUPABASE_KEY, AGENTS_DIR
```

**動作イメージ:**
```
[Supabase agent_tasks に pending タスク INSERT]
        ↓ Realtime通知
[orchestrator/index.js が to_agent を確認]
        ↓
[agent-runner.js が `claude` CLI を spawn]
        ↓
[claude が agents/{to_agent}/CLAUDE.md を読み込んで実行開始]
        ↓
[タスク完了時に agent_tasks.status を done に更新]
```

**実装スケルトン（MVP-B での参考用）:**
```javascript
// imai/orchestrator/index.js
const { createClient } = require('@supabase/supabase-js')
const { spawnAgent } = require('./agent-runner')

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY)

supabase
  .channel('pending-tasks')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'agent_tasks',
    filter: 'status=eq.pending'
  }, async (payload) => {
    const task = payload.new
    await spawnAgent(task.to_agent, task.id)
  })
  .subscribe()
```

**常駐化（Windows）:**  
`pm2` を使って Windows サービスとして登録:
```powershell
npm install -g pm2
pm2 start imai/orchestrator/index.js --name yw-orchestrator
pm2 startup  # Windows サービス化
pm2 save
```

### MVP-A での暫定運用（手動起動）

MVP-B 完成まで：
1. ダッシュボードで pending タスクが発生したことを **スマホで確認**（Realtime表示）
2. PC 側で該当エージェントを手動起動
3. エージェントがダッシュボードの自分宛タスクを確認して実行

これだけでも「口頭での手動伝達」から大幅に改善される。

---

## 4. デプロイ方法

### ダッシュボード（フロントエンド）

| 項目 | 内容 |
|---|---|
| ホスティング | Vercel（kaidashi と同様） |
| パス | `products/agent-hub/` |
| ビルド設定 | Static HTML + Vanilla JS（ビルド不要） |
| 自動デプロイ | GitHub 連携、`main` ブランチ push で反映 |
| デプロイコマンド | `cd products/agent-hub && vercel --prod` |

### 環境変数（Vercel に登録）

```
SUPABASE_URL=https://<new-project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
```

> ダッシュボードは読み取り専用なので anon key のみ。書き込みは別途 service_role key 管理。

---

## 5. インフラ上の懸念・未解決事項

| # | 懸念 | 優先度 | 対応案 |
|---|------|--------|--------|
| 1 | Supabase 無料プランのリアルタイム接続数上限（200接続/プロジェクト） | 低 | MVP段階では問題なし |
| 2 | `agent_tasks.output` が大きくなるとDB肥大化 | 中 | output は別ストレージ（Supabase Storage）に分離を将来検討 |
| 3 | PC がオフラインの場合、orchestrator も止まる | 中 | MVP-B 設計時に「PC 不在時のキュー保持」を考慮 |
| 4 | 同一エージェントへの並行タスク | 中 | Conner指摘通り、スコープ外として明記。MVP-B でキュー処理を実装 |
| 5 | service_role key の管理 | 高 | `.env` に記載、`.gitignore` 必須。Vercel の環境変数に登録 |

---

## まとめ・David へのアクション

| # | 決定事項 | 担当 |
|---|----------|------|
| 1 | Supabase: bbq-app pause → 新規プロジェクト作成 | Imai |
| 2 | テーブル: `priority`, `cancelled`, `error_message`, `parent_task_id`, `metadata` を追加 | David |
| 3 | 自動起動: MVP-B に分割（Conner案に同意）、方式A（Node.js daemon）を採用予定 | Imai（MVP-B担当） |
| 4 | MVP-A のデプロイ: Vercel + 新規 Supabase プロジェクト | Imai |
| 5 | service_role key の `.gitignore` 設定 | Imai |
