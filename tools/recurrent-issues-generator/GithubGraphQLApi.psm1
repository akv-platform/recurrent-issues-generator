class GithubGraphQLApi {
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

        if ($response.data.organization.projects.nodes.length -eq 0) {
            Write-Host "##[error] Not found `"$ProjectName`" in `"$OrganizationName`""
            exit 1
        }

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
        Write-Host "Issue `"$Title`" is created"
        return $response.data.createIssue.issue
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
            Method      = "POST"
            ContentType = "application/json"
            Uri         = $this.graphQlApiUrl
            Body        = $requestGraphQl
            Headers     = @{ }
        }
        if ($this.AuthHeader) {
            $params.Headers += $this.AuthHeader
        }

        $response = Invoke-WebRequest @params | ConvertFrom-Json
        
        if ($response.errors) {
            Write-Host "##[error] Response has errors!"
            Write-Host "##[error] $($response.errors | ForEach-Object { $_.message })"
            exit 1
        }

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