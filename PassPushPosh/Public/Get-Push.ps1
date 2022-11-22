function Get-Push {
    <#
    .SYNOPSIS
    Retrieve the secret contents of a Push

    .DESCRIPTION
    Accepts a URL Token string, returns the contents of a Push along with
    metadata regarding that Push. Note, Get-Push will return data on an expired
    Push (datestamps, etc) even if it does not return the Push contents.

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush] or [string]

    .EXAMPLE
    Get-Push -URLToken gzv65wiiuciy

    .EXAMPLE
    Get-Push -URLToken gzv65wiiuciy -Raw

    {"payload":"I am your payload!","expired":false,"deleted":false,"expired_on":"","expire_after_days":1,"expire_after_views":4,"url_token":"bwzehzem_xu-","created_at":"2022-11-21T13:20:08.635Z","updated_at":"2022-11-21T13:23:45.342Z","deletable_by_viewer":true,"retrieval_step":false,"days_remaining":1,"views_remaining":4}

    .LINK
    https://pwpush.com/api/1.0/passwords/show.en.html

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars','',Scope='Function',Justification='Global variables are used for module session helpers.')]
    [CmdletBinding()]
    [OutputType([PasswordPush])]
    param(
        # URL Token for the secret
        [parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        $URLToken,

        # Return the raw response body from the API call
        [Parameter()]
        [switch]
        $Raw
    )
    begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }

    process {
        try {
            $iwrSplat = @{
                'Method' = 'Get'
                'ContentType' = 'application/json'
                'Uri' = "$Global:PPPBaseUrl/p/$URLToken.json"
                'UserAgent' = $Global:PPPUserAgent
            }
            if ($Global:PPPHeaders) { $iwrSplat['Headers'] = $Global:PPPHeaders }
            Write-Verbose "Sending HTTP request: $($iwrSplat | Out-String)"
            $response = Invoke-WebRequest @iwrSplat -ErrorAction Stop
            if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name PPPLastCall -Value $response
                Write-Debug 'Response to Invoke-WebRequest set to PPPLastCall Global variable'
            }
            if ($Raw) {
                Write-Debug "Returning raw object:`n$($response.Content)"
                return $response.Content
            }
            return $response.Content | ConvertTo-PasswordPush
        } catch {
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name PPPLastError -Value $_
                Write-Debug -Message 'Response object set to global variable $PPPLastError'
            }
        }
    }
}