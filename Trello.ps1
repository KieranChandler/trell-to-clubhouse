function GetCardCreatedAction($cardId, $allActions) {
    foreach ($action in $allActions) {
        $isCreateCardAction = $action.type -eq "createCard"
        $isForThisCard = $action.data.card.id -eq $cardId

        if ($isCreateCardAction -and $isForThisCard) {
            $action
        }
    }
}

function Get-CardCommentActions($CardId, $AllActions) {
    [PSCustomObject[]]$actionsToReturn = @()
    foreach ($action in $AllActions) {
        $isCommentAction = $action.type -eq "commentCard"
        $isForThisCard = $action.data.card.id -eq $cardId

        if ($isCommentAction -and $isForThisCard) {

            $actionsToReturn += [PSCustomObject]@{
                    CommentAuthorUserId = $action.memberCreator.id
                    AuthorDate          = $action.date
                    CommentContents     = $action.data.text
                }
        }
    }
    return $actionsToReturn
}

function Get-EpicCardBelongsTo(
    $AllCards,
    $Card
) {
    $epicCardId = ($Card.pluginData `
        | Where-Object { $_.idPlugin -eq "5b7ae739fad82e45988016cf" } `
        | Select-Object -ExpandProperty value `
        | ConvertFrom-Json `
        | Select-Object -ExpandProperty epicId)

    return ($AllCards `
        | Where-Object { $_.id -eq $epicCardId } `
        | Select-Object -ExpandProperty name)
}