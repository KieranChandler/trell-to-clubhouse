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
