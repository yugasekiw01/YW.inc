-- ============================================================
-- イベント管理テーブルの追加
-- イベントごとにデータを分離するための基盤
-- ============================================================

-- 1. events テーブル作成
CREATE TABLE IF NOT EXISTS events (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  event_code TEXT        UNIQUE NOT NULL,
  name       TEXT        NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 既存テーブルに event_id カラムを追加（nullable: 既存データはNULLのまま）
ALTER TABLE bbq_items
  ADD COLUMN IF NOT EXISTS event_id UUID REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE participants
  ADD COLUMN IF NOT EXISTS event_id UUID REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE warikan_entries
  ADD COLUMN IF NOT EXISTS event_id UUID REFERENCES events(id) ON DELETE CASCADE;

-- 3. パフォーマンス向上のためインデックス追加
CREATE INDEX IF NOT EXISTS idx_bbq_items_event_id       ON bbq_items(event_id);
CREATE INDEX IF NOT EXISTS idx_participants_event_id    ON participants(event_id);
CREATE INDEX IF NOT EXISTS idx_warikan_entries_event_id ON warikan_entries(event_id);

-- 4. RLS（Row Level Security）は既存設定を継承
--    event_id での絞り込みはアプリ側のクエリで行う
