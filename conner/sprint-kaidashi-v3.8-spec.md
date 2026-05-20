# カイダシ v3.8 スプリント仕様書

**作成日**: 2026-05-20  
**担当**: Conner（要件定義） → David（実装）  
**優先度**: Medium  
**バージョンタイプ**: Minor (3.7.0 → 3.8.0)

---

## 🎯 スプリント目標

カイダシの参加者管理に以下2つの機能を追加：
1. **参加者重複防止機能** - 類似名前を検出して重複登録を防止
2. **参加者統合機能** - 既に重複した参加者を統合

---

## 📋 背景

### 現在の問題

**シナリオ**:
1. Aさんが親切で「田中」を参加者に追加
2. 本人が後から「田中さん」で参加
3. システムは別人と判断 → 重複登録
4. 割り勘が1人多くカウントされる

**原因**:
- 完全一致のみチェック（`participants.includes(name)`）
- 「田中」と「田中さん」は別の名前として扱われる

---

## ✨ 機能詳細

### 1️⃣ 参加者重複防止機能

#### 概要
参加者追加時に、既存の類似名前を検出して確認ダイアログを表示。

#### 動作フロー
```
参加者追加ボタンクリック
  ↓
名前入力（例: 田中さん）
  ↓
完全一致チェック → 一致あり → エラー表示
  ↓ 一致なし
類似名前チェック → 類似あり → 確認ダイアログ
  │                            「既に『田中』さんがいます」
  │                            「同じ人？ → キャンセル」
  │                            「別の人？ → OK で追加」
  ↓ 類似なし
追加処理
```

#### 類似判定ロジック

##### 正規化関数
```javascript
function normalizeName(name) {
    return name
        .replace(/さん|くん|ちゃん|様|氏$/g, '')  // 敬称削除
        .replace(/\s+/g, '')                      // 空白削除
        .toLowerCase()                            // 小文字化
        .replace(/[ァ-ン]/g, (s) =>               // カタカナ→ひらがな
            String.fromCharCode(s.charCodeAt(0) - 0x60));
}
```

##### 類似判定関数
```javascript
function findSimilarNames(newName, existingNames) {
    const normalized = normalizeName(newName);
    
    return existingNames.filter(existing => {
        const existingNormalized = normalizeName(existing);
        
        // 1. 正規化後の完全一致
        if (normalized === existingNormalized) return true;
        
        // 2. 部分一致（どちらかが含まれる）
        if (normalized.includes(existingNormalized) || 
            existingNormalized.includes(normalized)) return true;
        
        // 3. レーベンシュタイン距離が2以下
        if (levenshteinDistance(normalized, existingNormalized) <= 2) return true;
        
        return false;
    });
}
```

##### レーベンシュタイン距離（編集距離）
```javascript
function levenshteinDistance(a, b) {
    const matrix = [];
    
    // 初期化
    for (let i = 0; i <= b.length; i++) {
        matrix[i] = [i];
    }
    for (let j = 0; j <= a.length; j++) {
        matrix[0][j] = j;
    }
    
    // 動的計画法
    for (let i = 1; i <= b.length; i++) {
        for (let j = 1; j <= a.length; j++) {
            if (b.charAt(i - 1) === a.charAt(j - 1)) {
                matrix[i][j] = matrix[i - 1][j - 1];
            } else {
                matrix[i][j] = Math.min(
                    matrix[i - 1][j - 1] + 1,  // 置換
                    matrix[i][j - 1] + 1,      // 挿入
                    matrix[i - 1][j] + 1       // 削除
                );
            }
        }
    }
    
    return matrix[b.length][a.length];
}
```

#### 検出例

| 既存参加者 | 新規入力 | 判定 | 理由 |
|----------|---------|------|------|
| 田中 | 田中さん | ⚠️ 類似 | 敬称削除後一致 |
| たろう | タロウ | ⚠️ 類似 | カナ→ひらがな後一致 |
| 山田 太郎 | 山田太郎 | ⚠️ 類似 | 空白削除後一致 |
| 佐藤 | 佐藤一郎 | ⚠️ 類似 | 部分一致 |
| 鈴木 | 鈴本 | ⚠️ 類似 | 編集距離1 |
| 田中 | 鈴木 | ✅ 別人 | 類似なし |

#### UI実装

**JavaScript修正箇所**: `app.html` の `confirmAddParticipant()` 関数

