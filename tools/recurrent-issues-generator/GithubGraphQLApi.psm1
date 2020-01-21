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

        Write-Host "Request repository labels for $owner/$name"
        $response = $this.InvokeApiMethod($query)
        return $response.data.repository.labels.nodes
    }

    [string] GetProjectId([string]$OrganizationName, [string]$ProjectName) {
        $query = "{organization(login:`"$OrganizationName`"){
            projects(search:`"$ProjectName`", first:1) {
                nodes {
                    id
                }
            }
        }}"

        Write-Host "Request project id for $OrganizationName/$ProjectName"
        $response = $this.InvokeApiMethod($query)
        return $response.data.organization.projects.nodes[0].id
    }

    [object] GetProjectColumns([string]$OrganizationName, [string]$ProjectName) {
        $query = "{organization(login:`"$OrganizationName`"){
            projects(search:`"$ProjectName`", first:1) {
                nodes {
                    columns(first:20) {
                        nodes {
                            name, id
                        }
                    }
                }
            }
        }}"

        Write-Host "Request project columns for $OrganizationName/$ProjectName"
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
            {
                issue {
                    projectCards(first:20) {
                        nodes {
                           id
                        }
                    }
                }
            }
         }"
    
        Write-Host "Request to create issue `"$Title`""
        $response = $this.InvokeApiMethod($query)
        Write-Host $response.data.createIssue.issue.projectCards.nodes
        return $response.data.createIssue.issue
    }

    [object] GetMilestoneCardIds([string]$milestoneId) {
        $owner = $this.RepositoryOwner
        $name = $this.RepositoryName
        $query = "{repository(owner: `"$owner`", name: `"$name`") {
            issues(filterBy: {milestone: `"$milestoneId`"}, first: 20) {
                nodes {
                    projectCards(first: 20) {
                        nodes {
                            id
                        }
                    }
                }
            }
        }}"
        
        Write-Host "Request milestone card ids"
        $response = $this.InvokeApiMethod($query)

        $cardIds = @()
        foreach ($issue in $response.data.repository.issues.nodes) {
            $cardIds += $issue.projectCards.nodes[0].id
        }

        return $cardIds
    }

    [object] MoveProjectCard([string]$CardId, $ColumnId) {
        $query = "mutation {
            moveProjectCard(input:{
                cardId: `"$CardId`",
                columnId: `"$ColumnId`"
            })
            {clientMutationId}
        }"
        
        Write-Host "Request to move project cards"
        $response = $this.InvokeApiMethod($query)

        return $response
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

        $response = Invoke-WebRequest @params 

        $statusCode = $response.statuscode
        Write-Host "Response status code: $statusCode"
        if ($statusCode -ne 200) {
            Write-Error "Response: $response"
        }

        return $response | ConvertFrom-Json
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