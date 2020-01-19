Import-Module (Join-Path $PSScriptRoot -ChildPath "GithubGraphQLApi.psm1")

$organizationName = "vsafonkin-test-organization"
$projectName = "Test project"

$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneNodeId = $eventPayload.milestone.node_id
$milestoneId = $eventPayload.milestone.id
$repositoryName = $eventPayload.repository.name
$repositoryOwner = $eventPayload.repository.owner.login
$repositoryNodeId = $eventPayload.repository.node_id

# if ($milestoneTitle -NotMatch "\d{4} Week \d") {
#     exit 0
# }

function Get-IssueLabelsIds {
    param(
        [object[]] $RepositoryLabels,
        [string[]] $IssueLabels
    )

    $labelIds = @()
    foreach ($RepositoryLabel in $RepositoryLabels) {
        if ($IssueLabels.Contains($RepositoryLabel.name)) {
            $labelIds += $RepositoryLabel.id
        }
    }
    return $labelIds | ConvertTo-Json
}

$githubGraphQlApi = Get-GithubGraphQlApi -RepositoryOwner $repositoryOwner -RepositoryName $repositoryName -BearerToken $env:GITHUB_TOKEN

# Get repository labels
$labels = $githubGraphQlApi.GetRepoLabels()

# Get project id for assigned project
$projectId = $githubGraphQlApi.GetProjectId($organizationName, $projectName)

Write-Host "Create issues..."
$jsonPath = Join-Path $PSScriptRoot "issues.json"
$issues = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

foreach ($issue in $issues) {
    $title = $issue.Title + $milestoneTitle
    $issueLabelIds = Get-IssueLabelsIds -RepositoryLabels $labels -IssueLabels $issue.Labels
    $githubGraphQlApi.CreateIssue($repositoryNodeId, $milestoneNodeId, $title, $issue.Body, $issueLabelIds, $projectId)
    Write-Host "Issue `"$title`" is created"

}

# Move assigned project cards to "to do" column
$cardIds = $githubGraphQlApi.GetMilestoneCardIds($milestoneId)
foreach ($cardId in $cardIds) {
    $githubGraphQlApi.MoveProjectCard($cardId)
}