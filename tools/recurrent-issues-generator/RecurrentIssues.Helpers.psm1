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

function Get-IssueBody {
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

function Add-TeamLabel {
    param (
        [string[]] $IssueLabels,
        [string[]] $TeamLabels,
        [int] $Week,
        [int] $IssueGroup
    )
    
    if ($Week % 2 -ne 0) {
        $groupOneLabel = $TeamLabels[0]
        $groupTwoLabel = $TeamLabels[1]
    } else {
        $groupOneLabel = $TeamLabels[1]
        $groupTwoLabel = $TeamLabels[0]
    }

    if ($IssueGroup -eq 1) {
        $IssueLabels += $groupOneLabel
    } elseif ($IssueGroup -eq 2) {
        $IssueLabels += $groupTwoLabel
    }
    
    return $IssueLabels
}