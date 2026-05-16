#!/usr/bin/env bash
# カイダシ 全自動デプロイスクリプト
# 使い方: Claudeに「all」と言う

set -e

KAIDASHI_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$KAIDASHI_DIR/../.." && pwd)"

# トークンを .env.local から読み込む
if [ -f "$KAIDASHI_DIR/.env.local" ]; then
  set -a; source "$KAIDASHI_DIR/.env.local"; set +a
fi

echo "🛒 カイダシ デプロイ開始..."

# ── 1. SQLマイグレーション ──────────────────────────────
MIGRATIONS_DIR="$KAIDASHI_DIR/migrations"
if [ -d "$MIGRATIONS_DIR" ]; then
  SQL_FILES=()
  while IFS= read -r -d '' f; do SQL_FILES+=("$f"); done < <(find "$MIGRATIONS_DIR" -name "*.sql" -print0 2>/dev/null | sort -z)
  if [ ${#SQL_FILES[@]} -gt 0 ]; then
    echo "📦 SQLマイグレーション実行中..."
    for sql_file in "${SQL_FILES[@]}"; do
      echo "  → $(basename "$sql_file")"
      node -e "
        const sql = require('fs').readFileSync('$sql_file', 'utf8');
        fetch('https://api.supabase.com/v1/projects/$SUPABASE_PROJECT_REF/database/query', {
          method: 'POST',
          headers: { 'Authorization': 'Bearer $SUPABASE_PAT', 'Content-Type': 'application/json' },
          body: JSON.stringify({ query: sql })
        }).then(r => r.json()).then(r => {
          if (r.message && !r.message.includes('already exists')) { console.error('SQL error:', r.message); process.exit(1); }
          console.log('  ✅ OK');
        }).catch(e => { console.error(e); process.exit(1); });
      "
    done
  fi
fi

# ── 2. Git commit & push ────────────────────────────────
echo "📤 Git push中..."
cd "$REPO_DIR"
git add products/kaidashi/
if git diff --cached --quiet; then
  echo "  → 変更なし（スキップ）"
else
  git commit -m "kaidashi: deploy $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "  ✅ push完了"
fi

# ── 3. Netlify デプロイ ─────────────────────────────────
echo "🚀 Netlifyデプロイ中..."
netlify deploy \
  --dir="$KAIDASHI_DIR" \
  --site="$NETLIFY_SITE_ID" \
  --auth="$NETLIFY_AUTH_TOKEN" \
  --prod \
  --message="kaidashi deploy $(date '+%Y-%m-%d %H:%M')"

echo ""
echo "✅ 全て完了！"
echo "🌐 Netlify URL を確認してください"
