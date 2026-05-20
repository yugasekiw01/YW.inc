# カイダシ v2.0 スプリント仕様書

**作成日**: 2026-05-19  
**担当**: Conner（要件定義） → David（実装）  
**優先度**: High

---

## 🎯 スプリント目標

カイダシアプリに以下3つの機能を追加：
1. **PWA対応** - ホーム画面追加時のリソース読み込みエラー修正
2. **数量・単位機能** - 買い出し品の数量・単位を管理
3. **品物削除機能** - 誰でも品物を削除可能に

---

## 📋 機能詳細

### 1️⃣ アプリアイコン + PWA対応

#### 🎨 アイコンデザイン仕様
- **テキスト**: "KAIDASHI"（一行、中央配置）
- **フォント**: スタイリッシュな可愛めのゴシック
  - 推奨: Zen Kaku Gothic New, M PLUS Rounded 1c, Zen Maru Gothic
- **背景色**: `#1ABC9C` (エメラルドグリーン)
- **文字色**: `#FFFFFF` (白)
- **サイズ**: 192x192px, 512x512px
- **保存先**: `products/kaidashi/icons/`
  - `icon-192.png`
  - `icon-512.png`

#### 📄 manifest.json（新規作成）

**パス**: `products/kaidashi/manifest.json`

```json
{
  "name": "カイダシ",
  "short_name": "カイダシ",
  "description": "イベントごとに買い出しと割り勘をみんなで管理！",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#E8FAF4",
  "theme_color": "#1ABC9C",
  "orientation": "portrait",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

#### 🛠️ Service Worker（新規作成）

**パス**: `products/kaidashi/sw.js`

**要件**:
- 静的リソース（HTML、CSS、JS、フォント）をキャッシュ
- オフライン時にキャッシュから配信
- Supabase APIはキャッシュしない（リアルタイム性重視）
- キャッシュバージョン管理（更新時に古いキャッシュを削除）

**キャッシュ対象**:
```javascript
const CACHE_NAME = 'kaidashi-v2.0';
const urlsToCache = [
  '/',
  '/index.html',
  '/app.html',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  'https://fonts.googleapis.com/css2?family=Yomogi&display=swap'
];
```

**キャッシュ除外**:
- `https://akovhthopauhmlbcjjfw.supabase.co/*`
- `https://cdn.jsdelivr.net/npm/@supabase/*`

#### 📝 HTMLファイル修正

**index.html と app.html の `<head>` 内に追加**:

```html
<!-- PWA対応 -->
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="#1ABC9C">
<link rel="apple-touch-icon" href="/icons/icon-192.png">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="カイダシ">

<!-- Service Worker登録 -->
<script>
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(reg => console.log('SW registered:', reg))
      .catch(err => console.error('SW registration failed:', err));
  });
}
</script>
```

---

### 2️⃣ 数量・単位機能

#### 🗄️ DB変更（Supabase migration）

**マイグレーションファイル作成**: `products/kaidashi/migrations/add_quantity_unit.sql`

```sql
-- items テーブルに数量・単位カラムを追加
ALTER TABLE items 
ADD COLUMN quantity INTEGER,
ADD COLUMN unit TEXT;

-- 既存データはNULLのまま（任意入力のため）
```

#### 📋 単位の選択肢

```javascript
const UNITS = [
  '',       // 空（未指定）
  '個',
  '本',
  '袋',
  'パック',
  'セット',
  '箱',
  '缶',
  'kg',
  'g',
  'L',
  'ml',
  '束',
  '玉',
  '枚'
];

const UNIT_ICONS = {
  '個': '🔢',
  '本': '📏',
  '袋': '🛍️',
  'パック': '📦',
  'セット': '🎁',
  '箱': '📦',
  '缶': '🥫',
  'kg': '⚖️',
  'g': '⚖️',
  'L': '🧃',
  'ml': '🧃',
  '束': '🌾',
  '玉': '🔴',
  '枚': '📄'
};
```

#### 🎨 UI変更（app.html）

**追加フォーム修正**:

```html
<div class="add-form">
    <div class="input-row">
        <input type="text" id="item-name" placeholder="品目を入力" autocomplete="off" style="flex: 1;" />
        <input type="number" id="item-quantity" placeholder="数量" style="width: 70px;" min="0" />
        <select id="item-unit" style="width: 90px;">
            <option value="">単位</option>
            <option value="個">個</option>
            <option value="本">本</option>
            <option value="袋">袋</option>
            <option value="パック">パック</option>
            <option value="セット">セット</option>
            <option value="箱">箱</option>
            <option value="缶">缶</option>
            <option value="kg">kg</option>
            <option value="g">g</option>
            <option value="L">L</option>
            <option value="ml">ml</option>
            <option value="束">束</option>
            <option value="玉">玉</option>
            <option value="枚">枚</option>
        </select>
    </div>
    <select id="item-category">
        <!-- 既存のカテゴリ選択 -->
    </select>
    <button class="add-btn" id="add-btn">＋ リストに追加！</button>
</div>
```

**CSS追加**:

```css
.input-row {
    display: flex;
    gap: 8px;
    margin-bottom: 10px;
}
.input-row input,
.input-row select {
    /* 既存のスタイルを継承 */
}
```

**JavaScript修正**:

