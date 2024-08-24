function Invoke-PasswordPusherAPI {
    [CmdletBinding()]
 #   [OutputType([PasswordPush],[string])]
    param(
        [string]$Endpoint,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
        [object]$Body
    )
    process {
        $_uri = "$Script:PPPBaseURL/$Endpoint"
        Write-Debug "Invoke-PasswordPusherAPI: $Method $_uri"

        $iwrSplat = @{
            'Method' = $Method
            'ContentType' = 'application/json'
            'Body' = ($body | ConvertTo-Json)
            'Uri' = $_uri
            'UserAgent' = $Script:PPPUserAgent
        }
        if ($Script:PPPHeaders.'X-User-Token') {
            $iwrSplat['Headers'] = $Script:PPPHeaders
            Write-Debug "API token **" + $Script:PPPHeaders.'X-User-Token'.Substring($Script:PPPHeaders.'X-User-Token'.Length-4)
        }
        Write-Verbose "Sending HTTP request (minus body): $($iwrSplat | Select-Object Method,ContentType,Uri,UserAgent,Headers | Out-String)"

        Invoke-WebRequest @iwrSplat -SkipHttpErrorCheck
    }
}