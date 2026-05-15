param()

$input_text = [Console]::In.ReadToEnd()

try {
    $data = $input_text | ConvertFrom-Json
} catch {
    exit 0
}

$model = if ($data.model.display_name) { $data.model.display_name } else { "?" }
$ctx_raw = if ($null -ne $data.context_window.used_percentage) { $data.context_window.used_percentage } else { 0 }
$ctx_pct = [int][math]::Floor([double]$ctx_raw)

$five_h = $data.rate_limits.five_hour.used_percentage
$five_h_reset = $data.rate_limits.five_hour.resets_at
$week = $data.rate_limits.seven_day.used_percentage

function Get-Color($pct) {
    if ($pct -ge 80) { return "Red" }
    elseif ($pct -ge 50) { return "Yellow" }
    else { return "Green" }
}

$five_h_remaining = ""
if ($five_h_reset) {
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $diff = $five_h_reset - $now
    if ($diff -gt 0) {
        $h = [math]::Floor($diff / 3600)
        $m = [math]::Floor(($diff % 3600) / 60)
        $five_h_remaining = "${h}h${m}m"
    } else {
        $five_h_remaining = "reset soon"
    }
}

$parts = @("[${model}]")

if ($null -ne $five_h) {
    $five_h_int = [int][math]::Round([double]$five_h)
    $part = "5h:${five_h_int}%"
    if ($five_h_remaining) { $part += "(${five_h_remaining})" }
    $parts += $part
}

if ($null -ne $week) {
    $week_int = [int][math]::Round([double]$week)
    $parts += "7d:${week_int}%"
}

$bar_width = 8
$filled = [math]::Floor($ctx_pct * $bar_width / 100)
$empty = $bar_width - $filled
$bar = ("█" * $filled) + ("░" * $empty)

$esc = [char]27
if ($ctx_pct -ge 90) {
    $parts += "${esc}[31m⚠ ctx:${bar}${ctx_pct}%${esc}[0m"
} elseif ($ctx_pct -ge 80) {
    $parts += "${esc}[33mctx:${bar}${ctx_pct}%${esc}[0m"
} else {
    $parts += "ctx:${bar}${ctx_pct}%"
}

$output = $parts -join " "

$result = [ordered]@{
    statusLine = $output
} | ConvertTo-Json -Compress

Write-Output $result
