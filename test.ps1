Import-Module (Join-Path $PSScriptRoot -ChildPath "GithubGraphQLApi.psm1")


$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
Write-Host $eventPayload.milestone
Write-Host $eventPayload.repository
Write-Host $eventPayload.sender
$milestoneTitle = $eventPayload.milestone.title
$milestoneNodeId = $eventPayload.milestone.node_id
$milestoneId = $eventPayload.milestone.id
$repositoryName = $eventPayload.repository.name
$repositoryOwner = $eventPayload.repository.owner.login
$repositoryId = $eventPayload.repository.node_id

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

$githubGraphQlApi = Get-GithubGraphQlApi -BearerToken $env:MY_GITHUB_TOKEN

# Get repository labels
$labels = $githubGraphQlApi.GetRepoLabels($repositoryOwner, $repositoryName)

Write-Host "Create issues..."
$jsonPath = Join-Path $PSScriptRoot "issues.json"
$issues = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

foreach ($issue in $issues) {
    $title = $issue.Title + $milestoneTitle
    $issueLabelIds = Get-IssueLabelsIds -RepositoryLabels $labels -IssueLabels $issue.Labels
    $githubGraphQlApi.CreateIssue($repositoryId, $milestoneNodeId, $title, $issue.Body, $issueLabelIds)
    Write-Host "Issue `"$title`" is created"

}

# Move assigned project cards to "to do" column
$cardIds = $githubGraphQlApi.GetMilestoneCardIds($repositoryOwner, $repositoryName, $milestoneId)
foreach ($cardId in $cardIds) {
    $githubGraphQlApi.MoveProjectCard($cardId)
}