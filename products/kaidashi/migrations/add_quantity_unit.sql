-- items テーブルに数量・単位カラムを追加
ALTER TABLE items
ADD COLUMN IF NOT EXISTS quantity INTEGER,
ADD COLUMN IF NOT EXISTS unit TEXT;

-- 既存データはNULLのまま（任意入力のため）
