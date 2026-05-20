# Agent Hub 連携ガイド

## 概要
各エージェントは作業開始・完了時にSupabaseを更新し、スマホからリアルタイムで進捗を確認できるようにする。

## Supabase接続情報

```
URL: https://pemepunzxrvmsvjjhsry.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlbWVwdW56eHJ2bXN2ampoc3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTk2NTcsImV4cCI6MjA5NDY3NTY1N30.AvfSOhXCQWk5TDzP0JaP_z54sonNpCwYlIOE2TXslCE
```

## 必須アクション

### 1. 作業開始時（status → busy）
```powershell
$h = @{ "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlbWVwdW56eHJ2bXN2ampoc3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTk2NTcsImV4cCI6MjA5NDY3NTY1N30.AvfSOhXCQWk5TDzP0JaP_z54sonNpCwYlIOE2TXslCE"; "Content-Type" = "application/json" }
$body = '{"status":"busy","last_seen":"' + (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") + '"}'
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_status?agent_name=eq.<自分の名前>" -Method PATCH -Headers $h -Body $body
```

### 2. 作業完了時（status → idle）
```powershell
$body = '{"status":"idle","last_seen":"' + (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") + '"}'
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_status?agent_name=eq.<自分の名前>" -Method PATCH -Headers $h -Body $body
```

### 3. 他エージェントにタスク依頼時
```powershell
$task = @{
    sprint_name = "<スプリント名>"
    phase = "<要件定義|実装|テスト|リリース|振り返り>"
    from_agent = "<自分の名前>"
    to_agent = "<依頼先の名前>"
    task_type = "<development|testing|review|infrastructure>"
    title = "<タスクタイトル>"
    description = "<詳細説明>"
    priority = "<high|normal|low>"
    status = "pending"
} | ConvertTo-Json -Compress
$body = [System.Text.Encoding]::UTF8.GetBytes($task)
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_tasks" -Method POST -Headers $h -Body $body -ContentType "application/json; charset=utf-8"
```

### 4. タスク受け取り時（status → running）
```powershell
$body = '{"status":"running"}'
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_tasks?id=eq.<タスクID>" -Method PATCH -Headers $h -Body $body
```

### 5. タスク完了時（status → done）
```powershell
$body = '{"status":"done","progress":100}'
Invoke-RestMethod -Uri "https://pemepunzxrvmsvjjhsry.supabase.co/rest/v1/agent_tasks?id=eq.<タスクID>" -Method PATCH -Headers $h -Body $body
```

## エージェント名一覧
| 名前 | 役割 |
|------|------|
| sakura | 秘書 |
| conner | コンサル |
| david | 開発 |
| tiara | テスト |
| imai | インフラ |

## Wモデルフェーズ
1. **要件定義** - Conner/Sakura主導
2. **実装** - David主導
3. **テスト** - Tiara主導
4. **リリース** - Imai主導
5. **振り返り** - 全員参加

## 注意事項
- 日本語を含む場合はUTF-8エンコーディングを使用
- 作業開始・完了時のstatus更新を忘れずに
- タスク引き継ぎ時は必ずagent_tasksにレコード作成