```javascript
async function confirmAddParticipant() {
    if (!eventId) return;
    const input = document.getElementById('participant-name-input');
    const name = input.value.trim();
    
    if (!name) { input.focus(); return; }
    
    // 完全一致チェック（既存）
    if (participants.includes(name)) {
        alert('その名前はすでに登録されています');
        input.focus();
        return;
    }
    
    // 🆕 類似名前チェック
    const similar = findSimilarNames(name, participants);
    
    if (similar.length > 0) {
        const names = similar.map(n => `「${n}」`).join('、');
        const confirmed = confirm(
            `似た名前の参加者がいます：${names}\n\n` +
            `同じ人ですか？\n` +
            `→ 同じ人なら「キャンセル」を押してください\n` +
            `→ 別の人なら「OK」で追加します`
        );
        
        if (!confirmed) {
            hideParticipantAddForm();
            return;
        }
    }
    
    // 追加処理
    await sb.from('participants')
        .upsert({ name, event_id: eventId }, { onConflict: 'event_id,name' });
    hideParticipantAddForm();
}

// 🆕 上記の関数を追加
function normalizeName(name) { /* ... */ }
function findSimilarNames(newName, existingNames) { /* ... */ }
function levenshteinDistance(a, b) { /* ... */ }
```

---

### 2️⃣ 参加者統合機能

#### 概要
既に重複登録された参加者を後から統合する機能。

#### UI追加

**参加者エリアに統合ボタンを追加**:
```html
<div class="participants-wrap">
    <div class="participants-header">👥 参加者 <span id="participant-count">0</span>人</div>
    <div class="participant-tags" id="participant-tags">
        <!-- 既存の参加者タグ -->
    </div>
    
    <!-- 🆕 統合ボタン -->
    <button class="participant-merge-btn" onclick="showMergeModal()" 
            style="margin-top: 10px;">
        🔗 重複を統合
    </button>
    
    <!-- 既存の追加フォーム -->
</div>
```

**統合モーダル**:
```html
<!-- 🆕 参加者統合モーダル -->
<div class="merge-modal hidden" id="merge-modal">
    <div class="merge-modal-box">
        <div class="icon">🔗</div>
        <h2>参加者を統合</h2>
        <p>同じ人を1つにまとめます</p>
        
        <div class="merge-select-wrap">
            <div class="merge-label">統合する人（消える）</div>
            <select id="merge-from" class="merge-select">
                <!-- 参加者リストを動的に生成 -->
            </select>
        </div>
        
        <div class="merge-arrow">↓ 統合先 ↓</div>
        
        <div class="merge-select-wrap">
            <div class="merge-label">残す名前</div>
            <select id="merge-to" class="merge-select">
                <!-- 参加者リストを動的に生成 -->
            </select>
        </div>
        
        <div class="merge-warning">
            ⚠️ 割り勘の記録も「残す名前」に変更されます
        </div>
        
        <button class="merge-submit-btn" onclick="mergeParticipants()">統合する</button>
        <button class="merge-cancel-btn" onclick="closeMergeModal()">キャンセル</button>
    </div>
</div>
```

#### CSS追加

```css
/* 統合ボタン */
.participant-merge-btn {
    background: #F0FBF7;
    border: 2px dashed #C8EDE6;
    color: #1ABC9C;
    border-radius: 16px;
    padding: 10px 16px;
    font-size: 0.88rem;
    font-weight: 800;
    font-family: inherit;
    cursor: pointer;
    transition: all 0.18s;
    width: 100%;
}

.participant-merge-btn:hover {
    background: #D5F5EC;
    border-color: #1ABC9C;
}

/* 統合モーダル */
.merge-modal {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(6px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 110;
    padding: 20px;
}

.merge-modal.hidden {
    display: none;
}

.merge-modal-box {
    background: white;
    border-radius: 24px;
    padding: 28px 24px;
    width: 100%;
    max-width: 360px;
    text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,0.25);
    animation: popIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.merge-modal-box .icon {
    font-size: 3rem;
    margin-bottom: 12px;
}

.merge-modal-box h2 {
    font-size: 1.2rem;
    font-weight: 800;
    margin-bottom: 6px;
    color: #2C7A6C;
}

.merge-modal-box p {
    font-size: 0.85rem;
    color: #999;
    margin-bottom: 18px;
}

.merge-select-wrap {
    margin-bottom: 14px;
    text-align: left;
}

.merge-label {
    font-size: 0.85rem;
    font-weight: 800;
    color: #1ABC9C;
    margin-bottom: 6px;
}

.merge-select {
    width: 100%;
    border: 2px solid #C8EDE6;
    border-radius: 12px;
    padding: 12px 14px;
    font-size: 1rem;
    font-family: inherit;
    outline: none;
    background: #F7FDFB;
    font-weight: 700;
}

.merge-select:focus {
    border-color: #1ABC9C;
    box-shadow: 0 0 0 3px rgba(26,188,156,0.15);
}

.merge-arrow {
    font-size: 1.2rem;
    color: #1ABC9C;
    margin: 14px 0;
    font-weight: 800;
}

.merge-warning {
    font-size: 0.78rem;
    color: #E74C3C;
    background: #FFF0F0;
    padding: 10px 12px;
    border-radius: 10px;
    margin-bottom: 14px;
    font-weight: 700;
}

.merge-submit-btn {
    width: 100%;
    background: linear-gradient(135deg, #1ABC9C, #2ECC71);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 13px;
    font-size: 1rem;
    font-weight: 800;
    font-family: inherit;
    cursor: pointer;
    margin-bottom: 8px;
    transition: transform 0.15s;
}

.merge-submit-btn:hover {
    transform: translateY(-2px);
}

.merge-cancel-btn {
    width: 100%;
    background: #F0F0F0;
    color: #999;
    border: none;
    border-radius: 12px;
    padding: 11px;
    font-size: 0.9rem;
    font-weight: 800;
    font-family: inherit;
    cursor: pointer;
}
```

