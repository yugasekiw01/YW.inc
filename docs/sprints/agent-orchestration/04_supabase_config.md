# YW Agent Hub - Supabase Configuration

## プロジェクト情報

- **Project Name**: yw-agent-hub
- **Project Ref**: pemepunzxrvmsvjjhsry
- **URL**: https://pemepunzxrvmsvjjhsry.supabase.co
- **Region**: ap-northeast-1 (Tokyo)
- **Status**: ACTIVE_HEALTHY

## API Keys

### Anon Key (公開可能)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlbWVwdW56eHJ2bXN2ampoc3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTk2NTcsImV4cCI6MjA5NDY3NTY1N30.AvfSOhXCQWk5TDzP0JaP_z54sonNpCwYlIOE2TXslCE
```

### Service Role Key
⚠️ **機密情報** - `.env.local` に保存済み

## データベース

### テーブル構成

1. **agent_tasks** - エージェント間タスク管理
   - id (uuid, primary key)
   - sprint_name, phase, from_agent, to_agent
   - task_type, title, description, priority, status
   - progress, output, error_message
   - parent_task_id (self-reference)
   - metadata (jsonb)
   - created_at, updated_at

2. **agent_status** - エージェントステータス管理
   - agent_name (text, primary key)
   - status (idle/busy/error)
   - current_task_id (参照: agent_tasks)
   - last_seen, updated_at

### 初期エージェント
- sakura (秘書)
- conner (コンサル)
- david (開発)
- tiara (テスト)
- imai (保守・インフラ)

### Realtime
✅ 両テーブルで有効化済み

### Row Level Security (RLS)
✅ 両テーブルで有効化済み（全操作許可ポリシー）

## 作成日時
2026-05-18 19:20 JST
