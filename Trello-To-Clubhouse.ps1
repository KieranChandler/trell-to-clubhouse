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
        } `
        | Select-Object -ExpandProperty ClubhouseUserId `
        | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    $workflowState = ($WorkflowStateMap | Where-Object trelloListId -eq $trelloCard.idList).clubhouseStateId

    $labelNames = $trelloCard.labels | Select-Object -ExpandProperty name

    $newStoryId = New-Story `
        -ApiToken $ApiToken `
        -Name $trelloCard.name `
        -Description $trelloCard.desc`
        -ProjectId $ClubhouseProjectId `
        -Created $action.date `
        -Updated $trelloCard.dateLastActivity `
        -OwnerIds $ownerIds `
        -WorkflowStateId $workflowState `
        -LabelNames $labelNames `
        -Attachments $trelloCard.attachments

    $commentActions = Get-CardCommentActions `
        -CardId $trelloCard.id `
        -AllActions $trelloSrcObj.actions

    foreach ($commentAction in $commentActions) {
        $commentAuthor = FromTrelloUserIdToClubhouseUserId `
            -TrelloUserId $commentAction.CommentAuthorUserId `
            -Users $Users

        New-CommentOnStory `
            -ApiToken $ApiToken `
            -StoryId $newStoryId `
            -CommentAuthor $commentAuthor `
            -AuthorDate $commentAction.AuthorDate `
            -CommentContents $commentAction.CommentContents
    }
}

function ConvertTo-ClubHouseEpic([string]$ApiToken, [psobject]$trelloCard, $UsersMap) {
    $action = (GetCardCreatedAction -cardId $trelloCard.id -allActions $trelloSrcObj.actions)

    $ownerIds = $trelloCard.idMembers `
    | Select-Object `
    @{
        N = "ClubhouseUserId";
        E = { FromTrelloUserIdToClubhouseUserId -TrelloUserId $_ -Users $TrelloToClubhouseUserMap }
    } `
    | Select-Object -ExpandProperty ClubhouseUserId `
    | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    $labelNames = $trelloCard.labels | Select-Object -ExpandProperty name

    $newEpicId = New-Epic `
        -ApiToken $ApiToken `
        -Name $trelloCard.name `
        -Description $trelloCard.desc`
        -Created $action.date `
        -Updated $trelloCard.dateLastActivity `
        -OwnerIds $ownerIds `
        -LabelNames $labelNames

    $commentActions = Get-CardCommentActions `
        -CardId $trelloCard.id `
        -AllActions $trelloSrcObj.actions

    foreach ($commentAction in $commentActions) {
        $commentAuthor = FromTrelloUserIdToClubhouseUserId `
            -TrelloUserId $commentAction.CommentAuthorUserId `
            -Users $Users

        New-CommentOnStory `
            -ApiToken $ApiToken `
            -StoryId $newEpicId `
            -CommentAuthor $commentAuthor `
            -AuthorDate $commentAction.AuthorDate `
            -CommentContents $commentAction.CommentContents
    }
}

$epicListId = "5e0010e3d50d53272ede97d4"
foreach ($card in $trelloSrcObj.Cards) {
    $isNotAnArchivedCard = -not $card.closed
    $isNotAMilestoneCard = $card.idList -ne $epicListId
    $isAMilestoneCard = $card.idList -eq $epicListId

    if ($isNotAnArchivedCard -and $isAMilestoneCard) {
        ConvertTo-ClubHouseEpic $ClubhouseApiToken $card $TrelloToClubhouseUserMap
    }
}

foreach ($card in $trelloSrcObj.Cards) {
    $isNotAnArchivedCard = -not $card.closed
    $isNotAMilestoneCard = $card.idList -ne $epicListId
    $isAMilestoneCard = $card.idList -eq $epicListId

    if ($isNotAnArchivedCard -and $isNotAMilestoneCard) {
        ConvertTo-ClubHouseStory $ClubhouseApiToken $card $TrelloToClubhouseUserMap $WorkflowStateMap
    }
}