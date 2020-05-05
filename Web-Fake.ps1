function Invoke-PostRequest(
    [string] $Uri,
    [PSCustomObject] $RequestBodyObj
) {
    Write-Host
    Write-Host "Invoked URL $Uri with request body: "
    Write-Host $RequestBodyObj | ConvertTo-Json
    Write-Host

    return "{}"
}