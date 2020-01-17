Write-Host "Milestone!!!"
$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneDate = $eventPayload.milestone.created_at

Write-Host "Title: $milestoneTitle"
Write-Host "Description: $milestoneDescription"
Write-Host "Date: $milestoneDate"