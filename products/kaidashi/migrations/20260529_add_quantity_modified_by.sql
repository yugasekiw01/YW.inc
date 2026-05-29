-- 個数変更者を記録するカラムを追加
ALTER TABLE items
ADD COLUMN IF NOT EXISTS quantity_modified_by TEXT;

-- 既存データはNULLのまま（任意）
