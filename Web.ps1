function SimplifyWebResponse($WebResponse) {
    $WebResponse | Select-Object StatusCode, StatusDescription, Content | ConvertTo-Json
}

function Invoke-PostRequest(
    [string] $Uri,
    [PSCustomObject] $RequestBodyObj
) {
    $response = Invoke-WebRequest `
        -Uri $Uri `
        -Method "POST" `
        -ContentType "application/json" `
        -Body $RequestBodyObj `
        -UseBasicParsing

    Write-Host $(SimplifyWebResponse -WebResponse $response)
    Write-Host

    return $response
}

function Invoke-GetRequest(
    [string] $Uri
) {
    $response = Invoke-WebRequest `
        -Uri $Uri `
        -Method "GET" `
        -ContentType "application/json" `
        -UseBasicParsing

    return $response
}