<#
    .SYNOPSIS
    Initialize the PassPushPosh module

    .DESCRIPTION
    Initialize-PassPushPosh sets variables for the module's use during the remainder of the session.
    Server URL and User Agent values are set by default but may be overridden.
    If invoked with email address and API key, calls are sent as authenticated. Otherwise they default to
    anonymous.

    This function is called automatically if needed, defaulting to the public pwpush.com service.

    .PARAMETER EmailAddress
    Email address for authenticated calls.

    .PARAMETER ApiKey
    API key for authenticated calls.

    .PARAMETER BaseUrl
    Base URL for API calls. Allows use of module with private instances of Password Pusher
    Default: https://pwpush.com

    .PARAMETER UserAgent
    Set a specific user agent. Default user agent is a combination of the
    module info, what your OS reports itself as, and a hash based on
    your username + workstation or domain name. This way the UA can be
    semi-consistent across sessions but not identifying.

    .PARAMETER Force
    Force setting new information. If module is already initialized you can use this to
    Re-initialize with default settings. Implied if either ApiKey or BaseUrl is provided.

    .EXAMPLE
    # Initialize with default settings
    PS > Initialize-PassPushPosh

    .EXAMPLE
    # Initialize with authentication
    PS > Initialize-PassPushPosh -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose

    VERBOSE: Initializing PassPushPosh. ApiKey: [x-kdjf], BaseUrl: https://pwpush.com

    .EXAMPLE
    # Initialize with another server with authentication
    PS > Initialize-PassPushPosh -BaseUrl https://myprivatepwpushinstance.com -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose

    VERBOSE: Initializing PassPushPosh. ApiKey: [x-kdjf], BaseUrl: https://myprivatepwpushinstance.com

    .EXAMPLE
    # Set a custom User Agent
    PS > InitializePassPushPosh -UserAgent "I'm a cool dude with a cool script."

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Initialize-PassPushPosh.md

    .NOTES
    -WhatIf setting for Set-Variable -Script is disabled, otherwise -WhatIf
    calls for other functions would return incorrect data in the case this
    function has not yet run.
    #>
function Initialize-PassPushPosh {
    [CmdletBinding(DefaultParameterSetName = 'Anonymous')]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Authenticated')]
        [ValidatePattern('.+\@.+\..+')]
        [string]$EmailAddress,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'Authenticated')]
        [ValidateLength(5, 256)]
        [string]$ApiKey,

        [Parameter(Position = 0, ParameterSetName = 'Anonymous')]
        [Parameter(Position = 2, ParameterSetName = 'Authenticated')]
        [ValidatePattern('^https?:\/\/[a-zA-Z0-9-_]+.[a-zA-Z0-9]+')]
        [string]$BaseUrl,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserAgent,

        [Parameter()][switch]$Force
    )
    if ($Script:PPPBaseURL -and $true -inotin $Force, [bool]$ApiKey, [bool]$BaseUrl, [bool]$UserAgent) { Write-Debug -Message 'PassPushPosh is already initialized.' }
    else {
        $defaultBaseUrl = 'https://pwpush.com'
        $apiKeyOutput = if ($ApiKey) { (Format-PasswordPusherSecret -Secret $ApiKey -ShowSample) } else { 'None' }

        if (-not $Script:PPPBaseURL) {
            # Not initialized
            if (-not $BaseUrl) { $BaseUrl = $defaultBaseUrl }
            Write-Verbose "Initializing PassPushPosh. ApiKey: [$apiKeyOutput], BaseUrl: $BaseUrl"
        }
        elseif ($Force -or $ApiKey -or $BaseURL) {
            if (-not $BaseUrl) { $BaseUrl = $defaultBaseUrl }
            $oldApiKeyOutput = if ($Script:PPPApiKey) { Format-PasswordPusherSecret -Secret $Script:PPPApiKey -ShowSample } else { 'None' }
            Write-Verbose "Re-initializing PassPushPosh. Old ApiKey: [$oldApiKeyOutput] New ApiKey: [$apiKeyOutput], Old BaseUrl: $Script:PPPBaseUrl New BaseUrl: $BaseUrl"
        }
        if ($PSCmdlet.ParameterSetName -eq 'Authenticated') {
            Set-Variable -Scope Script -Name PPPHeaders -WhatIf:$false -Value @{
                'X-User-Email' = $EmailAddress
                'X-User-Token' = $ApiKey
            }
        }
        elseif ($Script:PPPHeaders) {
            # Remove if present - covers case where module is reinitialized from an authenticated to an anonymous session
            Remove-Variable -Scope Script -Name PPPHeaders -WhatIf:$false
        }

        if (-not $UserAgent) {
            $osVersion = [System.Environment]::OSVersion
            $userAtDomain = "{0}@{1}" -f [System.Environment]::UserName, [System.Environment]::UserDomainName
            $uAD64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($userAtDomain))
            Write-Debug "$userAtDomain transformed to $uAD64. First 20 characters $($uAD64.Substring(0,20))"
            # Version tag is replaced by the semantic version number at build time. See PassPushPosh/issues/11 for context
            $UserAgent = "PassPushPosh/{{semversion}} $osVersion/$($uAD64.Substring(0,20))"
            # $UserAgent = "PassPushPosh/$((Get-Module -Name PassPushPosh).Version.ToString()) $osVersion/$($uAD64.Substring(0,20))"
            Write-Verbose "Generated user agent: $UserAgent"
        }
        else {
            Write-Verbose "Using specified user agent: $UserAgent"
        }

        Set-Variable -WhatIf:$false -Scope Script -Name PPPBaseURL -Value $BaseUrl.TrimEnd('/')
        Set-Variable -WhatIf:$false -Scope Script -Name PPPUserAgent -Value $UserAgent
    }
}