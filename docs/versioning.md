# YW.inc バージョニングルール

**対象**: 全エージェント（David、Tiara、Imai、Sakura、Conner）  
**更新日**: 2026-05-20

---

## 📦 セマンティックバージョニング

YW.inc の全プロダクトは **セマンティックバージョニング（Semantic Versioning 2.0.0）** に従います。

### バージョン形式

```
major.minor.patch
```

例: `3.8.1`

---

## 🎯 バージョンの種類

| 種類 | 更新内容 | 例 | 担当フェーズ |
|------|---------|-----|------------|
| **Major** | 大幅な変更・後方互換性なし | 3.8.0 → **4.0.0** | 要件定義・実装 |
| **Minor** | 新機能追加（後方互換性あり） | 3.7.0 → **3.8.0** | 要件定義・実装 |
| **Patch** | バグ修正のみ | 3.7.0 → **3.7.1** | テスト・保守 |

---

## 📋 各エージェントの責務

### Conner（コンサルタント）

**要件定義時**:
- ✅ 新機能の規模を判断し、バージョンタイプを決定
- ✅ 仕様書にバージョン番号を明記
- ✅ Davidへの引き継ぎ時にバージョン情報を伝える

**判断基準**:
```
大幅なUI変更・DB構造変更 → Major (4.0.0)
新機能追加               → Minor (3.8.0)
既存機能の改善のみ       → Minor (3.8.0)
```

**例**:
- UI差別化（walica対策）→ **Major (4.0.0)** - UIが大幅に変わる
- 参加者重複防止機能 → **Minor (3.8.0)** - 新機能だが既存に影響小

---

### David（開発）

**実装時**:
- ✅ 実装開始前に現在のバージョンを確認
- ✅ 実装完了後、バージョン更新スクリプトを実行
- ✅ CHANGELOG.md に変更内容を記載
- ✅ Tiaraにバージョン情報を引き継ぐ

**バージョン更新コマンド**:
```powershell
# 自動計算（推奨）
cd products/<プロダクト名>
.\update-version.ps1 minor   # 新機能
.\update-version.ps1 patch   # バグ修正
.\update-version.ps1 major   # 大幅変更

# 直接指定
.\update-version.ps1 3.8.0
```

**Git操作**:
```bash
# 実装完了後
git add .
git commit -m "Release v3.8.0: 参加者重複防止機能追加"
git tag v3.8.0
git push origin main --tags
```

---

### Tiara（テスト）

**テスト時**:
- ✅ テスト対象バージョンを記録
- ✅ バグ発見時、Patch リリースが必要か判断
- ✅ リグレッションテスト範囲をバージョンタイプで決定

**テスト範囲の目安**:
```
Major更新 → 全機能テスト
Minor更新 → 新機能 + 関連機能テスト
Patch更新 → 修正箇所のみテスト
```

**バグ修正でのバージョン更新**:
```powershell
# バグ修正後
.\update-version.ps1 patch
```

---

### Imai（インフラ・保守）

**デプロイ時**:
- ✅ デプロイ前にバージョン番号を確認
- ✅ Vercel/Netlify でタグを指定してデプロイ
- ✅ 本番環境のバージョンを記録

**ロールバック時**:
```bash
# 特定バージョンにロールバック
git checkout v3.7.0
vercel --prod
```

**緊急パッチ適用**:
```powershell
# 本番で重大なバグ発見
.\update-version.ps1 patch
git commit -m "Hotfix v3.7.1: 割り勘計算エラー修正"
git tag v3.7.1
git push origin main --tags
```

---

### Sakura（秘書）

**プロジェクト管理時**:
- ✅ スプリント計画時にバージョン目標を設定
- ✅ リリースノートの作成
- ✅ ユーザーへのリリース通知

---

## 🚫 禁止事項

### ❌ やってはいけないこと

1. **手動でバージョン番号を変更**
   - ❌ `VERSION` ファイルを直接編集
   - ✅ 必ず `update-version.ps1` を使用

2. **複数ファイルの不一致**
   - ❌ `VERSION` と `manifest.json` が異なる
   - ✅ スクリプトが自動で同期

3. **タグなしリリース**
   - ❌ git tag を付けずにデプロイ
   - ✅ 必ず `git tag vX.Y.Z` を作成

4. **CHANGELOG.md の未更新**
   - ❌ バージョンだけ上げて変更内容を書かない
   - ✅ 必ず変更内容を記載

---

## 📝 バージョン更新フロー（完全版）

### 新機能リリース（Minor）

```mermaid
Conner → David → Tiara → Imai
  ↓       ↓       ↓       ↓
要件定義  実装    テスト  デプロイ
v3.8決定 v3.8実装 v3.8検証 v3.8公開
```

**1. Conner（要件定義）**
```markdown
# 仕様書
スプリント: カイダシ v3.8
機能: 参加者重複防止
バージョンタイプ: Minor (3.7.0 → 3.8.0)
```

**2. David（実装）**
```powershell
# 実装開始
cd products/kaidashi

# 実装...

# 完了後
.\update-version.ps1 minor
notepad CHANGELOG.md  # 変更内容を追記
git add .
git commit -m "Release v3.8.0: 参加者重複防止機能追加"
git tag v3.8.0
git push origin main --tags
```

**3. Tiara（テスト）**
```powershell
# テスト対象確認
cat VERSION  # 3.8.0

# テスト実施...

# バグ発見時
.\update-version.ps1 patch  # 3.8.0 → 3.8.1
git commit -m "Fix v3.8.1: 参加者統合時のエラー修正"
git tag v3.8.1
git push origin main --tags
```

**4. Imai（デプロイ）**
```bash
# タグを指定してデプロイ
git checkout v3.8.1
vercel --prod

# デプロイ記録
echo "v3.8.1 deployed at $(date)" >> deploy.log
```

---

## 🔍 現在のバージョン確認方法

### コマンドライン
```powershell
# カイダシ
cd products/kaidashi
cat VERSION
```

### コード内
```javascript
// manifest.json
fetch('/manifest.json')
  .then(r => r.json())
  .then(data => console.log('Version:', data.version));
```

---

## 📊 プロダクト別バージョン

| プロダクト | 現在 | 次期予定 | ファイル |
|-----------|------|---------|---------|
| カイダシ | v3.7.0 | v3.8.0 | `products/kaidashi/VERSION` |
| BBQ App | - | - | （バージョン管理未導入） |

---

## 🛠️ トラブルシューティング

### Q: バージョンが不一致になった
```powershell
# 強制修正（最終手段）
.\update-version.ps1 3.8.0
```

### Q: 間違ったバージョンをタグ付けした
```bash
# タグ削除
git tag -d v3.8.0
git push origin :refs/tags/v3.8.0

# 正しいバージョンで再実行
.\update-version.ps1 3.8.0
git tag v3.8.0
git push origin main --tags
```

### Q: Patch が多すぎる（3.7.10 等）
- 問題なし。Patch 番号に上限はありません
- ただし、10個以上になったら Minor アップデートを検討

---

## 📚 参考

- [Semantic Versioning 2.0.0](https://semver.org/)
- カイダシ: `products/kaidashi/CHANGELOG.md`
- 更新スクリプト: `products/kaidashi/update-version.ps1`

---

**重要**: このルールは全エージェントが遵守すること。  
不明点があれば Conner に相談してください。
