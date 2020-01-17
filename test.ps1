Write-Host "Milestone!!!"
$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneDate = $eventPayload.milestone.created_at
$milestoneNumber = $eventPayload.milestone.number
Write-Host $eventPayload.milestone
Write-Host "------------"
Write-Host "Title: $milestoneTitle"
Write-Host "Description: $milestoneDescription"
Write-Host "Date: $milestoneDate"
Write-Host "Number: $milestoneNumber"

$body = @{
    title = "Hello issue"
    body = "issue body is here"
    milestone = $milestoneNumber
}

$githubURL = "https://api.github.com/repos/vsafonkin/test-github-actions/issues"
Invoke-WebRequest $githubURL -Method "POST" -Body $($body | ConvertTo-Json)