$eventPayload = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
$milestoneTitle = $eventPayload.milestone.title
$milestoneDescription = $eventPayload.milestone.description
$milestoneId = $eventPayload.milestone.node_id
$repositoryId = $eventPayload.repository.node_id



# if ($milestoneTitle -NotMatch "\d\d\d\d Week \d") {
#     exit 0
# }

Write-Host "Create issues..."

$githubGraphQLApi = "https://api.github.com/graphql"
$query = "mutation {
            createIssue(input:{
                            title:`"hello github`", 
                            repositoryId:`"$repositoryID`",
                            milestoneId:`"$milestoneId`"
                        })
            {issue {title}
            }
         }"

$requestGraphQl = @{
    query = $query
} | ConvertTo-Json

$params = @{
    Uri = $githubGraphQLApi
    Method = "POST"
    Body = $requestGraphQl
    Headers = @{
        Authorization = "Bearer $env:GITHUB_TOKEN"
    }
}

$response = Invoke-WebRequest @params
Write-Host $response

