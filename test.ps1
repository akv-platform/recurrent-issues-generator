Import-Module (Join-Path $PSScriptRoot -ChildPath "GithubGraphQLApi.psm1")


$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
# Write-Host $eventPayload.repository.owner
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneId = $eventPayload.milestone.node_id
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

$githubGraphQlApi = Get-GithubGraphQlApi -BearerToken $env:GITHUB_TOKEN

# Get repository labels
$labels = $githubGraphQlApi.GetRepoLabels($repositoryOwner, $repositoryName)

Write-Host "Create issues..."
$jsonPath = Join-Path $PSScriptRoot "issues.json"
$issues = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

foreach ($issue in $issues) {
    $title = $issue.Title + $milestoneTitle
    $issueLabelIds = Get-IssueLabelsIds -RepositoryLabels $labels -IssueLabels $issue.Labels
    $githubGraphQlApi.CreateIssue($repositoryId, $milestoneId, $title, $issue.Body, $issueLabelIds)
    Write-Host "Issue `"$title`" is created"
}
