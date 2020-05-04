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

    $response = Invoke-WebRequest `
        -Uri "https://api.clubhouse.io/api/v3/stories?token=$ApiToken" `
        -Method "POST" `
        -ContentType "application/json" `
        -Body $requestBody `
        -UseBasicParsing
}
