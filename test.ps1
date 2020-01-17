Write-Host "Milestone!!!"
$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
Write-Host $eventPayload