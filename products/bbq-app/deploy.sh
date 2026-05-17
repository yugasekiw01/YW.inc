#!/usr/bin/env bash
# bbq-app 全自動デプロイスクリプト
# 使い方: Claudeに「all」と言う

set -e

BBQ_DIR="$(cd "$(dirname "$0")" && pwd)"

# トークンを .env.local から読み込む
if [ -f "$BBQ_DIR/.env.local" ]; then
  set -a
  source "$BBQ_DIR/.env.local"
  set +a
fi
REPO_DIR="$(cd "$BBQ_DIR/../.." && pwd)"
MIGRATIONS_DIR="$BBQ_DIR/migrations"

echo "🔥 bbq-app デプロイ開始..."

# ── 1. SQLマイグレーション ──────────────────────────────
SQL_FILES=()
if [ -d "$MIGRATIONS_DIR" ]; then
  while IFS= read -r -d '' f; do
    SQL_FILES+=("$f")
  done < <(find "$MIGRATIONS_DIR" -maxdepth 1 -name "*.sql" -print0 2>/dev/null | sort -z)
fi

if [ ${#SQL_FILES[@]} -gt 0 ]; then
  echo "📦 SQLマイグレーション実行中..."
  for sql_file in "${SQL_FILES[@]}"; do
    echo "  → $(basename "$sql_file")"
    node -e "
      const fs = require('fs');
      const sql = fs.readFileSync(process.argv[1], 'utf8');
      fetch('https://api.supabase.com/v1/projects/' + process.env.SUPABASE_PROJECT_REF + '/database/query', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer ' + process.env.SUPABASE_PAT,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ query: sql })
      }).then(r => r.json()).then(r => {
        if (r.message) { console.error('SQL error:', r.message); process.exit(1); }
        console.log('  ✅ OK');
      }).catch(e => { console.error(e); process.exit(1); });
    " "$sql_file"
  done
else
  echo "📦 SQLマイグレーション: なし（スキップ）"
fi

# ── 2. Git commit & push ────────────────────────────────
echo "📤 Git push中..."
cd "$REPO_DIR"
git add products/bbq-app/
if git diff --cached --quiet; then
  echo "  → 変更なし（スキップ）"
else
  git commit -m "bbq-app: deploy $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "  ✅ push完了"
fi

# ── 3. Netlify デプロイ ─────────────────────────────────
echo "🚀 Netlifyデプロイ中..."
netlify deploy \
  --dir="$BBQ_DIR" \
  --site="$NETLIFY_SITE_ID" \
  --auth="$NETLIFY_AUTH_TOKEN" \
  --prod \
  --message="deploy $(date '+%Y-%m-%d %H:%M')"

echo ""
echo "✅ 全て完了！"
echo "🌐 https://bright-dusk-b92ada.netlify.app"
