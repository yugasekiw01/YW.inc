#!/bin/bash
# カイダシ セマンティックバージョン自動更新スクリプト

set -e

show_usage() {
    CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "不明")
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  カイダシ バージョン更新"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "使い方:"
    echo "  ./update-version.sh <major|minor|patch>"
    echo "  または"
    echo "  ./update-version.sh <バージョン番号>"
    echo ""
    echo "セマンティックバージョニング:"
    echo "  major  - 大幅な変更・互換性なし (例: 3.7.0 → 4.0.0)"
    echo "  minor  - 新機能追加 (例: 3.7.0 → 3.8.0)"
    echo "  patch  - バグ修正のみ (例: 3.7.0 → 3.7.1)"
    echo ""
    echo "直接指定:"
    echo "  ./update-version.sh 3.8.0"
    echo ""
    echo "現在のバージョン: v$CURRENT_VERSION"
    echo ""
}

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

CURRENT_VERSION=$(cat VERSION)

# セマンティックバージョニング自動計算
case "$1" in
    major|MAJOR)
        # x.y.z → (x+1).0.0
        CURRENT_MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
        NEW_VERSION="$((CURRENT_MAJOR + 1)).0.0"
        BUMP_TYPE="Major"
        ;;
    minor|MINOR)
        # x.y.z → x.(y+1).0
        CURRENT_MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
        CURRENT_MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
        NEW_VERSION="$CURRENT_MAJOR.$((CURRENT_MINOR + 1)).0"
        BUMP_TYPE="Minor"
        ;;
    patch|PATCH)
        # x.y.z → x.y.(z+1)
        CURRENT_MAJOR=$(echo $CURRENT_VERSION | cut -d. -f1)
        CURRENT_MINOR=$(echo $CURRENT_VERSION | cut -d. -f2)
        CURRENT_PATCH=$(echo $CURRENT_VERSION | cut -d. -f3)
        NEW_VERSION="$CURRENT_MAJOR.$CURRENT_MINOR.$((CURRENT_PATCH + 1))"
        BUMP_TYPE="Patch"
        ;;
    *)
        # 直接バージョン指定
        NEW_VERSION=$1
        BUMP_TYPE="直接指定"
        ;;
esac

# x.y 形式を x.y.0 に正規化
if [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+$ ]]; then
    NEW_VERSION="$NEW_VERSION.0"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  カイダシ バージョン更新"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "更新タイプ: $BUMP_TYPE"
echo "現在: v$CURRENT_VERSION"
echo "更新: v$NEW_VERSION"
echo ""
read -p "続行しますか？ (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ キャンセルしました"
    exit 1
fi

echo ""
echo "📝 ファイルを更新中..."

# 1. VERSION ファイル更新
echo $NEW_VERSION > VERSION
echo "  ✅ VERSION"

# 2. sw.js 更新（キャッシュ名からpatch番号は除く）
CACHE_VERSION=$(echo $NEW_VERSION | cut -d. -f1-2)  # 3.8.0 → 3.8
sed -i "s/const CACHE_NAME = 'kaidashi-v.*'/const CACHE_NAME = 'kaidashi-v$CACHE_VERSION'/" sw.js
echo "  ✅ sw.js (kaidashi-v$CACHE_VERSION)"

# 3. manifest.json 更新
sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" manifest.json
echo "  ✅ manifest.json"

echo ""
echo "✨ バージョンを v$NEW_VERSION に更新しました！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  次のステップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. CHANGELOG.md を編集して変更内容を追記"
echo "   nano CHANGELOG.md"
echo ""
echo "2. 変更をコミット"
echo "   git add ."
echo "   git commit -m \"Release v$NEW_VERSION\""
echo ""
echo "3. タグを作成してプッシュ"
echo "   git tag v$NEW_VERSION"
echo "   git push origin main --tags"
echo ""
