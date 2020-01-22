Import-Module (Join-Path $PSScriptRoot -ChildPath "GithubGraphQLApi.psm1")
Import-Module (Join-Path $PSScriptRoot -ChildPath "RecurrentIssues.Helpers.psm1")


$organizationName = "akv-platform"
$projectName = "Recurrent issues generator test project"

$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneNodeId = $eventPayload.milestone.node_id
$repositoryName = $eventPayload.repository.name
$repositoryOwner = $eventPayload.repository.owner.login
$repositoryNodeId = $eventPayload.repository.node_id

if ($milestoneTitle -NotMatch "\d{4} Week \d") {
    Write-Host "This milestone no need to create recurrent issues."
    exit 0
}

$week = $milestoneTitle.split(" ")[2]

$githubGraphQlApi = Get-GithubGraphQlApi -RepositoryOwner $repositoryOwner -RepositoryName $repositoryName -BearerToken $env:GITHUB_TOKEN

# Get repository labels
$labels = $githubGraphQlApi.GetRepoLabels()

# Get project id for assigned project
$projectId = $githubGraphQlApi.GetProjectId($organizationName, $projectName)

Write-Host "Create issues..."
$jsonPath = Join-Path $PSScriptRoot "issues.json"
$issues = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

$milestoneCardIds = @()

foreach ($issue in $issues) {
    $title = $issue.Title + $milestoneTitle
    $body = [string]::Join("\n", $issue.Body)
    $issueLabels = Add-TeamLabel -IssueLabels $issue.Labels -Week $week -IssueGroup $issue.Group
    $issueLabelIds = Get-IssueLabelIds -RepositoryLabels $labels -IssueLabels $issueLabels
    $issue = $githubGraphQlApi.CreateIssue($repositoryNodeId, $milestoneNodeId, $title, $body, $issueLabelIds, $projectId)
    $milestoneCardIds += Get-IssueCardIds -Issue $issue
}

# Get "to do" column id
$columnName = "to do"
$projectColumns = $githubGraphQlApi.GetProjectColumns($organizationName, $projectName)
$columnId = Get-ColumnId -ProjectColumns $projectColumns -ColumnName $columnName

# Move assigned project cards to "to do" column
foreach ($cardId in $milestoneCardIds) {
    $githubGraphQlApi.MoveProjectCard($cardId, $columnId)
}