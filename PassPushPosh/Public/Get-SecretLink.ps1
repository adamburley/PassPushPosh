function Get-SecretLink {
    <#
    .SYNOPSIS
    Returns a fully qualified secret link to a push of given URL Token

    .DESCRIPTION
    Accepts a string value for a URL Token and retrieves a full URL link to the secret.
    Returned value is a 1-step retrieval link depending on option selected during Push creation.
    Returns false if URL Token is invalid, however it will return a URL if the token is valid
    but the Push is expired or deleted.

    .INPUTS
    [string] URL Token value

    .OUTPUTS
    [string] Fully qualified URL
    [bool] $False if Push URL Token is invalid. Note: Expired or deleted Pushes will still return a link.

    .EXAMPLE
    Get-SecretLink -URLToken gzv65wiiuciy
    https://pwpush.com/en/p/gzv65wiiuciy/r

    .EXAMPLE
    # En France
    PS > Get-SecretLink -URLToken gzv65wiiuciy -Language fr
    https://pwpush.com/fr/p/gzv65wiiuciy/r

    .EXAMPLE
    Get-SecretLink -URLToken gzv65wiiuciy -Raw
    { "url": "https://pwpush.com/es/p/0fkapnbo_pwp4gi8uy0/r" }

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-SecretLink.md

    .LINK
    https://pwpush.com/api/1.0/passwords/preview.en.html

    .NOTES
    Including this endpoint for completeness - however it is generally unnecessary.
    The only thing this endpoint does is return a different value depending if "Use 1-click retrieval step"
    was selected when the Push was created.  Since both the 1-click and the direct links are available
    regardless if that option is selected, the links are calculable and both are included by default in a
    [PasswordPush] object.

    As it returns false if a Push URL token is not valid you can use it to test if a Push exists without
    burning a view.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars','',Scope='Function',Justification='Global variables are used for module session helpers.')]
    [CmdletBinding()]
    [Alias('Get-PushPreview')]
    [OutputType('[string]')]
    param(
        # URL Token for the secret
        [parameter(Mandatory, ValueFromPipeline)]
        [ValidateLength(5, 256)]
        [string]$URLToken,

        # Language for returned links. Defaults to system language, can be overridden here.
        [Parameter()]
        [string]
        $Language = $Global:PPPLanguage,

        # Return the raw response body from the API call
        [Parameter()]
        [switch]
        $Raw
    )
    begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }
    process {
        try {
            if ($Language -ine 'en') { $uri += "?push_locale=$Language" }
            $iwrSplat = @{
                'Method' = 'Get'
                'ContentType' = 'application/json'
                'Uri' = "$Global:PPPBaseUrl/p/$URLToken/preview.json"
                'UserAgent' = $Global:PPPUserAgent
            }
            if ($Global:PPPHeaders) { $iwrSplat['Headers'] = $Global:PPPHeaders }
            Write-Verbose "Sending HTTP request: $($iwrSplat | Out-String)"
            $responseContent = Invoke-WebRequest @iwrSplat | Select-Object -ExpandProperty Content
            if ($Raw) { return $responseContent }
            else { return $responseContent | ConvertFrom-Json | Select-Object -ExpandProperty url }
        }
        catch {
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
                Write-Debug -Message 'Response object set to global variable $PPPLastError'
            }
        }
    }
}