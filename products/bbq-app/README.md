# 🔥 BBQ 買い出しリスト

リンクを知っている全員がリアルタイムで編集できる BBQ 買い出し管理アプリです。  
**Firebase は不要。Supabase（完全無料・カード登録なし）を使います。**

---

## セットアップ手順

### 1. Supabase でプロジェクトを作成

1. [supabase.com](https://supabase.com) にアクセスして「Start your project」
2. GitHub アカウントでサインアップ（無料）
3. 「New project」をクリック
4. プロジェクト名（例: `bbq-list`）と DB パスワードを入力
5. Region は **Northeast Asia (Tokyo)** を選択 → 「Create new project」

作成に 1〜2 分かかります。

---

### 2. テーブルを作成

プロジェクトが作成されたら、左メニューの **「SQL Editor」** を開いて、  
以下の SQL を貼り付けて「RUN」ボタンを押す：

```sql
-- テーブル作成
CREATE TABLE bbq_items (
    id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name       TEXT NOT NULL,
    qty        TEXT,
    category   TEXT,
    checked    BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 誰でも読み書きできるポリシー（リンクを知っていれば全員使える）
ALTER TABLE bbq_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public access" ON bbq_items FOR ALL USING (true) WITH CHECK (true);

-- リアルタイム同期を有効化
ALTER PUBLICATION supabase_realtime ADD TABLE bbq_items;
```

---

### 3. URL と API キーをコピー

左メニューの **「Project Settings」→「API」** を開く：

- **Project URL** → `https://xxxxxxxxxx.supabase.co` のような URL
- **Project API keys** → `anon` `public` と書かれているキー

---

### 4. index.html を編集

`index.html` の以下の2行を書き換える：

```js
const SUPABASE_URL      = 'https://xxxxxxxxxx.supabase.co';  // ← Project URL
const SUPABASE_ANON_KEY = 'eyJhbGci...';                     // ← anon キー
```

---

### 5. ホスティング（無料でどれか選ぶ）

#### 方法 A: Netlify Drop（最も簡単・ドラッグ＆ドロップのみ）

1. [app.netlify.com/drop](https://app.netlify.com/drop) を開く
2. `bbq-app` フォルダをブラウザにドラッグ＆ドロップ
3. URL が発行されるのでみんなに共有 ✅

#### 方法 B: Vercel（CLI）

```bash
npm install -g vercel
vercel
```

---

## 機能

| 機能 | 詳細 |
|---|---|
| リアルタイム同期 | 誰かが追加・チェックすると全員の画面に即反映 |
| カテゴリ分類 | 肉 / 野菜・果物 / 飲み物 / 炭水化物 / 調味料・その他 |
| 購入済みチェック | チェックすると打ち消し線＆透明化 |
| 進捗バー | 何品買ったか一目でわかる |
| スマホ対応 | 買い物中にスマホで操作しやすい UI |
