param (
    [string]
    $TrelloSrcJson,
    [string]
    $ClubhouseProjectId
)

. "./Trello.ps1"

$trelloSrcObj = ($TrelloSrcJson | ConvertFrom-Json)

function ConvertTo-ClubHouseStory([psobject]$trelloCard) {
    $action = (GetCardCreatedAction -cardId $trelloCard.id -allActions $trelloSrcObj.actions)

    [PSCustomObject]@{
        name       = $trelloCard.name
        project_id = $ClubhouseProjectId
        created_at = $action.date
    }
}

foreach ($card in $trelloSrcObj.Cards) {
    $isNotAnArchivedCard = -not $card.closed
    if ($isNotAnArchivedCard) {
        ConvertTo-ClubHouseStory $card | ConvertTo-Json
    }
}