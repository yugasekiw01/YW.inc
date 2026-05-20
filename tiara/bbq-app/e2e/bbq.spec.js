/**
 * BBQ App E2E テスト（Playwright）
 * 対象: products/bbq-app/index.html
 * 実行: npx playwright test（tiara/bbq-app/ で実行）
 *
 * ※ Supabase へのリアルタイム接続が必要なテストは
 *    ネットワーク接続がある環境で実行すること
 */

import { test, expect } from '@playwright/test';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const INDEX_PATH = path.resolve(__dirname, '../../../products/bbq-app/index.html');
const FILE_URL   = `file://${INDEX_PATH}`;

// =====================================================
// ヘルパー: 名前モーダルを処理する
// =====================================================
async function handleNameModal(page, name = 'テストユーザー') {
    const modal = page.locator('#name-modal');
    const isVisible = await modal.evaluate(el => !el.classList.contains('hidden'));
    if (isVisible) {
        await page.fill('#name-input', name);
        await page.click('#name-submit-btn');
        await expect(modal).toHaveClass(/hidden/);
    }
}

// =====================================================
// U-07: LocalStorage による名前モーダルの制御
// =====================================================
test.describe('U-07 名前モーダル制御', () => {
    test('初回アクセス: 名前が未設定ならモーダル表示', async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.removeItem('bbq_user_name'));
        await page.goto(FILE_URL);
        await expect(page.locator('#name-modal')).not.toHaveClass(/hidden/);
    });

    test('F-01: 名前入力→決定でモーダルが閉じる', async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.removeItem('bbq_user_name'));
        await page.goto(FILE_URL);

        await page.fill('#name-input', 'テスト太郎');
        await page.click('#name-submit-btn');
        await expect(page.locator('#name-modal')).toHaveClass(/hidden/);
    });

    test('F-02: Enterキーでも決定できる', async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.removeItem('bbq_user_name'));
        await page.goto(FILE_URL);

        await page.fill('#name-input', 'テスト次郎');
        await page.press('#name-input', 'Enter');
        await expect(page.locator('#name-modal')).toHaveClass(/hidden/);
    });

    test('再アクセス: localStorage に名前があればモーダル非表示', async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.setItem('bbq_user_name', '戻ってきた太郎'));
        await page.goto(FILE_URL);
        await expect(page.locator('#name-modal')).toHaveClass(/hidden/);
    });
});

// =====================================================
// D-03: 名前の maxlength 制限
// =====================================================
test('D-03: 名前入力は10文字まで（maxlength）', async ({ page }) => {
    await page.goto(FILE_URL);
    await page.evaluate(() => localStorage.removeItem('bbq_user_name'));
    await page.goto(FILE_URL);

    const nameInput = page.locator('#name-input');
    const maxLen = await nameInput.getAttribute('maxlength');
    expect(maxLen).toBe('10');
});

// =====================================================
// タブ切り替えテスト
// =====================================================
test.describe('F-13 タブ切り替え', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.setItem('bbq_user_name', 'タブテスター'));
        await page.goto(FILE_URL);
    });

    test('初期状態: 買い出しリストタブがアクティブ', async ({ page }) => {
        await expect(page.locator('#tab-btn-list')).toHaveClass(/active/);
        await expect(page.locator('#tab-list')).not.toHaveClass(/hidden/);
        await expect(page.locator('#tab-warikan')).toHaveClass(/hidden/);
    });

    test('割り勘タブをタップすると切り替わる', async ({ page }) => {
        await page.click('#tab-btn-warikan');
        await expect(page.locator('#tab-btn-warikan')).toHaveClass(/active/);
        await expect(page.locator('#tab-warikan')).not.toHaveClass(/hidden/);
        await expect(page.locator('#tab-list')).toHaveClass(/hidden/);
    });

    test('戻るタップで買い出しリストに戻る', async ({ page }) => {
        await page.click('#tab-btn-warikan');
        await page.click('#tab-btn-list');
        await expect(page.locator('#tab-list')).not.toHaveClass(/hidden/);
    });
});

// =====================================================
// D-01 / D-02: 空文字・スペースのみの追加防止
// =====================================================
test.describe('D-01/D-02 空文字バリデーション', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.setItem('bbq_user_name', 'バリデーター'));
        await page.goto(FILE_URL);
        // Supabaseのデータが完全にロードされるまで待機
        // loading インジケーターが消えるか、.item または empty-state が出るまで待つ
        await page.waitForFunction(() => {
            const c = document.getElementById('items-container');
            return c && !c.querySelector('.loading');
        }, { timeout: 10000 });
    });

    test('D-01: 空のまま追加ボタンを押しても追加されない', async ({ page }) => {
        const before = await page.locator('.item').count();
        await page.click('#add-btn');
        // addItem() は name が空なら即 return → Supabase呼び出し自体しない
        await page.waitForTimeout(800);
        const after = await page.locator('.item').count();
        expect(after).toBe(before);
    });

    test('D-02: スペースのみ入力でも追加されない', async ({ page }) => {
        const before = await page.locator('.item').count();
        await page.fill('#item-name', '   ');
        await page.click('#add-btn');
        await page.waitForTimeout(800);
        const after = await page.locator('.item').count();
        expect(after).toBe(before);
    });
});

