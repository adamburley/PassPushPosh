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

        $call = Invoke-WebRequest @iwrSplat -SkipHttpErrorCheck
        Write-Debug "Response: $($call.StatusCode) $($call.Content)"
        if (Test-Json -Json $call.Content) {
            $result = $call.Content | ConvertFrom-Json
            if ($ReturnErrors -or $null -eq $result.error) {
                $result
            }
            else {
                Write-Error -Message "$callInfo : $($call.StatusCode) $($result.error)"
            }
        }
        else {
            Write-Error -Message "Parseable JSON not returned by API. $callInfo : $($call.StatusCode) $($call.Content)"
        }
    }
}