/**
 * テスト後クリーンアップスクリプト
 * Supabase からテスト用データを削除する
 */

const SUPABASE_URL      = 'https://jzyjarmagxvljraknbec.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6eWphcm1hZ3h2bGpyYWtuYmVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4Mjc3NDcsImV4cCI6MjA5NDQwMzc0N30.a-V8AikYHUX2axRF22a1ZnpI6c1RKVOogK7mIxLLYAU';

const headers = {
    'apikey':        SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type':  'application/json',
};

// テストで使った参加者名
const TEST_PARTICIPANTS = [
    'テストユーザー', 'テスト太郎', 'テスト次郎', '戻ってきた太郎',
    'タブテスター', 'バリデーター', '追加テスター', '統計テスター',
    'ボタンテスター', '接続テスター', '割り勘テスター',
];

// テストアイテムのキーワード（like検索用）
const TEST_ITEM_KEYWORDS = [
    'テスト追加_', 'エンター追加_', '入力欄クリアテスト', '連打テスト',
];

async function deleteParticipants() {
    console.log('\n👥 テスト参加者を削除中...');
    for (const name of TEST_PARTICIPANTS) {
        const res = await fetch(
            `${SUPABASE_URL}/rest/v1/participants?name=eq.${encodeURIComponent(name)}`,
            { method: 'DELETE', headers: { ...headers, 'Prefer': 'return=representation' } }
        );
        if (res.ok) {
            const data = await res.json();
            if (data.length > 0) console.log(`  ✅ 削除: ${name}`);
            else                  console.log(`  ⏭  スキップ（存在しない）: ${name}`);
        } else {
            console.error(`  ❌ エラー: ${name}`, res.status);
        }
    }
}

async function deleteTestItems() {
    console.log('\n🛒 テストアイテムを削除中...');
    for (const keyword of TEST_ITEM_KEYWORDS) {
        const res = await fetch(
            `${SUPABASE_URL}/rest/v1/bbq_items?name=like.*${encodeURIComponent(keyword)}*`,
            { method: 'DELETE', headers: { ...headers, 'Prefer': 'return=representation' } }
        );
        if (res.ok) {
            const data = await res.json();
            if (data.length > 0) {
                data.forEach(item => console.log(`  ✅ 削除: 「${item.name}」`));
            } else {
                console.log(`  ⏭  スキップ（該当なし）: *${keyword}*`);
            }
        } else {
            console.error(`  ❌ エラー: *${keyword}*`, res.status);
        }
    }
}

async function listRemaining() {
    console.log('\n📋 削除後の残存データ確認...');

    const [itemsRes, peopleRes] = await Promise.all([
        fetch(`${SUPABASE_URL}/rest/v1/bbq_items?select=name,category,checked&order=created_at.asc`, { headers }),
        fetch(`${SUPABASE_URL}/rest/v1/participants?select=name`, { headers }),
    ]);

    const items   = await itemsRes.json();
    const people  = await peopleRes.json();

    console.log(`\n  🛒 bbq_items: ${items.length}件`);
    items.forEach(i => console.log(`     - [${i.checked ? '✔' : ' '}] ${i.name} (${i.category})`));

    console.log(`\n  👥 participants: ${people.length}人`);
    people.forEach(p => console.log(`     - ${p.name}`));
}

(async () => {
    console.log('🔥 BBQ App テストデータ クリーンアップ開始');
    await deleteParticipants();
    await deleteTestItems();
    await listRemaining();
    console.log('\n✨ クリーンアップ完了！');
})();
