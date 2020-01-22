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

function Add-TeamLabel {
    param (
        [string[]] $IssueLabels,
        [int] $Week,
        [int] $IssueGroup
    )
    
    if ($Week % 2 -ne 0) {
        $labelForFirstGroup = "alyona team"
        $labelForSecondGroup = "sergey team"
    } else {
        $labelForFirstGroup = "sergey team"
        $labelForSecondGroup = "alyona team"
    }

    if ($IssueGroup -eq 1) {
        $IssueLabels += $labelForFirstGroup
    } elseif ($IssueGroup -eq 2) {
        $IssueLabels += $labelForSecondGroup
    }
    
    return $IssueLabels
}

function Get-IssueCardIds {
    param(
        [object[]] $Issue
    )
    
    $cardIds = @()
    foreach($card in $Issue.projectCards.nodes) {
        $cardIds += $card.id
    }

    return $cardIds
}