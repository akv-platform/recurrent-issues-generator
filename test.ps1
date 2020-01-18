Import-Module (Join-Path $PSScriptRoot -ChildPath "GithubGraphQLApi.psm1")


$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneId = $eventPayload.milestone.node_id
$repositoryId = $eventPayload.repository.node_id

if ($milestoneTitle -NotMatch "\d{4} Week \d") {
    exit 0
}

$githubGraphQlApi = Get-GithubGraphQlApi -BearerToken $env:GITHUB_TOKEN

Write-Host "Create issues..."
$jsonPath = Join-Path $PSScriptRoot "issues.json"
$issues = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

foreach ($issue in $issues) {
    $title = $issue.Title + $milestoneTitle
    $githubGraphQlApi.CreateIssue($repositoryId, $milestoneId, $title)
    Write-Host "Issue `"$title`" is created"
}



