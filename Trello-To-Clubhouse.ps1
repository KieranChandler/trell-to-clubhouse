param (
    [string]
    $ClubhouseApiToken,
    [string]
    $TrelloSrcJson,
    [string]
    $ClubhouseProjectId,
    $TrelloToClubhouseUserMap,
    $WorkflowStateMap
)

. "./Trello.ps1"
. "./Clubhouse.ps1"

$trelloSrcObj = ($TrelloSrcJson | ConvertFrom-Json)

function FromTrelloUserIdToClubhouseUserId($TrelloUserId, $Users) {
    foreach ($user in $Users) {
        if ($user.trelloUserId -eq $TrelloUserId) {
            return $user.clubhouseUserId
        }
    }
}

function ConvertTo-ClubHouseStory([string]$ApiToken, [psobject]$trelloCard, $Users, $WorkflowStateMap) {
    $action = (GetCardCreatedAction -cardId $trelloCard.id -allActions $trelloSrcObj.actions)

    $ownerIds = ($trelloCard.idMembers `
        | Select-Object `
        @{
            N = "ClubhouseUserId";
            E = { FromTrelloUserIdToClubhouseUserId -TrelloUserId $_ -Users $TrelloToClubhouseUserMap }
        }) `
        | Select-Object -ExpandProperty ClubhouseUserId

    $workflowState = ($WorkflowStateMap | Where-Object trelloListId -eq $trelloCard.idList).clubhouseStateId

    $labelNames = $trelloCard.labels | Select-Object -ExpandProperty name

    New-Story `
        -ApiToken $ApiToken `
        -Name $trelloCard.name `
        -Description $trelloCard.desc`
        -ProjectId $ClubhouseProjectId `
        -Created $action.date `
        -Updated $trelloCard.dateLastActivity `
        -OwnerIds $ownerIds `
        -WorkflowStateId $workflowState `
        -LabelNames $labelNames
}

foreach ($card in $trelloSrcObj.Cards) {
    $isNotAnArchivedCard = -not $card.closed
    $isNotAMilestoneCard = $card.idList -ne "5e0010e3d50d53272ede97d4"
    if ($isNotAnArchivedCard -and $isNotAMilestoneCard) {
        ConvertTo-ClubHouseStory $ClubhouseApiToken $card $TrelloToClubhouseUserMap $WorkflowStateMap
    }
}