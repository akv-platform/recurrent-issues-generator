class GithubGraphQLApi
{
    [string] $GraphQlApiUrl
    [string] $RepositoryOwner
    [string] $RepositoryName
    [object] $AuthHeader

    GithubGraphQLApi(
        [string] $RepositoryOwner,
        [string] $RepositoryName,
        [string] $BearerToken
    ) {
        $this.GraphQlApiUrl = "https://api.github.com/graphql"
        $this.RepositoryOwner = $RepositoryOwner
        $this.RepositoryName = $RepositoryName
        $this.AuthHeader = @{
            Authorization = "Bearer $BearerToken"
        }
    }

    [object] GetRepoLabels() {
        $owner = $this.RepositoryOwner
        $name = $this.RepositoryName
        $query = "{repository(owner: `"$owner`", name: `"$name`") {labels(first: 100) {nodes {name, id}}}}"
        $response = $this.InvokeApiMethod($query)
        return $response.data.repository.labels.nodes
    }

    [string] GetProjectId([string]$OrganizationName, [string]$ProjectName) {
        $query = "{organization(login:`"$OrganizationName`"){
            projects(search:`"$ProjectName`", last:1) {
                nodes {
                    id
                }
            }
        }}"
        $response = $this.InvokeApiMethod($query)
        return $response.data.organization.projects.nodes[0].id
    }

    [object] GetProjectColumns([string]$OrganizationName, [string]$ProjectName) {
        $query = "{organization(login:`"$OrganizationName`"){
            projects(search:`"$ProjectName`", last:1) {
                nodes {
                    columns(last:20) {
                        nodes {
                            name, id
                        }
                    }
                }
            }
        }}"
        $response = $this.InvokeApiMethod($query)
        return $response.data.organization.projects.nodes[0].columns.nodes
    }

    [object] CreateIssue([string]$RepositoryId,
                         [string]$MilestoneId,
                         [string]$Title,
                         [string]$Body,
                         [string[]]$LabelIds,
                         [string]$ProjectId) {
        $query = "mutation {
            createIssue(input:{
                repositoryId:`"$repositoryID`",
                milestoneId:`"$milestoneId`"
                title:`"$Title`",
                body:`"$Body`",
                labelIds:$LabelIds,
                projectIds: `"$ProjectId`"
            })
            {issue {title}
            }
         }"

        return $this.InvokeApiMethod($query)
    }

    [object] GetMilestoneCardIds([string]$milestoneId) {
        $owner = $this.RepositoryOwner
        $name = $this.RepositoryName
        $query = "{repository(owner: `"$owner`", name: `"$name`") {
            issues(filterBy: {milestone: `"$milestoneId`"}, last: 20) {
                nodes {
                    projectCards(last: 20) {
                        nodes {
                            id
                        }
                    }
                }
            }
        }}"

        $response = $this.InvokeApiMethod($query)

        $cardIds = @()
        foreach ($issue in $response.data.repository.issues.nodes) {
            $cardIds += $issue.projectCards.nodes[0].id
        }

        return $cardIds
    }

    [object] MoveProjectCard([string]$CardId) {
        $columnId = "MDEzOlByb2plY3RDb2x1bW43NzIyODY5"
        $query = "mutation {
            moveProjectCard(input:{
                cardId: `"$CardId`",
                columnId: `"$columnId`"
            })
            {clientMutationId}
        }"

        return $this.InvokeApiMethod($query)
    }

    [object] hidden InvokeApiMethod(
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

        $response = Invoke-WebRequest @params | ConvertFrom-Json
        return $response
    }
}

function Get-GithubGraphQlApi {
    param (
        [string] $RepositoryOwner,
        [string] $RepositoryName,
        [string] $BearerToken
    )

    return [GithubGraphQLApi]::New($RepositoryOwner, $RepositoryName, $BearerToken)
}