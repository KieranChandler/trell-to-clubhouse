function SimplifyWebResponse($WebResponse) {
    $WebResponse | Select-Object StatusCode, StatusDescription, Content | ConvertTo-Json
}

function StatusCodeIsSuccess([int] $StatusCode) {
    ($StatusCode -eq 200 `
        -or `
        $StatusCode -eq 201 `
        -or `
        $StatusCode -eq 202 `
        -or `
        $StatusCode -eq 203)
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

    return $response
}

function Invoke-PutRequest(
    [string] $Uri,
    [PSCustomObject] $RequestBodyObj
) {
    $response = Invoke-WebRequest `
        -Uri $Uri `
        -Method "Put" `
        -ContentType "application/json" `
        -Body $RequestBodyObj `
        -UseBasicParsing

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