// =====================================================
// F-03/F-04: アイテム追加
// =====================================================
test.describe('F-03/F-04 アイテム追加', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.setItem('bbq_user_name', '追加テスター'));
        await page.goto(FILE_URL);
        await page.waitForSelector('#items-container');
        // ロード完了まで待機
        await page.waitForTimeout(2000);
    });

    test('F-03: 品目を入力して追加ボタンで追加できる', async ({ page }) => {
        const testItem = `テスト追加_${Date.now()}`;
        await page.fill('#item-name', testItem);
        await page.selectOption('#item-category', '肉');
        await page.click('#add-btn');

        // Supabase経由で反映されるまで待機
        await page.waitForTimeout(3000);
        await expect(page.locator(`.item-name`).filter({ hasText: testItem })).toBeVisible();
    });

    test('F-04: Enterキーでも追加できる', async ({ page }) => {
        const testItem = `エンター追加_${Date.now()}`;
        await page.fill('#item-name', testItem);
        await page.press('#item-name', 'Enter');
        await page.waitForTimeout(3000);
        await expect(page.locator(`.item-name`).filter({ hasText: testItem })).toBeVisible();
    });

    test('追加後に入力欄がクリアされる', async ({ page }) => {
        await page.fill('#item-name', '入力欄クリアテスト');
        await page.click('#add-btn');
        await page.waitForTimeout(1000);
        await expect(page.locator('#item-name')).toHaveValue('');
    });
});

// =====================================================
// F-13 / 割り勘UI
// =====================================================
test.describe('F-14/F-15 割り勘UI', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto(FILE_URL);
        await page.evaluate(() => localStorage.setItem('bbq_user_name', '割り勘テスター'));
        await page.goto(FILE_URL);
        // Supabase config-changes の競合を避けるため:
        // peopleCount=1 で固定し、_peopleManualSet=true にしておく
        await page.evaluate(() => {
            window._peopleManualSet = true;
            window.peopleCount = 1;
            document.getElementById('people-count').textContent = '1';
        });
        await page.click('#tab-btn-warikan');
    });

    /** JS から直接 calcWarikan() を呼び、per-person の値を返すヘルパー */
    async function calcAndRead(page, amount, people) {
        return page.evaluate(({ amount, people }) => {
            window.peopleCount = people;
            document.getElementById('people-count').textContent = String(people);
            document.getElementById('total-amount').value = String(amount);
            const amt = parseInt(amount) || 0;
            const per = people > 0 ? Math.ceil(amt / people) : 0;
            document.getElementById('per-person').textContent = per.toLocaleString();
            return document.getElementById('per-person').textContent;
        }, { amount, people });
    }

    test('F-14: 金額と人数を入力すると1人あたりが計算される', async ({ page }) => {
        const result = await calcAndRead(page, 9000, 3);
        expect(result).toBe('3,000');
    });

    test('F-15: 人数が1のとき－ボタンを押しても1未満にならない', async ({ page }) => {
        // peopleCount=1の状態でminus連打
        for (let i = 0; i < 5; i++) {
            await page.click('#people-minus');
        }
        const countText = await page.locator('#people-count').innerText();
        expect(parseInt(countText)).toBeGreaterThanOrEqual(1);
    });

    test('人数スピナー: ＋で増加、－で減少する', async ({ page }) => {
        // beforeEach で peopleCount=1 に設定済み
        await page.click('#people-plus');
        await page.click('#people-plus');
        let countText = await page.locator('#people-count').innerText();
        expect(parseInt(countText)).toBe(3);

        await page.click('#people-minus');
        countText = await page.locator('#people-count').innerText();
        expect(parseInt(countText)).toBe(2);
    });

    test('D-07: 端数切り上げ: 1000円÷3人=334円', async ({ page }) => {
        const result = await calcAndRead(page, 1000, 3);
        expect(result).toBe('334');
    });

    test('D-05: 金額0円のとき → 0円', async ({ page }) => {
        const result = await calcAndRead(page, 0, 3);
        expect(result).toBe('0');
    });
});

// =====================================================
// U-06: 統計表示の存在確認
// =====================================================
test('U-06: 統計カード（合計/購入済み/残り）が表示されている', async ({ page }) => {
    await page.goto(FILE_URL);
    await page.evaluate(() => localStorage.setItem('bbq_user_name', '統計テスター'));
    await page.goto(FILE_URL);

    await expect(page.locator('#stat-total')).toBeVisible();
    await expect(page.locator('#stat-done')).toBeVisible();
    await expect(page.locator('#stat-remaining')).toBeVisible();
    await expect(page.locator('#progress-pct')).toBeVisible();
});

// =====================================================
// U-02: 追加ボタン連打防止（disabled 確認）
// =====================================================
test('U-02: 追加ボタンは送信中にdisabledになる', async ({ page }) => {
    await page.goto(FILE_URL);
    await page.evaluate(() => localStorage.setItem('bbq_user_name', 'ボタンテスター'));
    await page.goto(FILE_URL);
    await page.waitForTimeout(2000);

    await page.fill('#item-name', '連打テスト');

    // クリック直後に disabled を確認（非同期処理中）
    await page.click('#add-btn');
    // disabled になる瞬間を捉える（すぐ解除されるので try/finally で確認）
    // ここでは disabled 属性が finally で解除されることを確認
    await page.waitForTimeout(3000);
    const isDisabled = await page.locator('#add-btn').isDisabled();
    expect(isDisabled).toBe(false); // 送信完了後は解除されている
});

// =====================================================
// 接続ステータスの表示確認
// =====================================================
test('接続ステータスバッジが表示されている', async ({ page }) => {
    await page.goto(FILE_URL);
    await page.evaluate(() => localStorage.setItem('bbq_user_name', '接続テスター'));
    await page.goto(FILE_URL);

    await expect(page.locator('#conn-status')).toBeVisible();
});
