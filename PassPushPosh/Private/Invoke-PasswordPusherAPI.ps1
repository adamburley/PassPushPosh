function Invoke-PasswordPusherAPI {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [string]$Endpoint,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
        [object]$Body,

        [Switch]$ReturnErrors
    )
    process {
        $_uri = "$Script:PPPBaseURL/$Endpoint"
        Write-Debug "Invoke-PasswordPusherAPI: $Method $_uri"

        $iwrSplat = @{
            'Method'      = $Method
            'ContentType' = 'application/json'
            'Body'        = ($body | ConvertTo-Json)
            'Uri'         = $_uri
            'UserAgent'   = $Script:PPPUserAgent
        }
        if ($Script:PPPHeaders.'X-User-Token') {
            $iwrSplat['Headers'] = $Script:PPPHeaders
            Write-Debug "Authentciated with API token $(Format-PasswordPusherSecret -Secret $Script:PPPHeaders.'X-User-Token' -ShowSample)"
        }
        $callInfo = "$Method $_uri"
        Write-Verbose "Sending HTTP request: $callInfo"

        #$call = Invoke-WebRequest @iwrSplat -SkipHttpErrorCheck
        $_errorBody = $null
        try {
            $call = Invoke-WebRequest @iwrSplat -ErrorVariable _errorBody
            $rawContent = $call.Content
            Write-Debug "Response: $($call.StatusCode) $($call.Content)"
        }
        catch {
            $rawContent = $_errorBody.Message
            $responseCode = [int]($_.Exception.Response.StatusCode)
            Write-Debug "Response: $responseCode $_errorBody"
        }
        if ($result = try { $rawContent | ConvertFrom-Json -ErrorAction SilentlyContinue } catch { $null }) {
            if ($ReturnErrors -or $call.StatusCode -eq 200 -or $null -eq $result.error) {
                $result
            }
            else {
                Write-Error -Message "$callInfo : $statusCode $($result.error)"
            }
        }
        else {
            Write-Error -Message "Parseable JSON not returned by API. $callInfo : $statusCode $rawContent"
        }
    }
}