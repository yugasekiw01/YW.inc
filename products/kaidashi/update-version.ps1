# カイダシ セマンティックバージョン自動更新スクリプト (PowerShell版)

param(
    [Parameter(Mandatory=$false)]
    [string]$VersionOrType
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    $CurrentVersion = "不明"
    if (Test-Path "VERSION") {
        $CurrentVersion = (Get-Content "VERSION" -Raw).Trim()
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  カイダシ バージョン更新" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "使い方:"
    Write-Host "  .\update-version.ps1 <major|minor|patch>"
    Write-Host "  または"
    Write-Host "  .\update-version.ps1 <バージョン番号>"
    Write-Host ""
    Write-Host "セマンティックバージョニング:"
    Write-Host "  major  - 大幅な変更・互換性なし (例: 3.7.0 → 4.0.0)" -ForegroundColor Red
    Write-Host "  minor  - 新機能追加 (例: 3.7.0 → 3.8.0)" -ForegroundColor Yellow
    Write-Host "  patch  - バグ修正のみ (例: 3.7.0 → 3.7.1)" -ForegroundColor Green
    Write-Host ""
    Write-Host "直接指定:"
    Write-Host "  .\update-version.ps1 3.8.0"
    Write-Host ""
    Write-Host "現在のバージョン: v$CurrentVersion"
    Write-Host ""
}

if (-not $VersionOrType) {
    Show-Usage
    exit 1
}

$CurrentVersion = (Get-Content "VERSION" -Raw).Trim()
$Parts = $CurrentVersion -split '\.'
$CurrentMajor = [int]$Parts[0]
$CurrentMinor = [int]$Parts[1]
$CurrentPatch = if ($Parts.Count -ge 3) { [int]$Parts[2] } else { 0 }

$BumpType = ""
$NewVersion = ""

# セマンティックバージョニング自動計算
switch ($VersionOrType.ToLower()) {
    "major" {
        $NewVersion = "$($CurrentMajor + 1).0.0"
        $BumpType = "Major"
    }
    "minor" {
        $NewVersion = "$CurrentMajor.$($CurrentMinor + 1).0"
        $BumpType = "Minor"
    }
    "patch" {
        $NewVersion = "$CurrentMajor.$CurrentMinor.$($CurrentPatch + 1)"
        $BumpType = "Patch"
    }
    default {
        # 直接バージョン指定
        $NewVersion = $VersionOrType
        $BumpType = "直接指定"
    }
}

# x.y 形式を x.y.0 に正規化
if ($NewVersion -match '^\d+\.\d+$') {
    $NewVersion = "$NewVersion.0"
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  カイダシ バージョン更新" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "更新タイプ: $BumpType" -ForegroundColor Magenta
Write-Host "現在: v$CurrentVersion" -ForegroundColor Yellow
Write-Host "更新: v$NewVersion" -ForegroundColor Green
Write-Host ""

$confirmation = Read-Host "続行しますか？ (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "❌ キャンセルしました" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 ファイルを更新中..." -ForegroundColor Cyan

# 1. VERSION ファイル更新
Set-Content -Path "VERSION" -Value $NewVersion -NoNewline
Write-Host "  ✅ VERSION" -ForegroundColor Green

# 2. sw.js 更新（キャッシュ名からpatch番号は除く）
$CacheVersion = ($NewVersion -split '\.')[0..1] -join '.'  # 3.8.0 → 3.8
$swContent = Get-Content "sw.js" -Raw
$swContent = $swContent -replace "const CACHE_NAME = 'kaidashi-v[^']*'", "const CACHE_NAME = 'kaidashi-v$CacheVersion'"
Set-Content -Path "sw.js" -Value $swContent -NoNewline
Write-Host "  ✅ sw.js (kaidashi-v$CacheVersion)" -ForegroundColor Green

# 3. manifest.json 更新
$manifestContent = Get-Content "manifest.json" -Raw
$manifestContent = $manifestContent -replace '"version": "[^"]*"', "`"version`": `"$NewVersion`""
Set-Content -Path "manifest.json" -Value $manifestContent -NoNewline
Write-Host "  ✅ manifest.json" -ForegroundColor Green

Write-Host ""
Write-Host "✨ バージョンを v$NewVersion に更新しました！" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  次のステップ" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. CHANGELOG.md を編集して変更内容を追記"
Write-Host "   notepad CHANGELOG.md"
Write-Host ""
Write-Host "2. 変更をコミット"
Write-Host "   git add ."
Write-Host "   git commit -m `"Release v$NewVersion`""
Write-Host ""
Write-Host "3. タグを作成してプッシュ"
Write-Host "   git tag v$NewVersion"
Write-Host "   git push origin main --tags"
Write-Host ""