#### JavaScript実装

```javascript
// 🆕 統合モーダルを表示
function showMergeModal() {
    if (participants.length < 2) {
        alert('参加者が2人以上必要です');
        return;
    }
    
    // セレクトボックスに参加者リストを設定
    const fromSelect = document.getElementById('merge-from');
    const toSelect = document.getElementById('merge-to');
    
    fromSelect.innerHTML = participants
        .map(name => `<option value="${esc(name)}">${esc(name)}</option>`)
        .join('');
    
    toSelect.innerHTML = participants
        .map(name => `<option value="${esc(name)}">${esc(name)}</option>`)
        .join('');
    
    document.getElementById('merge-modal').classList.remove('hidden');
}

// 🆕 統合モーダルを閉じる
function closeMergeModal() {
    document.getElementById('merge-modal').classList.add('hidden');
}

// 🆕 参加者を統合
async function mergeParticipants() {
    const fromName = document.getElementById('merge-from').value;
    const toName = document.getElementById('merge-to').value;
    
    if (!fromName || !toName) {
        alert('統合する人と残す名前を選択してください');
        return;
    }
    
    if (fromName === toName) {
        alert('同じ人は統合できません');
        return;
    }
    
    const confirmed = confirm(
        `「${fromName}」を「${toName}」に統合しますか？\n\n` +
        `※ 割り勘の記録も「${toName}」に変更されます`
    );
    
    if (!confirmed) return;
    
    try {
        // 1. 割り勘エントリーの更新
        const { data: entries } = await sb.from('warikan_entries')
            .select('*')
            .eq('event_id', eventId);
        
        for (const entry of entries || []) {
            let updated = false;
            let newEntry = { ...entry };
            
            // payer を変更
            if (entry.payer === fromName) {
                newEntry.payer = toName;
                updated = true;
            }
            
            // members を変更
            if (entry.members && entry.members.includes(fromName)) {
                newEntry.members = entry.members.map(m => m === fromName ? toName : m);
                updated = true;
            }
            
            if (updated) {
                await sb.from('warikan_entries')
                    .update({ 
                        payer: newEntry.payer, 
                        members: newEntry.members 
                    })
                    .eq('id', entry.id);
            }
        }
        
        // 2. アイテムの更新
        const { data: items } = await sb.from('items')
            .select('*')
            .eq('event_id', eventId);
        
        for (const item of items || []) {
            let updates = {};
            
            if (item.added_by === fromName) {
                updates.added_by = toName;
            }
            
            if (item.checked_by === fromName) {
                updates.checked_by = toName;
            }
            
            if (item.voters && item.voters.includes(fromName)) {
                updates.voters = item.voters.map(v => v === fromName ? toName : v);
            }
            
            if (Object.keys(updates).length > 0) {
                await sb.from('items').update(updates).eq('id', item.id);
            }
        }
        
        // 3. participants から削除
        await sb.from('participants')
            .delete()
            .eq('name', fromName)
            .eq('event_id', eventId);
        
        closeMergeModal();
        alert('✅ 統合が完了しました！');
        
    } catch (error) {
        console.error('統合エラー:', error);
        alert('❌ 統合に失敗しました。もう一度お試しください。');
    }
}
```

