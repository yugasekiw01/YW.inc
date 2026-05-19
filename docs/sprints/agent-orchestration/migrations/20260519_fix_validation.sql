-- agent_tasks テーブルの DB バリデーション修正
-- Tiara テスト結果に基づく修正（TC-07, TC-09, TC-10, TC-11）

-- [B-01-a] title に NOT NULL 制約を追加
-- 既存データで NULL がないことを確認してから制約追加
DO $$
BEGIN
  -- 既存の NULL データを空文字で埋める（万が一のため）
  UPDATE agent_tasks SET title = '(no title)' WHERE title IS NULL;

  -- NOT NULL 制約を追加
  ALTER TABLE agent_tasks ALTER COLUMN title SET NOT NULL;

  RAISE NOTICE '[B-01-a] title NOT NULL constraint added';
END $$;

-- [B-01-b] progress に CHECK 制約を追加（0〜100の範囲）
DO $$
BEGIN
  -- 既存データで範囲外の値を修正
  UPDATE agent_tasks SET progress = 0 WHERE progress < 0;
  UPDATE agent_tasks SET progress = 100 WHERE progress > 100;

  -- CHECK 制約を追加
  ALTER TABLE agent_tasks ADD CONSTRAINT progress_range CHECK (progress >= 0 AND progress <= 100);

  RAISE NOTICE '[B-01-b] progress CHECK constraint added (0-100)';
END $$;

-- [B-01-c] 重複登録防止のユニーク制約を追加
-- 同じスプリント・フェーズ・送受信エージェント・タイトルの組み合わせは重複不可
DO $$
BEGIN
  -- 既存の重複データがあれば、最新のもの以外を削除
  DELETE FROM agent_tasks a
  USING agent_tasks b
  WHERE a.id < b.id
    AND a.sprint_name = b.sprint_name
    AND a.phase = b.phase
    AND a.from_agent = b.from_agent
    AND a.to_agent = b.to_agent
    AND a.title = b.title
    AND a.status = 'pending';  -- pending のみ重複チェック

  -- ユニーク制約を追加（pending状態のタスクのみ）
  -- 完了済みタスクは履歴として残すため、部分インデックスを使用
  CREATE UNIQUE INDEX agent_tasks_unique_pending
    ON agent_tasks (sprint_name, phase, from_agent, to_agent, title)
    WHERE status = 'pending';

  RAISE NOTICE '[B-01-c] Unique constraint added for pending tasks';
END $$;
