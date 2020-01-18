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

    [object] CreateIssue([string]$RepositoryId, [string]$MilestoneId, [string]$Title) {
        $query = "mutation {
            createIssue(input:{
                            title:`"$Title`", 
                            repositoryId:`"$repositoryID`",
                            milestoneId:`"$milestoneId`"
                        })
            {issue {title}
            }
         }"

        $requestGraphQl = @{
            query = $query
        } | ConvertTo-Json

        $response = $this.InvokeRestMethod($requestGraphQl)
        return $response
    }

    [object] hidden InvokeRestMethod(
        [string] $requestGraphQl
    ) {
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