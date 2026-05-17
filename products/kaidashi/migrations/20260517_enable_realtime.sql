-- Supabase Realtime 有効化
-- リアルタイム更新を動作させるため、各テーブルをパブリケーションに追加

ALTER PUBLICATION supabase_realtime ADD TABLE items;
ALTER PUBLICATION supabase_realtime ADD TABLE participants;
ALTER PUBLICATION supabase_realtime ADD TABLE warikan_entries;
