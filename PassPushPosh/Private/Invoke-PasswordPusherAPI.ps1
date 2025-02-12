function Invoke-PasswordPusherAPI {
    [CmdletBinding(DefaultParameterSetName = 'Body')]
    [OutputType([PSCustomObject])]
    param(
        [string]$Endpoint,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
        
        [Parameter(ParameterSetName = 'Body')]
        [object]$Body,

        [Parameter(ParameterSetName = 'Form')]
        [object]$Form,

        [Switch]$ReturnErrors
    )
    process {
        $_uri = "$Script:PPPBaseURL/$Endpoint"
        Write-Debug "Invoke-PasswordPusherAPI: $Method $_uri"

        $iwrSplat = @{
            'Method'      = $Method
            'Uri'         = $_uri
            'UserAgent'   = $Script:PPPUserAgent
        }
        if ($PSCmdlet.ParameterSetName -eq 'Form') {
            $iwrSplat.Form = $Form
        } else {
            $iwrSplat.Body = ($body | ConvertTo-Json)
            $iwrSplat.ContentType = 'application/json'
        }
        if ($Script:PPPHeaders.'X-User-Token') {
            $iwrSplat['Headers'] = $Script:PPPHeaders
            Write-Debug "Authenticated with X-User-Token $(Format-PasswordPusherSecret -Secret $Script:PPPHeaders.'X-User-Token' -ShowSample)"
        }
        if ($Script:PPPHeaders.'Authorization') {
            $iwrSplat['Headers'] = $Script:PPPHeaders
            Write-Debug "Authenticated with Bearer token $(Format-PasswordPusherSecret -Secret $Script:PPPHeaders.'Authorization' -ShowSample)"
        }
        $callInfo = "$Method $_uri"
        Write-Verbose "Sending HTTP request: $callInfo"

        $call = Invoke-WebRequest @iwrSplat -SkipHttpErrorCheck
        Write-Debug "Response: $($call.StatusCode) $($call.Content)"
        if (Test-Json -Json $call.Content) {
            $result = $call.Content | ConvertFrom-Json
            if ($ReturnErrors -or $call.StatusCode -eq 200 -or $null -eq $result.error) {
                $result
            } else {
                Write-Error -Message "$callInfo : $($call.StatusCode) $($result.error)"
            }
        } else {
            Write-Error -Message "Parseable JSON not returned by API. $callInfo : $($call.StatusCode) $($call.Content)"
        }
    }
}