function New-Story(
    [string] $Name,
    [string] $Created,
    [string] $ProjectId
) {
    [PSCustomObject]@{
        name       = $Name
        project_id = $ProjectId
        created_at = $Created
    } | ConvertTo-Json
}
