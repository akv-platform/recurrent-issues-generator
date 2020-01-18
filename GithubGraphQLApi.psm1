class GithubGraphQLApi
{
    [string] $GraphQlApiUrl
    [object] $AuthHeader

    GithubGraphQLApi(
        [string] $BearerToken
    ) {
        $this.GraphQlApiUrl = "https://api.github.com/graphql"
        $this.AuthHeader = @{
            Authorization = "Bearer $BearerToken"
        }
    }

    [object] GetRepoLabels([string]$RepositoryOwner, [string]$RepositoryName) {
        $query = "{repository(owner: `"$RepositoryOwner`", name: `"$RepositoryName`") {labels(first: 100) {nodes {name, id}}}}"
        $response = $this.InvokeRestMethod($query) | ConvertFrom-Json
        return $response.data.repository.labels.nodes
    }

    [object] CreateIssue([string]$RepositoryId, [string]$MilestoneId, [string]$Title, [string]$Body) {
        $query = "mutation {
            createIssue(input:{
                repositoryId:`"$repositoryID`",
                milestoneId:`"$milestoneId`"
                title:`"$Title`",
                body:`"$Body`"
            })
            {issue {title}
            }
         }"

        return $this.InvokeRestMethod($query) | ConvertFrom-Json
    }

    [object] hidden InvokeRestMethod(
        [string] $queryGraphQl
    ) {
        $requestGraphQl = @{
            query = $queryGraphQl
        } | ConvertTo-Json

        $params = @{
            Method = "POST"
            ContentType = "application/json"
            Uri = $this.graphQlApiUrl
            Body = $requestGraphQl
            Headers = @{}
        }
        if ($this.AuthHeader) {
            $params.Headers += $this.AuthHeader
        }

        $response = Invoke-RestMethod @params
        return $response
    }
}

function Get-GithubGraphQlApi {
    param (
        [string] $BearerToken
    )

    return [GithubGraphQLApi]::New($BearerToken)
}