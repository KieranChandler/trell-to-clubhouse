function GetCardCreatedAction($cardId, $allActions) {
    foreach ($action in $allActions) {
        $isCreateCardAction = $action.type -eq "createCard"
        $isForThisCard = $action.data.card.id -eq $cardId

        if ($isCreateCardAction -and $isForThisCard) {
            $action
        }
    }
}
