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

$bodyRequest = @{
    title = "Hello issue"
    body = "issue body is here"
    milestone = $milestoneNumber
} | ConvertTo-Json

$githubURL = "https://api.github.com/repos/vsafonkin/test-github-actions/issues"


function Invoke-Request {
    param(
        [string] $Url,
        [string] $Method,
        [string] $Body
    )
    
    $params = @{
        Method = $Method
        ContentType = "application/json"
        Uri = $Url
        Body = $Body
    }

    $response = Invoke-RestMethod @params
    return $response
}

$response = Invoke-Request -Url $githubURL -Method "Post" -Body $bodyRequest
Write-Host $response