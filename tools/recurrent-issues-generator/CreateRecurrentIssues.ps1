Import-Module (Join-Path $PSScriptRoot -ChildPath "GithubGraphQLApi.psm1")
Import-Module (Join-Path $PSScriptRoot -ChildPath "RecurrentIssues.Helpers.psm1")


$organizationName = "akv-platform"

$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneNodeId = $eventPayload.milestone.node_id
$repositoryName = $eventPayload.repository.name
$repositoryOwner = $eventPayload.repository.owner.login
$repositoryNodeId = $eventPayload.repository.node_id

if ($milestoneTitle -NotMatch "\d{4} Week \d") {
    Write-Host "This milestone no need to create recurrent issues."
    exit 0
}

[int]$week = $milestoneTitle.split(" ")[2]

$sierraIssuesFlag = (($milestoneDescription -Match "sierra") -or (($week + 2) % 4 -eq 0))

$githubGraphQlApi = Get-GithubGraphQlApi -RepositoryOwner $repositoryOwner -RepositoryName $repositoryName -BearerToken $env:GITHUB_TOKEN

# Get repository labels
$labels = $githubGraphQlApi.GetRepoLabels()

Write-Host "Create issues..."
$jsonPath = Join-Path $PSScriptRoot "issues.json"
$issues = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

if ($sierraIssuesFlag) {
    $sierraIssuesJsonPath = Join-Path $PSScriptRoot "sierra_issues.json"
    $sierraIssues = Get-Content -Raw -Path $sierraIssuesJsonPath | ConvertFrom-Json
    $issues += $sierraIssues
}

foreach ($issue in $issues) {
    $title = $issue.Title + $milestoneTitle
    $body = [string]::Join("\n", $issue.Body)
    $projectId = $githubGraphQlApi.GetProjectId($organizationName, $issue.projectName)
    $issueLabels = Add-TeamLabel -IssueLabels $issue.Labels -Week $week -IssueGroup $issue.Group
    $issueLabelIds = Get-IssueLabelIds -RepositoryLabels $labels -IssueLabels $issueLabels
    $issue = $githubGraphQlApi.CreateIssue($repositoryNodeId, $milestoneNodeId, $title, $body, $issueLabelIds, $projectId)
    $projectColumns = $githubGraphQlApi.GetProjectColumns($organizationName, $issue.ProjectName)
    $columnId = Get-ColumnId -ProjectColumns $projectColumns -ColumnName $issue.ColumnName
    $githubGraphQlApi.MoveProjectCard((Get-IssueCardIds -Issue $issue), $columnId)
}