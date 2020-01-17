Write-Host "Milestone!!!"
$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone
$milestoneDescription = $eventPayload.description
$milestoneDate = $eventPayload.created_at

Write-Host"Title: $milestoneTitle"
Write-Host"Description: $milestoneTitle"
Write-Host"Date: $milestoneTitle"