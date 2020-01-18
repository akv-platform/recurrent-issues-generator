Write-Host "Milestone!!!"
$eventPayload = Get-Content $env:GITHUB_EVENT_PATH
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneDate = $eventPayload.milestone.created_at
$milestoneNumber = $eventPayload.milestone.number
Write-Host $eventPayload
Write-Host "------------"
Write-Host "Title: $milestoneTitle"
Write-Host "Description: $milestoneDescription"
Write-Host "Date: $milestoneDate"
Write-Host "Number: $milestoneNumber"

# if ($milestoneTitle -NotMatch "\d\d\d\d Week \d") {
#     exit 0
# }

# Write-Host "Create issues..."

