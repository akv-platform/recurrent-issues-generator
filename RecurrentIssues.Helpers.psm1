function Get-IssueLabelIds {
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

function Get-ColumnId {
    param(
        [object[]] $ProjectColumns,
        [string] $ColumnName
    )

    foreach ($projectColumn in $ProjectColumns) {
        if ($projectColumn.name -eq $ColumnName) {
            return $projectColumn.id
        }
    }

    Write-Host "Column with name $ColumnName not exists in project"
    return $null
}

Get-IssueBody {
    param(
        [string[]] $IssueBodyRows
    )

    $resultBody = ""
    foreach ($bodyRow in $IssueBodyRows) {
        $bodyRow += "\n"
        $resultBody += $bodyRow
    }
    return $resultBody
}