function New-Story(
    [string] $ApiToken,
    [string] $Name,
    [string] $Created,
    [string] $Updated,
    [string] $ProjectId
) {
    $requestBody = [PSCustomObject]@{
        name       = $Name
        project_id = $ProjectId
        created_at = $Created
        updated_at = $Updated
    } | ConvertTo-Json

    $response = Invoke-WebRequest `
        -Uri "https://api.clubhouse.io/api/v3/stories?token=$ApiToken" `
        -Method "POST" `
        -ContentType "application/json" `
        -Body $requestBody `
        -UseBasicParsing
}
