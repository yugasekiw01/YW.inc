/**
 * BBQ App ユニットテスト
 * 対象: アプリのピュア関数ロジック
 * 実行: node --test tiara/bbq-app/unit/logic.test.mjs
 */

import { test, describe } from 'node:test';
import assert from 'node:assert/strict';

// =====================================================
// テスト対象関数（index.html から抽出）
// =====================================================

/** XSS エスケープ */
function esc(s) {
    return String(s ?? '')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/** 割り勘計算（切り上げ） */
function calcPerPerson(totalAmount, peopleCount) {
    const amt = parseInt(totalAmount) || 0;
    return peopleCount > 0 ? Math.ceil(amt / peopleCount) : 0;
}

/** 統計計算 */
function calcStats(items) {
    const total     = items.length;
    const done      = items.filter(i => i.checked).length;
    const remaining = total - done;
    const pct       = total ? Math.round(done / total * 100) : 0;
    return { total, done, remaining, pct };
}

/** 挙手トグルロジック */
function toggleVote(voters, myName) {
    if (!voters) voters = [];
    return voters.includes(myName)
        ? voters.filter(v => v !== myName)
        : [...voters, myName];
}

/** カテゴリの fallback */
function resolveCategory(category) {
    return category || '調味料・その他';
}

// =====================================================
// D-04: XSS エスケープテスト
// =====================================================
describe('D-04 XSS エスケープ（esc関数）', () => {
    test('<script>タグをエスケープする', () => {
        const input  = '<script>alert(1)</script>';
        const result = esc(input);
        assert.equal(result, '&lt;script&gt;alert(1)&lt;/script&gt;');
        assert.ok(!result.includes('<'), 'HTMLタグが残っていてはいけない');
    });

    test('&をエスケープする', () => {
        assert.equal(esc('A & B'), 'A &amp; B');
    });

    test('"をエスケープする', () => {
        assert.equal(esc('"quoted"'), '&quot;quoted&quot;');
    });

    test('null/undefinedは空文字を返す', () => {
        assert.equal(esc(null), '');
        assert.equal(esc(undefined), '');
    });

    test('普通のテキストはそのまま返す', () => {
        assert.equal(esc('牛カルビ'), '牛カルビ');
    });

    test('XSS攻撃パターン: onerror属性', () => {
        const input  = '<img src=x onerror="alert(1)">';
        const result = esc(input);
        assert.ok(!result.includes('<img'), 'imgタグが残っていてはいけない');
    });
});

// =====================================================
// 割り勘計算テスト
// =====================================================
describe('割り勘計算（calcPerPerson）', () => {
    test('D-05: 金額=0円 → 0円', () => {
        assert.equal(calcPerPerson(0, 3), 0);
    });

    test('D-06: 3000円 ÷ 1人 → 3000円', () => {
        assert.equal(calcPerPerson(3000, 1), 3000);
    });

    test('D-07: 1000円 ÷ 3人 → 切り上げ 334円', () => {
        assert.equal(calcPerPerson(1000, 3), 334);
    });

    test('D-08: 大きな金額 9999999 ÷ 1 → そのまま', () => {
        assert.equal(calcPerPerson(9999999, 1), 9999999);
    });

    test('人数0のとき → 0円（ゼロ除算防止）', () => {
        assert.equal(calcPerPerson(1000, 0), 0);
    });

    test('金額が未入力(空文字)のとき → 0円', () => {
        assert.equal(calcPerPerson('', 2), 0);
    });

    test('割り切れる場合は切り上げなし: 900円 ÷ 3 = 300円', () => {
        assert.equal(calcPerPerson(900, 3), 300);
    });

    test('1円 ÷ 2人 → 切り上げ 1円', () => {
        assert.equal(calcPerPerson(1, 2), 1);
    });
});

// =====================================================
// 統計計算テスト
// =====================================================
describe('統計計算（calcStats）', () => {
    test('D-09: アイテムゼロ → 全て0、進捗0%', () => {
        const result = calcStats([]);
        assert.deepEqual(result, { total: 0, done: 0, remaining: 0, pct: 0 });
    });

    test('D-10: 全件チェック済み → 残り0、進捗100%', () => {
        const items = [
            { checked: true },
            { checked: true },
            { checked: true },
        ];
        const result = calcStats(items);
        assert.equal(result.done, 3);
        assert.equal(result.remaining, 0);
        assert.equal(result.pct, 100);
    });

    test('一部チェック: 3件中2件 → 66%', () => {
        const items = [
            { checked: true },
            { checked: true },
            { checked: false },
        ];
        const result = calcStats(items);
        assert.equal(result.total, 3);
        assert.equal(result.done, 2);
        assert.equal(result.remaining, 1);
        assert.equal(result.pct, 67); // Math.round(2/3*100)
    });

    test('全件未チェック → 進捗0%', () => {
        const items = [{ checked: false }, { checked: false }];
        const result = calcStats(items);
        assert.equal(result.pct, 0);
        assert.equal(result.remaining, 2);
    });
});

// =====================================================
// 挙手トグルテスト
// =====================================================
describe('挙手トグル（toggleVote）', () => {
    test('F-08: 未挙手→挙手：名前が追加される', () => {
        const result = toggleVote(['Alice'], 'Bob');
        assert.deepEqual(result, ['Alice', 'Bob']);
    });

    test('F-09: 挙手済み→取消：名前が除去される', () => {
        const result = toggleVote(['Alice', 'Bob'], 'Alice');
        assert.deepEqual(result, ['Bob']);
    });

    test('初めての挙手（votersが空配列）', () => {
        const result = toggleVote([], 'Alice');
        assert.deepEqual(result, ['Alice']);
    });

    test('votersがnullでも動作する', () => {
        const result = toggleVote(null, 'Alice');
        assert.deepEqual(result, ['Alice']);
    });

    test('最後の1人が取消 → 空配列になる', () => {
        const result = toggleVote(['Alice'], 'Alice');
        assert.deepEqual(result, []);
    });

    test('同名で二重挙手しない', () => {
        // 既に追加済みならトグルで除去される（二重登録されない）
        const beforeToggle = toggleVote([], 'Alice');     // ['Alice']
        const afterToggle  = toggleVote(beforeToggle, 'Alice'); // []
        assert.deepEqual(afterToggle, []);
    });
});

// =====================================================
// カテゴリ fallback テスト
// =====================================================
describe('カテゴリ fallback', () => {
    test('カテゴリなし → 調味料・その他', () => {
        assert.equal(resolveCategory(null), '調味料・その他');
        assert.equal(resolveCategory(undefined), '調味料・その他');
        assert.equal(resolveCategory(''), '調味料・その他');
    });

    test('カテゴリあり → そのまま返す', () => {
        assert.equal(resolveCategory('肉'), '肉');
        assert.equal(resolveCategory('飲み物'), '飲み物');
    });
});
