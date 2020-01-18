Write-Host "Milestone!!!"
$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneDate = $eventPayload.milestone.created_at
$milestoneNumber = $eventPayload.milestone.number
$repositoryId = $eventPayload.repository.node_id
Write-Host $eventPayload
Write-Host "------------"
Write-Host "Title: $milestoneTitle"
Write-Host "Description: $milestoneDescription"
Write-Host "Date: $milestoneDate"
Write-Host "Number: $milestoneNumber"
Write-Host "Repository Id: $repositoryId"
Write-Host "------------"
Write-Host $env:GITHUB_TOKEN

# if ($milestoneTitle -NotMatch "\d\d\d\d Week \d") {
#     exit 0
# }

# Write-Host "Create issues..."

