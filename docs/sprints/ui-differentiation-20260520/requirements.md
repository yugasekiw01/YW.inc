# カイダシ 新UIフロー仕様書

**作成日**: 2026-05-20  
**担当**: Conner  
**スプリント**: ui-differentiation-20260520

---

## 🎯 目的

カイダシのイベント作成フローを刷新し、「walica」との差別化を図る。
**買い出しリスト機能**を前面に出し、カイダシ独自の価値を明確にする。

---

## 📊 現状分析

### 現在のフロー（問題あり）
```
トップページ
  ↓
イベント名入力
  ↓
作成ボタンクリック
  ↓
成功モーダル（URL表示）
  ↓
URL共有
```

**問題点**:
- walica と同様のフローで模倣と見られるリスク
- 買い出しリスト機能が目立たない
- カイダシの強みが伝わらない

---

## ✨ 新UIフロー（提案）

### コンセプト
**「みんなで買い出し、スマートに管理」**

買い出しシーンを想起させる UI で、カイダシの本来の価値を前面に出す。

---

## 🎨 新トップページ設計

### レイアウト構成

```
┌─────────────────────────────────────┐
│         🛒 カイダシ                  │
│   みんなで買い出し・割り勘を管理！    │
│           ✦ ✦ ✦                    │
├─────────────────────────────────────┤
│                                     │
│  【イラストエリア】                  │
│   🧺🥖🍎🧃🥬                        │
│   ↑ 買い出しをイメージさせるイラスト  │
│                                     │
├─────────────────────────────────────┤
│  📝 新しいイベントを作成              │
│                                     │
│  ┌─ STEP 1 ──────────────────┐    │
│  │ イベント名                  │    │
│  │ [例: 夏のBBQ・忘年会の準備]  │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌─ STEP 2（オプション）────────┐  │
│  │ シーン選択                   │    │
│  │ [🔥BBQ] [🏕キャンプ] [🎉パーティ]│
│  │ [🍱ピクニック] [📦その他]     │    │
│  └────────────────────────────┘    │
│                                     │
│  [🛒 イベントを作成する]             │
│                                     │
├─────────────────────────────────────┤
│  🕐 最近のイベント                   │
│                                     │
│  [🛒 夏のBBQ    コード: abc123 →]  │
│  [🛒 キャンプ   コード: def456 →]  │
│                                     │
└─────────────────────────────────────┘
```

### 主な変更点

#### 1️⃣ イラストエリアの追加 🆕
- **目的**: 買い出しシーンを視覚的に訴求
- **内容**: 🧺🥖🍎🧃🥬 などの絵文字を配置
- **効果**: walica（割り勘特化）との差別化

```html
<div class="illustration-area">
    <div class="illustration-icons">
        <span class="icon-float">🧺</span>
        <span class="icon-float">🥖</span>
        <span class="icon-float">🍎</span>
        <span class="icon-float">🧃</span>
        <span class="icon-float">🥬</span>
    </div>
    <p class="illustration-text">買い出しリストを共有して、みんなでお買い物</p>
</div>
```

**CSSアニメーション**:
```css
.icon-float {
    animation: float 3s ease-in-out infinite;
}
@keyframes float {
    0%, 100% { transform: translateY(0) rotate(-5deg); }
    50%      { transform: translateY(-15px) rotate(5deg); }
}
```

#### 2️⃣ シーン選択機能（STEP 2） 🆕

**目的**: テンプレート機能で差別化

```javascript
const SCENE_TEMPLATES = {
    'bbq': {
        emoji: '🔥',
        name: 'BBQ',
        categories: ['食べ物', '飲み物', '日用品'],
        suggestedItems: [
            { name: '牛肉', category: '食べ物', quantity: 1, unit: 'kg' },
            { name: 'ビール', category: '飲み物', quantity: 12, unit: '本' },
            { name: '炭', category: '日用品', quantity: 2, unit: '袋' },
            { name: '割り箸', category: '日用品', quantity: 1, unit: 'セット' }
        ]
    },
    'camp': {
        emoji: '🏕',
        name: 'キャンプ',
        suggestedItems: [
            { name: 'カレールー', category: '食べ物' },
            { name: '米', category: '食べ物', quantity: 2, unit: 'kg' },
            { name: '水', category: '飲み物', quantity: 2, unit: 'L' }
        ]
    },
    'party': {
        emoji: '🎉',
        name: 'パーティー',
        suggestedItems: [
            { name: 'ピザ', category: '食べ物', quantity: 3, unit: '枚' },
            { name: 'お菓子', category: '食べ物', quantity: 5, unit: '袋' },
            { name: 'ジュース', category: '飲み物', quantity: 2, unit: 'L' }
        ]
    },
    'picnic': {
        emoji: '🍱',
        name: 'ピクニック',
        suggestedItems: [
            { name: 'サンドイッチ', category: '食べ物' },
            { name: 'お茶', category: '飲み物', quantity: 1, unit: 'L' },
            { name: 'お菓子', category: '食べ物' }
        ]
    },
    'other': {
        emoji: '📦',
        name: 'その他',
        suggestedItems: []
    }
};
```

