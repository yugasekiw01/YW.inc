Phase 2 実装フェーズです。Supabase プロジェクトを作成してください。

## やること

1. Supabase ダッシュボードで bbq-app プロジェクトを pause
2. 新規プロジェクト「yw-agent-hub」を作成
3. 以下のテーブルを作成（03_infra.md の設計に従う）

### agent_tasks テーブル
```sql
CREATE TABLE agent_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sprint_name text NOT NULL,
  phase text NOT NULL,
  from_agent text NOT NULL,
  to_agent text NOT NULL,
  task_type text NOT NULL,
  title text NOT NULL,
  description text,
  priority text DEFAULT 'normal',
  status text DEFAULT 'pending',
  progress int DEFAULT 0,
  output text,
  error_message text,
  parent_task_id uuid REFERENCES agent_tasks(id),
  metadata jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX ON agent_tasks (to_agent, status);
CREATE INDEX ON agent_tasks (sprint_name, phase);
CREATE INDEX ON agent_tasks (created_at DESC);

ALTER TABLE agent_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON agent_tasks FOR ALL USING (true);
```

### agent_status テーブル
```sql
CREATE TABLE agent_status (
  agent_name text PRIMARY KEY,
  status text DEFAULT 'idle',
  current_task_id uuid REFERENCES agent_tasks(id),
  last_seen timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 初期データ
INSERT INTO agent_status (agent_name) VALUES 
  ('sakura'), ('conner'), ('david'), ('tiara'), ('imai');

ALTER TABLE agent_status ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON agent_status FOR ALL USING (true);
```

4. Realtime を有効化（両テーブル）
5. 作成したプロジェクトの情報を保存：

```
docs/sprints/agent-orchestration/04_supabase_config.md
- Project Ref: xxx
- URL: https://xxx.supabase.co
- Anon Key: xxx
```

※ Service Role Key は .env.local に保存（gitignore済み）