---

## 🗂️ ファイル変更一覧

### 修正
- `products/kaidashi/app.html`
  - JavaScript: 重複防止機能追加（3関数）
  - JavaScript: 統合機能追加（3関数）
  - HTML: 統合モーダル追加
  - CSS: 統合UI追加

### 新規作成
- なし（既存ファイルの修正のみ）

---

## ✅ 受け入れ条件

### 重複防止機能
- [ ] 敬称付き名前を追加時、敬称なしの類似名前が検出される
- [ ] カタカナ・ひらがなの違いで類似名前が検出される
- [ ] 空白の有無で類似名前が検出される
- [ ] 編集距離2以下で類似名前が検出される
- [ ] 確認ダイアログで「キャンセル」を押すと追加されない
- [ ] 確認ダイアログで「OK」を押すと追加される
- [ ] 類似名前がない場合は通常通り追加される

### 統合機能
- [ ] 参加者が2人未満の場合、統合ボタンでエラー表示
- [ ] 統合モーダルで全参加者が選択可能
- [ ] 同じ名前は統合できない（エラー表示）
- [ ] 統合実行後、割り勘の payer が更新される
- [ ] 統合実行後、割り勘の members が更新される
- [ ] 統合実行後、アイテムの added_by が更新される
- [ ] 統合実行後、アイテムの checked_by が更新される
- [ ] 統合実行後、アイテムの voters が更新される
- [ ] 統合実行後、participants から削除される
- [ ] リアルタイムで全員の画面に反映される

### UX
- [ ] スマホで快適に操作できる
- [ ] 確認ダイアログのメッセージが分かりやすい
- [ ] 統合後に成功メッセージが表示される

---

## 🧪 テスト項目（Tiaraへ引き継ぎ用）

### 重複防止テスト

| テストケース | 既存参加者 | 新規入力 | 期待結果 |
|------------|----------|---------|---------|
| 完全一致 | 田中 | 田中 | エラー表示 |
| 敬称あり | 田中 | 田中さん | 確認ダイアログ |
| カタカナ変換 | たろう | タロウ | 確認ダイアログ |
| 空白削除 | 山田 太郎 | 山田太郎 | 確認ダイアログ |
| 部分一致 | 佐藤 | 佐藤一郎 | 確認ダイアログ |
| 編集距離1 | 鈴木 | 鈴本 | 確認ダイアログ |
| 編集距離2 | 田中 | 中田 | 確認ダイアログ |
| 編集距離3 | 田中 | 中村 | 追加される |
| 全く違う名前 | 田中 | 鈴木 | 追加される |

### 統合テスト

1. **基本統合**
   - 「田中」と「田中さん」を統合
   - 割り勘記録が正しく更新されるか確認

2. **複数統合**
   - 「たろう」「タロウ」「太郎」を1つに統合
   - 3回統合操作を実行

3. **エッジケース**
   - 参加者1人で統合ボタンを押す → エラー
   - 同じ名前同士を統合しようとする → エラー

4. **データ整合性**
   - 統合後、割り勘計算が正しいか確認
   - 統合後、投票数が維持されるか確認

---

## 📊 進捗管理

- **Phase**: 要件定義 → 実装
- **From**: Conner
- **To**: David
- **Priority**: Medium
- **Version**: Minor (3.7.0 → 3.8.0)

---

## 🎨 デザインリファレンス

### カラーパレット（既存維持）
```
メインカラー: #1ABC9C
セカンダリ: #27AE60
エラー: #E74C3C
背景: #F0FBF7
```

### フォント（既存維持）
```
メイン: 'Yomogi', -apple-system, sans-serif
```

---

## 📝 備考

### 既存機能への影響
- ✅ 割り勘機能: 影響なし（統合時に更新）
- ✅ リアルタイム更新: 影響なし
- ✅ PWA: 影響なし
- ✅ 数量・単位: 影響なし

### パフォーマンス
- 類似判定は参加者数に比例（O(n)）
- 参加者数が50人未満なら問題なし
- レーベンシュタイン距離の計算は軽量（O(n×m)）

### 将来の拡張案
- 統合候補の自動提案
- 統合履歴の記録
- 一括統合機能

---

**仕様策定者**: Conner  
**バージョン**: 3.8.0 (Minor)  
**承認**: ユーザー承認済み  
**次フェーズ**: David（実装）
