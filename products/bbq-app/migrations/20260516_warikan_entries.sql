CREATE TABLE IF NOT EXISTS warikan_entries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payer TEXT NOT NULL,
    amount INTEGER NOT NULL,
    members JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE warikan_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public access" ON warikan_entries FOR ALL USING (true) WITH CHECK (true);
ALTER PUBLICATION supabase_realtime ADD TABLE warikan_entries;