**UI表示**:
```html
<div class="scene-selector">
    <div class="scene-label">シーンを選択（オプション）</div>
    <div class="scene-chips">
        <button class="scene-chip" data-scene="bbq">
            <span class="scene-emoji">🔥</span>
            <span class="scene-name">BBQ</span>
        </button>
        <button class="scene-chip" data-scene="camp">
            <span class="scene-emoji">🏕</span>
            <span class="scene-name">キャンプ</span>
        </button>
        <button class="scene-chip" data-scene="party">
            <span class="scene-emoji">🎉</span>
            <span class="scene-name">パーティー</span>
        </button>
        <button class="scene-chip" data-scene="picnic">
            <span class="scene-emoji">🍱</span>
            <span class="scene-name">ピクニック</span>
        </button>
        <button class="scene-chip" data-scene="other">
            <span class="scene-emoji">📦</span>
            <span class="scene-name">その他</span>
        </button>
    </div>
    <p class="scene-hint">選ぶと買い出しリストの例が自動で追加されます</p>
</div>
```

**動作**:
1. ユーザーがシーンを選択（オプション）
2. イベント作成時に `scene` パラメータをDBに保存
3. app.html を開いたときに、選択したシーンの `suggestedItems` を自動追加

#### 3️⃣ 2ステップ作成フロー

**STEP 1（必須）**: イベント名入力  
**STEP 2（オプション）**: シーン選択

```javascript
async function createEvent() {
    const name = document.getElementById('event-name-input').value.trim();
    const scene = selectedScene || 'other'; // 選択されたシーン
    
    if (!name) {
        errorEl.textContent = 'イベント名を入力してください';
        return;
    }
    
    const event_code = generateEventCode();
    const { data, error } = await sb.from('events')
        .insert({ 
            event_code, 
            name,
            scene // 新規追加
        })
        .select()
        .single();
    
    if (error) {
        errorEl.textContent = '作成に失敗しました';
        return;
    }
    
    // シーンが選択されていたら、サンプルアイテムを追加
    if (scene !== 'other' && SCENE_TEMPLATES[scene]) {
        const items = SCENE_TEMPLATES[scene].suggestedItems.map(item => ({
            ...item,
            event_id: data.id,
            checked: false
        }));
        await sb.from('items').insert(items);
    }
    
    // 成功モーダル表示（既存）
    createdEventUrl = `${location.origin}/app.html?event=${data.event_code}`;
    document.getElementById('event-url').textContent = createdEventUrl;
    document.getElementById('success-modal').classList.remove('hidden');
}
```

#### 4️⃣ 成功モーダルの改善

**現状**: URLをコピー → イベントを開く

**新UI**: QRコード生成機能を追加 🆕

```html
<div class="modal-box">
    <span class="modal-icon">🎉</span>
    <h2>イベント作成完了！</h2>
    <p>URLをみんなに共有しましょう</p>
    
    <!-- QRコード追加 -->
    <div class="qr-code-area" id="qr-code"></div>
    <div class="qr-hint">スマホでスキャンして参加</div>
    
    <div class="url-display" id="event-url" onclick="copyUrl()"></div>
    <div class="copy-hint" id="copy-hint">タップでコピー</div>
    
    <button class="btn-open" id="open-btn">このイベントを開く 🛒</button>
    <button class="btn-close" onclick="closeModal()">あとで開く</button>
</div>
```

