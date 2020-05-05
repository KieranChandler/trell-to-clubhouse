function SimplifyWebResponse($WebResponse) {
    $WebResponse | Select-Object StatusCode,StatusDescription,Content | ConvertTo-Json
}

function Get-EpicId(
    [string] $ApiToken,
    [string] $Name
) {
    Write-Host
    Write-Host "Getting epic Id from Clubhouse API.."
    $response = Invoke-WebRequest `
        -Uri "https://api.clubhouse.io/api/v3/epics?token=$ApiToken" `
        -Method "GET" `
        -ContentType "application/json" `
        -Body $requestBody `
        -UseBasicParsing

    ($response.Content | ConvertFrom-Json `
        | Where-Object { $_.name -eq $Name } `
        | Select-Object -ExpandProperty id)
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
        name       = $Name
        description = $Description
        project_id = $ProjectId
        created_at = $Created
        updated_at = $Updated
        owner_ids = $OwnerIds
        workflow_state_id = $WorkflowStateId
        labels  = $labels
    } | ConvertTo-Json

    Write-Host
    Write-Host "Creating story via Clubhouse API.."
    $response = Invoke-WebRequest `
        -Uri "https://api.clubhouse.io/api/v3/stories?token=$ApiToken" `
        -Method "POST" `
        -ContentType "application/json" `
        -Body $requestBody `
        -UseBasicParsing
    Write-Host $(SimplifyWebResponse -WebResponse $response)
}

function New-Epic(
    [string] $ApiToken,
    [string] $Name,
    [string] $Description,
    [string] $Created,
    [string] $Updated,
    [string[]] $OwnerIds,
    [string[]] $LabelNames,
    [int[]] $AttachmentIds
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
        name       = $Name
        description = $Description
        created_at = $Created
        updated_at = $Updated
        owner_ids = $OwnerIds
        labels  = $labels
    } | ConvertTo-Json

    Write-Host
    Write-Host "Creating epic via Clubhouse API.."
    $response = Invoke-WebRequest `
        -Uri "https://api.clubhouse.io/api/v3/epics?token=$ApiToken" `
        -Method "POST" `
        -ContentType "application/json" `
        -Body $requestBody `
        -UseBasicParsing
    Write-Host $(SimplifyWebResponse -WebResponse $response)
}
