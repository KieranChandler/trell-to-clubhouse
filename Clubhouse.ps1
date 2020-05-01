function New-Story(
    [string] $Name,
    [string] $Created,
    [string] $Updated,
    [string] $ProjectId
) {
    [PSCustomObject]@{
        name       = $Name
        project_id = $ProjectId
        created_at = $Created
        updated_at = $Updated
    } | ConvertTo-Json
}