**QRコード生成**（qrcode.js 使用）:
```html
<script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
<script>
function showSuccessModal(url) {
    document.getElementById('event-url').textContent = url;
    document.getElementById('success-modal').classList.remove('hidden');
    
    // QRコード生成
    const qrEl = document.getElementById('qr-code');
    qrEl.innerHTML = ''; // クリア
    new QRCode(qrEl, {
        text: url,
        width: 160,
        height: 160,
        colorDark: '#1ABC9C',
        colorLight: '#FFFFFF'
    });
}
</script>
```

---

## 📱 画面遷移フロー

### 新フロー
```
┌─────────────────┐
│  トップページ    │
│                 │
│  🧺🥖🍎🧃🥬   │ ← イラストで買い出しをアピール
│                 │
│  STEP 1:        │
│  [イベント名]   │
│                 │
│  STEP 2:        │
│  [シーン選択]   │ ← walicaにはない独自機能
│  🔥BBQ 🏕キャンプ│
│                 │
│  [作成ボタン]   │
└────┬────────────┘
     │
     ↓
┌─────────────────┐
│  成功モーダル    │
│                 │
│  🎉完成！       │
│  [QRコード]     │ ← walicaにはない
│  [URL]          │
│  [開く/閉じる]  │
└────┬────────────┘
     │
     ↓
┌─────────────────┐
│  アプリ画面      │
│  (app.html)     │
│                 │
│  買い出しリスト  │ ← シーンに応じたアイテムが自動追加
│  - 牛肉 1kg     │
│  - ビール 12本  │
│  - 炭 2袋       │
└─────────────────┘
```

---

## 🎨 デザイン変更点

### カラーパレット（既存維持）
```
メインカラー: #1ABC9C
セカンダリ: #27AE60
背景: linear-gradient(160deg, #E8FAF4 0%, #F0FBF7 60%, #E4F7EF 100%)
```

### 新規追加スタイル

```css
/* イラストエリア */
.illustration-area {
    text-align: center;
    padding: 40px 20px;
    background: rgba(255,255,255,0.6);
    border-radius: 24px;
    margin-bottom: 20px;
}

.illustration-icons {
    font-size: 3rem;
    display: flex;
    justify-content: center;
    gap: 20px;
    margin-bottom: 16px;
}

.icon-float {
    display: inline-block;
    animation: float 3s ease-in-out infinite;
}

.icon-float:nth-child(1) { animation-delay: 0s; }
.icon-float:nth-child(2) { animation-delay: 0.5s; }
.icon-float:nth-child(3) { animation-delay: 1s; }
.icon-float:nth-child(4) { animation-delay: 1.5s; }
.icon-float:nth-child(5) { animation-delay: 2s; }

@keyframes float {
    0%, 100% { transform: translateY(0) rotate(-5deg); }
    50%      { transform: translateY(-15px) rotate(5deg); }
}

.illustration-text {
    font-size: 1rem;
    color: #1ABC9C;
    font-weight: 700;
}

/* シーン選択 */
.scene-selector {
    margin-bottom: 14px;
}

.scene-label {
    font-size: 0.85rem;
    color: #1ABC9C;
    margin-bottom: 10px;
    font-weight: 800;
}

.scene-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 8px;
}

.scene-chip {
    background: #F0FBF7;
    border: 2px solid #C8EDE6;
    border-radius: 16px;
    padding: 10px 16px;
    display: flex;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    transition: all 0.2s;
    font-family: inherit;
}

.scene-chip:hover {
    background: #D5F5EC;
    border-color: #1ABC9C;
    transform: translateY(-2px);
}

.scene-chip.selected {
    background: #1ABC9C;
    border-color: #1ABC9C;
    color: white;
    box-shadow: 0 4px 12px rgba(26,188,156,0.3);
}

.scene-emoji {
    font-size: 1.3rem;
}

.scene-name {
    font-size: 0.9rem;
    font-weight: 700;
}

.scene-hint {
    font-size: 0.75rem;
    color: #B2D8D0;
    margin-top: 4px;
}

/* QRコード */
.qr-code-area {
    background: white;
    padding: 16px;
    border-radius: 16px;
    display: inline-block;
    margin-bottom: 12px;
}

.qr-hint {
    font-size: 0.82rem;
    color: #1ABC9C;
    margin-bottom: 14px;
    font-weight: 700;
}
```

---

## 🗄️ DB変更

### events テーブルに追加

```sql
ALTER TABLE events 
ADD COLUMN scene TEXT DEFAULT 'other';
```

