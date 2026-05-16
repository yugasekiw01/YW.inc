-- カイダシ 初期テーブル作成
-- ※ このSQLはdeploy.sh経由で自動実行済み（2026-05-16）

CREATE TABLE IF NOT EXISTS events (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  event_code TEXT        UNIQUE NOT NULL,
  name       TEXT        NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS items (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id   UUID        NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name       TEXT        NOT NULL,
  category   TEXT        NOT NULL DEFAULT 'その他',
  checked    BOOLEAN     NOT NULL DEFAULT false,
  checked_by TEXT,
  voters     TEXT[]      DEFAULT '{}',
  added_by   TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS participants (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id   UUID        NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name       TEXT        NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, name)
);

CREATE TABLE IF NOT EXISTS warikan_entries (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id   UUID        NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  payer      TEXT        NOT NULL,
  amount     INTEGER     NOT NULL,
  members    TEXT[]      NOT NULL DEFAULT '{}',
  note       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_items_event_id           ON items(event_id);
CREATE INDEX IF NOT EXISTS idx_participants_event_id    ON participants(event_id);
CREATE INDEX IF NOT EXISTS idx_warikan_entries_event_id ON warikan_entries(event_id);
