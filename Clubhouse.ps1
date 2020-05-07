. .\Web.ps1
# . .\Web-Fake.ps1

function Get-EpicId(
    [string] $ApiToken,
    [string] $Name
) {
    Write-Host
    Write-Host "Getting epic Id from Clubhouse API.."
    $response = Invoke-GetRequest `
        -Uri "https://api.clubhouse.io/api/v3/epics?token=$ApiToken"

    ($response.Content | ConvertFrom-Json `
        | Where-Object { $_.name -eq $Name } `
        | Select-Object -ExpandProperty id)
}

function New-UrlAttachmentToStory(
    [string] $ApiToken,
    [string] $UrlToAttach,
    [string] $AttachmentName,
    [int] $StoryId
) {
    Write-Host
    Write-Host "Linking attachment $AttachmentName to story $StoryId via Clubhouse API.."

    $fileRequestBody = [PSCustomObject]@{
        name     = $AttachmentName
        type     = "url"
        url      = $UrlToAttach
        story_id = $StoryId
    } | ConvertTo-Json

    $response = Invoke-PostRequest `
        -Uri "https://api.clubhouse.io/api/v3/linked-files?token=$ApiToken" `
        -RequestBodyObj $fileRequestBody
}

function New-CommentOnStory(
    [string] $ApiToken,
    [string] $StoryId,
    [string] $CommentAuthor,
    [string] $AuthorDate,
    [string] $CommentContents
) {
    if ([string]::IsNullOrWhiteSpace($AuthorDate)) {
        $AuthorDate = "0001-01-01T00:00:00.000Z"
    }

    $requestBody = [PSCustomObject]@{
        author_id  = $CommentAuthor
        created_at = $AuthorDate
        text       = $CommentContents
    } | ConvertTo-Json

    Write-Host
    Write-Host "Adding comment by $CommentAuthor to story $StoryId via Clubhouse API.."
    $response = Invoke-PostRequest `
        -Uri "https://api.clubhouse.io/api/v3/stories/$($StoryId)/comments?token=$ApiToken" `
        -RequestBodyObj $requestBody
}

function New-Story(
    [string] $ApiToken,
    [string] $Name,
    [string] $Description,
    [string] $Created,
    [string] $Updated,
    [string] $ProjectId,
    [string[]] $OwnerIds,
    [string[]] $LabelNames,
    $Attachments,
    [int] $WorkflowStateId
) {
    if ($null -eq $LabelNames) {
        $LabelNames = @()
    }
    else {
        [PSCustomObject[]]$labels = $LabelNames | Select-Object `
        @{
            N = "name";
            E = { $_ }
        }
    }

    if ([string]::IsNullOrWhiteSpace($Created)) {
        $Created = "0001-01-01T00:00:00.000Z"
    }

    if ([string]::IsNullOrWhiteSpace($Updated)) {
        $Updated = "0001-01-01T00:00:00.000Z"
    }

    if ($null -eq $OwnerIds) {
        $OwnerIds = @()
    }

    $requestBody = [PSCustomObject]@{
        name              = $Name
        description       = $Description
        project_id        = $ProjectId
        created_at        = $Created
        updated_at        = $Updated
        owner_ids         = $OwnerIds
        workflow_state_id = $WorkflowStateId
        labels            = $labels
    } | ConvertTo-Json

    Write-Host
    Write-Host "Creating story via Clubhouse API.."
    $response = Invoke-PostRequest `
        -Uri "https://api.clubhouse.io/api/v3/stories?token=$ApiToken" `
        -RequestBodyObj $requestBody

    $newStoryId = ($response | ConvertFrom-Json).id

    foreach ($attachment in $Attachments) {
        New-UrlAttachmentToStory `
            -ApiToken $ApiToken `
            -UrlToAttach $attachment.url `
            -AttachmentName $attachment.name `
            -StoryId $newStoryId
    }

    return $newStoryId
}

function New-Epic(
    [string] $ApiToken,
    [string] $Name,
    [string] $Description,
    [string] $Created,
    [string] $Updated,
    [string[]] $OwnerIds,
    [string[]] $LabelNames
) {
    if ($null -eq $LabelNames) {
        $LabelNames = @()
    }
    else {
        [PSCustomObject[]]$labels = $LabelNames | Select-Object `
        @{
            N = "name";
            E = { $_ }
        }
    }

    if ([string]::IsNullOrWhiteSpace($Created)) {
        $Created = "0001-01-01T00:00:00.000Z"
    }

    if ([string]::IsNullOrWhiteSpace($Updated)) {
        $Updated = "0001-01-01T00:00:00.000Z"
    }

    if ($null -eq $OwnerIds) {
        $OwnerIds = @()
    }

    $requestBody = [PSCustomObject]@{
        name        = $Name
        description = $Description
        created_at  = $Created
        updated_at  = $Updated
        owner_ids   = $OwnerIds
        labels      = $labels
    } | ConvertTo-Json

    Write-Host
    Write-Host "Creating epic via Clubhouse API.."
    $response = Invoke-PostRequest `
        -Uri "https://api.clubhouse.io/api/v3/epics?token=$ApiToken" `
        -RequestBodyObj $requestBody

    $newEpicId = ($response | ConvertFrom-Json).id
    return $newEpicId
}

function New-StoryToEpicLink(
    [string] $ApiToken,
    [string] $EpicName,
    [int] $StoryId
) {
    $listEpicsResponse = Invoke-GetRequest `
        -Uri "https://api.clubhouse.io/api/v3/epics?token=$ApiToken"

    $x = ($listEpicsResponse.Content | ConvertFrom-Json) # No idea why this needs to be separate from the line below
    $epic = ($x `
        | Where-Object { -not $_.archived } `
        | Where-Object { $_.name -eq $EpicName })

    $requestBody = [PSCustomObject]@{
        epic_id = $epic.id
    } | ConvertTo-Json

    Write-Host
    Write-Host "Adding story $StoryId to epic $($epic.id) via Clubhouse API.."
    $response = Invoke-PutRequest `
        -Uri "https://api.clubhouse.io/api/v3/stories/$($StoryId)?token=$ApiToken" `
        -RequestBodyObj $requestBody
}