**scene の値**:
- `bbq` (🔥 BBQ)
- `camp` (🏕 キャンプ)
- `party` (🎉 パーティー)
- `picnic` (🍱 ピクニック)
- `other` (📦 その他)

---

## ✅ 受け入れ条件

### 必須機能
- [ ] トップページにイラストエリアが表示される
- [ ] シーン選択（5種類）が機能する
- [ ] シーン選択後、イベント作成すると app.html でサンプルアイテムが追加される
- [ ] 成功モーダルにQRコードが表示される
- [ ] QRコードをスキャンするとイベントページが開く
- [ ] シーン選択はオプション（スキップ可能）

### UI/UX
- [ ] 買い出しイメージが明確に伝わる
- [ ] walica との違いが一目でわかる
- [ ] スマホで快適に操作できる
- [ ] 既存の最近のイベント機能が動作する

### 技術要件
- [ ] レスポンシブ対応
- [ ] PWA機能に影響しない
- [ ] Supabase Realtime が動作する
- [ ] 既存のイベント（scene なし）も正常に動作

---

## 📐 ワイヤーフレーム（テキストベース）

### トップページ（Before → After）

**Before（現状）**:
```
┌──────────────────┐
│   🛒 カイダシ     │
│ みんなで買い出し  │
├──────────────────┤
│ 新しいイベント    │
│ [イベント名]     │
│ [作成ボタン]     │
├──────────────────┤
│ 最近のイベント    │
│ - 夏のBBQ        │
│ - キャンプ       │
└──────────────────┘
```

**After（新UI）**:
```
┌──────────────────┐
│   🛒 カイダシ     │
│ みんなで買い出し  │
├──────────────────┤
│  🧺🥖🍎🧃🥬    │ ← 新規
│ 買い出しリストを  │
│  共有しよう！     │
├──────────────────┤
│ 新しいイベント    │
│                  │
│ STEP 1           │
│ [イベント名]     │
│                  │
│ STEP 2           │ ← 新規
│ [🔥BBQ] [🏕]    │
│ [🎉] [🍱] [📦]  │
│                  │
│ [作成ボタン]     │
├──────────────────┤
│ 最近のイベント    │
│ - 夏のBBQ        │
│ - キャンプ       │
└──────────────────┘
```

### 成功モーダル（Before → After）

**Before（現状）**:
```
┌──────────────────┐
│   🎉 完成！       │
│ URLを共有しよう   │
│                  │
│ [URL表示]        │
│ タップでコピー    │
│                  │
│ [開く] [閉じる]  │
└──────────────────┘
```

**After（新UI）**:
```
┌──────────────────┐
│   🎉 完成！       │
│ URLを共有しよう   │
│                  │
│ [QRコード]       │ ← 新規
│ スマホでスキャン  │
│                  │
│ [URL表示]        │
│ タップでコピー    │
│                  │
│ [開く] [閉じる]  │
└──────────────────┘
```

---

## 🔍 walica との差別化まとめ

| 機能 | walica | カイダシ（新UI） |
|------|--------|-----------------|
| メインコンセプト | 割り勘計算 | **買い出しリスト管理** |
| トップページ | シンプルなフォーム | **買い出しイラスト** |
| イベント作成 | 1ステップ | **2ステップ（シーン選択）** |
| テンプレート | なし | **5種類のシーン** |
| QRコード | なし | **自動生成** |
| サンプルアイテム | なし | **シーン別自動追加** |

---

## 📊 実装優先順位

### Phase 1（必須）
1. イラストエリア追加
2. シーン選択UI
3. DB `scene` カラム追加
4. サンプルアイテム自動追加

### Phase 2（推奨）
5. QRコード生成機能

### Phase 3（将来）
6. シーンテンプレートのカスタマイズ
7. 他ユーザーのテンプレート共有

---

## 🚀 次のステップ

1. **Davidへ引き継ぎ**: 実装フェーズへ
2. **Tiaraと連携**: テストシナリオ確認
3. **Imaiと連携**: デプロイ準備

---

## 📝 補足

### ライブラリ追加
- **QRコード生成**: qrcode.js（CDN）

```html
<script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
```

### 既存機能への影響
- ✅ 割り勘機能: 影響なし
- ✅ リアルタイム更新: 影響なし
- ✅ 参加者管理: 影響なし
- ✅ 最近のイベント: 影響なし

---

**仕様策定者**: Conner  
**承認**: 未実施  
**次フェーズ**: David（実装）
