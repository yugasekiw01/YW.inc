# インフラ影響評価

**担当**: Imai  
**日付**: 2026-05-20  
**スプリント**: ui-differentiation-20260520

---

## 📋 評価サマリー

**総合評価**: ✅ **影響軽微 - UI変更のみ**

今回のUI変更は **index.html のフロントエンド変更のみ** であり、インフラへの大きな影響はない。
ただし、いくつかの注意事項あり。

---

## 🔍 確認項目

### 1. index.html 変更によるデプロイ手順への影響

**現状**:
- GitHub連携によるVercel自動デプロイ
- リポジトリ: https://github.com/yugasekiw01/YW.inc
- デプロイ対象: `products/kaidashi/`

**影響評価**: ✅ **影響なし**
- index.htmlの変更のみなので、既存の自動デプロイフローで対応可能
- 手動デプロイは不要
- ロールバックも `git revert` → 自動デプロイで対応可能

**推奨事項**:
- デプロイ後、即座に本番URL（https://kaidashi-lime.vercel.app）で動作確認
- 問題があれば即座にロールバック可能な体制で実施

---

### 2. Vercel 設定の変更が必要か

**現状の設定** (`vercel.json`):
```json
{
  "version": 2,
  "name": "kaidashi",
  "public": true,
  "cleanUrls": true,
  "trailingSlash": false,
  "headers": [ ... セキュリティヘッダー設定 ]
}
```

**影響評価**: ✅ **変更不要**
- セキュリティヘッダー（CSP, HSTS等）はそのまま有効
- UI変更によるルーティング変更なし
- index.html, app.htmlの2ページ構成は維持

**確認済み設定**:
- ✅ CSP（Content Security Policy）: Supabase, CDN許可済み
- ✅ X-Frame-Options: DENY
- ✅ HSTS: 有効

---

### 3. Supabase（カイダシ用）への影響

**現状**:
- Project Ref: `akovhthopauhmlbcjjfw`
- URL: `https://akovhthopauhmlbcjjfw.supabase.co`
- 使用テーブル: `events`, `items`, `participants`, `warikan_entries`

**影響評価**: ✅ **影響なし**
- DBスキーマ変更なし
- API呼び出しの変更なし（イベント作成ロジックは同じ）
- Realtime機能もそのまま継続

**注意事項**:
- UI変更後もSupabase JS SDKのバージョンは同じ（`@supabase/supabase-js@2`）
- 既存のイベントデータとの互換性は維持される

---

### 4. PWA 設定（manifest.json, sw.js）への影響

#### manifest.json
**影響評価**: ✅ **変更不要**
- start_url: "/" → 変更なし
- アイコン、テーマカラー → 変更なし

#### sw.js（Service Worker）
**影響評価**: ⚠️ **バージョンアップ必要**

**現状**:
```javascript
const CACHE_NAME = 'kaidashi-v2.1';
```

**必要な変更**:
```javascript
const CACHE_NAME = 'kaidashi-v2.2';  // UI変更に伴いバージョンアップ
```

**理由**:
- index.htmlの内容が変わるため、古いキャッシュを無効化する必要がある
- ユーザーが古いUIを見続けないようにする

**対応**:
- David（開発）にUI変更と同時にService Workerのバージョンアップを依頼
- デプロイ後、数分でユーザーに新しいUIが配信される

---

### 5. キャッシュ・CDN の考慮事項

**影響評価**: ⚠️ **注意が必要**

**Vercel CDNキャッシュ**:
- Vercelは自動的にHTMLファイルをキャッシュ
- デプロイ後、一部のユーザーに古いUIが表示される可能性あり

**対応策**:
1. **Service Workerバージョンアップ** → ブラウザキャッシュを無効化
2. **デプロイ後の確認** → シークレットモードで新UIを確認
3. **必要に応じてキャッシュパージ** → Vercelダッシュボードから手動クリア

**推奨手順**:
```bash
# デプロイ後の確認
1. Vercel デプロイ完了を確認
2. シークレットモード/プライベートブラウズで https://kaidashi-lime.vercel.app を開く
3. 新しいUIが表示されることを確認
4. 古いUIが表示される場合 → Vercelダッシュボードでキャッシュクリア
```

---

## 🚀 デプロイ手順の確認

### 現在のデプロイフロー

**方法1**: 自動デプロイ（推奨）
```bash
cd C:\Users\yugas\Yuja-Wang
git add products/kaidashi/
git commit -m "UI差別化: 新しいイベント作成フロー"
git push
# → Vercel が自動デプロイ
```

**方法2**: 手動デプロイ（緊急時）
```bash
cd products/kaidashi
vercel --prod
```

### ⚠️ 重要な発見：デプロイ先の矛盾

**問題**:
- `deploy.sh` では **Netlify** にデプロイ
- `CLAUDE.md` と `README.md` では **Vercel** と記載

**確認が必要**:
- 実際のデプロイ先はどちらか？
- deploy.shは古い設定の可能性

**推奨**:
- 実際のVercelプロジェクトを確認
- deploy.shが使われているか確認
- 使われていない場合は削除またはVercel用に修正

---

## 📊 監視・ログの要件

**影響評価**: ✅ **追加のログ不要**

**現状の監視**:
- ブラウザコンソールでのエラー監視（開発者ツール）
- Supabaseのログ（API呼び出し）
- Service Workerのログ（`console.log`）

**UI変更後も同じでOK**:
- エラーハンドリングは既存のまま
- 新UIで発生するエラーも既存の仕組みでキャッチ可能

**デプロイ後の確認項目**:
- [ ] ブラウザコンソールにエラーが出ないか
- [ ] イベント作成が正常に動作するか
- [ ] 既存イベントの表示は正常か
- [ ] スマホ・タブレットで問題ないか

---

## ✅ 完了基準

このインフラ影響確認は以下が満たされれば完了：

- [x] 全ての確認項目を評価
- [x] 影響範囲を特定
- [x] 必要な変更点を明記
- [x] デプロイ手順を確認
- [x] 監視・ログ要件を評価

---

## 📝 必要な変更点まとめ

### David（開発）への依頼事項

1. **Service Workerバージョンアップ**
   - `sw.js` の `CACHE_NAME` を `'kaidashi-v2.2'` に変更
   - index.html変更と同時にコミット

2. **デプロイ前の確認**
   - ローカル環境でのテスト
   - Service Worker登録の動作確認

### Imai（自分）のリリースフェーズでのタスク

1. **デプロイ実施**
   - Git push → Vercel自動デプロイ確認
   - または手動デプロイ（`vercel --prod`）

2. **本番動作確認**
   - シークレットモードで新UIを確認
   - イベント作成の動作テスト
   - 既存イベントの表示確認

3. **ロールバック準備**
   - 問題があれば `git revert` → 自動デプロイ
   - または Vercel ダッシュボードで前回のデプロイに戻す

---

## 🔄 次のアクション

- [ ] **Conner & Tiara** の成果物待ち
- [ ] **David** が実装完了したらリリースフェーズに移行
- [ ] デプロイ先（Vercel/Netlify）の矛盾を解消

---

**評価者**: Imai  
**ステータス**: ✅ 完了  
**次のフェーズ**: 実装（David）→ テスト（Tiara）→ リリース（Imai）