```javascript
// addItem() 関数を修正
async function addItem() {
    if (!eventId) return;
    const name = document.getElementById('item-name').value.trim();
    const category = document.getElementById('item-category').value;
    const quantity = parseInt(document.getElementById('item-quantity').value) || null;
    const unit = document.getElementById('item-unit').value || null;
    
    if (!name) { document.getElementById('item-name').focus(); return; }
    addBtn.disabled = true;
    try {
        await sb.from('items').insert({ 
            name, 
            category, 
            quantity,
            unit,
            checked: false, 
            added_by: myName || null, 
            event_id: eventId 
        });
        document.getElementById('item-name').value = '';
        document.getElementById('item-quantity').value = '';
        document.getElementById('item-unit').value = '';
        document.getElementById('item-name').focus();
    } finally { addBtn.disabled = false; }
}

// render() 関数内の表示部分を修正
function buildItemNameWithQuantity(item) {
    let displayName = esc(item.name);
    if (item.quantity && item.unit) {
        displayName += ` <strong>${item.quantity}${item.unit}</strong>`;
    } else if (item.quantity) {
        displayName += ` <strong>${item.quantity}</strong>`;
    } else if (item.unit) {
        displayName += ` <strong>${item.unit}</strong>`;
    }
    return displayName;
}

// render() 内で使用
html += `<div class="item-name">${buildItemNameWithQuantity(item)}</div>`;
```

#### 🎯 表示ロジック

| 入力状態 | 表示例 |
|---------|--------|
| 数量: 6, 単位: 本 | ビール **6本** |
| 数量: 6, 単位: なし | ビール **6** |
| 数量: なし, 単位: 本 | ビール **本** |
| どちらもなし | ビール |

#### 🚫 参加者が1人の場合の処理

```javascript
// render() 関数内で参加者数をチェック
const showVoteButton = participants.length > 1;

// 投票ボタンの表示制御
html += showVoteButton 
    ? `<button class="vote-btn ${voted?'voted':''}" onclick="voteItem('${esc(item.id)}')">✋ ホシイ！${voters.length?' '+voters.length:''}</button>`
    : '';
```

---

### 3️⃣ 品物削除機能

#### ✅ 現状確認

**既存コード（app.html 866行目）**:
```javascript
async function deleteItem(id) { 
    if (confirm('このアイテムを削除しますか？')) 
        await sb.from('items').delete().eq('id', id).eq('event_id', eventId); 
}
```

#### 🎯 要件

- ✅ **権限**: 誰でも削除可能
- ✅ **確認ダイアログ**: `confirm()` で確認
- ✅ **リアルタイム反映**: Supabase Realtime で自動反映
- ✅ **UI**: 削除ボタンは `added_by` が自分の場合のみ表示（既存仕様）

#### 🔧 修正不要

現在の実装で要件を満たしています。以下を確認するだけ：

1. **削除ボタンの表示条件**: 
   - 現状: `added_by === myName` の場合のみ表示
   - 要件: 誰でも削除可能
   - **→ 修正必要**: 削除ボタンを常に表示

**修正コード**:
```javascript
// render() 関数内（777行目付近）
// 修正前
${canDelete?`<button class="delete-btn" onclick="deleteItem('${esc(item.id)}')">✕</button>`:''}

// 修正後（常に表示）
<button class="delete-btn" onclick="deleteItem('${esc(item.id)}')">✕</button>
```

---

## 🗂️ ファイル変更一覧

### 新規作成
- `products/kaidashi/manifest.json`
- `products/kaidashi/sw.js`
- `products/kaidashi/icons/icon-192.png`
- `products/kaidashi/icons/icon-512.png`
- `products/kaidashi/migrations/add_quantity_unit.sql`

### 修正
- `products/kaidashi/index.html`（PWAメタタグ追加）
- `products/kaidashi/app.html`（PWAメタタグ + 数量・単位UI + 削除ボタン修正）

---

## 🧪 テスト項目（Tiaraへ引き継ぎ用）

### PWAテスト
- [ ] スマホでホーム画面に追加できる
- [ ] アイコンが正しく表示される
- [ ] オフライン時に基本機能が動作する
- [ ] リソース読み込みエラーが発生しない

### 数量・単位テスト
- [ ] 数量のみ入力 → 正しく表示
- [ ] 単位のみ入力 → 正しく表示
- [ ] 両方入力 → 正しく表示
- [ ] 両方未入力 → 通常通り表示
- [ ] 参加者1人の場合、ホシイボタン非表示

### 削除機能テスト
- [ ] 誰でも削除ボタンが表示される
- [ ] 削除確認ダイアログが表示される
- [ ] 削除後、全員の画面から消える

---

## 📊 進捗管理

- **Phase**: 要件定義 → 実装
- **From**: Conner
- **To**: David
- **Priority**: High
- **Deadline**: 未定（ユーザー確認後設定）

---

## 🎨 デザインリファレンス

### カラーパレット
```
メインカラー: #1ABC9C (エメラルドグリーン)
セカンダリ: #27AE60 (深めのグリーン)
背景: linear-gradient(160deg, #E8FAF4 0%, #F0FBF7 60%, #E4F7EF 100%)
アクセント: #2ECC71 (ライトグリーン)
テキスト: #2C7A6C (ダークグリーン)
```

### フォント
```
メイン: 'Yomogi', -apple-system, sans-serif
```

---

## 📝 備考

- Vercelへの自動デプロイ設定済み
- Supabase Realtime 有効
- 既存機能（割り勘、参加者管理）は変更なし

---

**仕様書作成者**: Conner  
**レビュー**: 未実施  
**承認**: ユーザー承認済み
