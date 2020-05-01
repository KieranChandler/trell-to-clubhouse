param (
    [string]
    $TrelloSrcJson,
    [string]
    $ClubhouseProjectId
)

. "./Trello.ps1"
. "./Clubhouse.ps1"

$trelloSrcObj = ($TrelloSrcJson | ConvertFrom-Json)

function ConvertTo-ClubHouseStory([psobject]$trelloCard) {
    $action = (GetCardCreatedAction -cardId $trelloCard.id -allActions $trelloSrcObj.actions)

    New-Story `
        -Name $trelloCard.name `
        -ProjectId $ClubhouseProjectId `
        -Created $action.date `
        -Updated $trelloCard.dateLastActivity
}

foreach ($card in $trelloSrcObj.Cards) {
    $isNotAnArchivedCard = -not $card.closed
    if ($isNotAnArchivedCard) {
        ConvertTo-ClubHouseStory $card
    }
}