param()

$inputText = [Console]::In.ReadToEnd()

try {
    $data = $inputText | ConvertFrom-Json
} catch {
    exit 0
}

$prompt = $data.prompt
if (-not $prompt -or -not ($prompt -match 'おはよう')) {
    exit 0
}

$timestamp = Get-Date -Format 'yyyy/MM/dd HH:mm'
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('=== Sakura 朝のブリーフィング ===')
$lines.Add("日時: $timestamp")
$lines.Add('')

# ── AI・ハーネスエンジニアリング ニュース ────────────────────────
$lines.Add('## AI・ハーネスエンジニアリング ニュース（HackerNews 直近）')
try {
    $hnUrl = 'https://hn.algolia.com/api/v1/search_by_date?query=Claude+Copilot+LLM+AI+agent&tags=story&hitsPerPage=5'
    $hn = Invoke-RestMethod -Uri $hnUrl -TimeoutSec 10
    foreach ($hit in $hn.hits) {
        if ($hit.title) {
            $title = $hit.title
            $pts   = $hit.points
            $url   = $hit.url
            $lines.Add("- $title ($pts pts)")
            if ($url) { $lines.Add("  $url") }
        }
    }
    if ($hn.hits.Count -eq 0) { $lines.Add('（該当記事なし）') }
} catch {
    $errMsg = $_.Exception.Message
    $lines.Add("（取得失敗: $errMsg）")
}
$lines.Add('')

# ── DTM プラグイン ニュース ──────────────────────────────────────
$lines.Add('## DTM プラグイン ニュース（Create Digital Music）')
try {
    $cdmUrl = 'https://cdm.link/feed/'
    $cdm = Invoke-RestMethod -Uri $cdmUrl -TimeoutSec 10
    $cdmItems = @($cdm) | Select-Object -First 5
    foreach ($item in $cdmItems) {
        if ($item.title) {
            $iTitle = $item.title
            $iLink  = $item.link
            $lines.Add("- $iTitle")
            if ($iLink) { $lines.Add("  $iLink") }
        }
    }
} catch {
    $errMsg2 = $_.Exception.Message
    $lines.Add("（取得失敗: $errMsg2）")
}
$lines.Add('')

# ── 未完了タスクリマインド ────────────────────────────────────────
$lines.Add('## 未完了タスクリマインド')
$todosDir = 'C:\Users\yugas\Yuja-Wang\sakura\.secretary\todos'
$latestFile = Get-ChildItem -Path $todosDir -Filter '*.md' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}\.md$' } |
    Sort-Object Name -Descending |
    Select-Object -First 1

if ($latestFile) {
    $fname = $latestFile.Name
    $lines.Add("（最新ファイル: $fname）")
    $content = Get-Content $latestFile.FullName -Encoding UTF8 -Raw
    $pending = ($content -split "`r?`n") | Where-Object { $_ -match '^\s*- \[ \]' }
    if ($pending) {
        foreach ($task in $pending) {
            $taskLine = $task.Trim()
            $lines.Add($taskLine)
        }
    } else {
        $lines.Add('（未完了タスクなし - よくできました！）')
    }
} else {
    $lines.Add('（タスクファイルが見つかりません）')
}

$lines.Add('')
$lines.Add('---')
$lines.Add('上記の情報をもとに、日本語で簡潔な朝のブリーフィングをしてください。')

$contextText = $lines -join "`n"

$result = [ordered]@{
    hookSpecificOutput = [ordered]@{
        hookEventName     = 'UserPromptSubmit'
        additionalContext = $contextText
    }
} | ConvertTo-Json -Depth 3 -Compress

Write-Output $result



