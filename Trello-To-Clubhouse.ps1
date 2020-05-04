param (
    [string]
    $ClubhouseApiToken,
    [string]
    $TrelloSrcJson,
    [string]
    $ClubhouseProjectId,
    $TrelloToClubhouseUserMap
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

function ConvertTo-ClubHouseStory([string]$ApiToken, [psobject]$trelloCard, $Users) {
    $action = (GetCardCreatedAction -cardId $trelloCard.id -allActions $trelloSrcObj.actions)

    $ownerIds = ($trelloCard.idMembers `
        | Select-Object `
        @{
            N = "ClubhouseUserId";
            E = { FromTrelloUserIdToClubhouseUserId -TrelloUserId $_ -Users $TrelloToClubhouseUserMap }
        }) `
        | Select-Object -ExpandProperty ClubhouseUserId

    New-Story `
        -ApiToken $ApiToken `
        -Name $trelloCard.name `
        -Description $trelloCard.desc`
        -ProjectId $ClubhouseProjectId `
        -Created $action.date `
        -Updated $trelloCard.dateLastActivity `
        -OwnerIds $ownerIds
}

foreach ($card in $trelloSrcObj.Cards) {
    $isNotAnArchivedCard = -not $card.closed
    if ($isNotAnArchivedCard) {
        ConvertTo-ClubHouseStory $ClubhouseApiToken $card $TrelloToClubhouseUserMap
    }
}