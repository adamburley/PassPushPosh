<#
    .SYNOPSIS
    Initialize the PassPushPosh module

    .DESCRIPTION
    Initialize-PassPushPosh sets variables for the module's use during the remainder of the session.
    Server URL and User Agent values are set by default but may be overridden.
    If invoked with email address and API key, calls are sent as authenticated. Otherwise they default to
    anonymous.

    This function is called automatically if needed, defaulting to the public pwpush.com service.

    .PARAMETER Bearer
    API key for authenticated calls. Supported on hosted instance and OSS v1.51.0 and newer.

    .PARAMETER ApiKey
    API key for authenticated calls. Supports older OSS installs.
    Also supports Bearer autodetection. This will be removed in a future version.

    .PARAMETER EmailAddress
    Email address for authenticated calls.
    NOTE: This is only required for legacy X-User-Token authentication. If using hosted pwpush.com
    services or OSS v1.51.0 or newer use -Bearer

    .PARAMETER UseLegacyAuth
    Use legacy X-User-Token. Supportsversions of Password Pusher OSS older than v1.51.0.
    If this is not set, but -ApiKey and -EmailAddress are specified the module will attempt to
    auto-detect the correct connection.

    .PARAMETER BaseUrl
    Base URL for API calls. Allows use of custom domains with hosted Password Pusher as well as specifying
    a private instance.

    Default: https://pwpush.com

    .PARAMETER UserAgent
    Set a specific user agent. Default user agent is a combination of the
    module info, what your OS reports itself as, and a hash based on
    your username + workstation or domain name. This way the UA can be
    semi-consistent across sessions but not identifying.

    Note: User agent must meet [RFC9110](https://www.rfc-editor.org/rfc/rfc9110#name-user-agent) specifications or the Password Pusher API will reject the call.

    .PARAMETER Force
    Force setting new information. If module is already initialized you can use this to
    re-initialize the module. If not specified and there is an existing session the request is ignored.

    .EXAMPLE
    # Default settings
    PS > Initialize-PassPushPosh

    .EXAMPLE
    # Authentication
    PS > Initialize-PassPushPosh -Bearer 'myreallylongapikey'

    .EXAMPLE
    # Initialize with another domain - may be a private instance or a hosted instance with custom domain
    PS > Initialize-PassPushPosh -BaseUrl https://myprivatepwpushinstance.example.com -Bearer 'myreallylongapikey'

    .EXAMPLE
    # Legacy authentication support
    PS > Initialize-PassPushPosh -ApiKey 'myreallylongapikey' -EmailAddress 'myregisteredemail@example.com' -UseLegacyAuthentication -BaseUrl https://myprivatepwpushinstance.example.com

    .EXAMPLE
    # Set a custom User Agent
    PS > InitializePassPushPosh -UserAgent "My-CoolUserAgent/1.12.1"

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Initialize-PassPushPosh.md

    .NOTES
    The use of X-USER-TOKEN for authentication is depreciated and will be removed in a future release of the API.
    This module will support it via legacy mode, initially by attempting to auto-detect if Bearer is supported.
    New code using this module should use -Bearer (most cases) or -UseLegacyAuthentication (self-hosted older versions).
    In a future release the module will default to Bearer unless the -UseLegacyAuthentication switch is set.

    #>
function Initialize-PassPushPosh {
    [CmdletBinding(DefaultParameterSetName = 'Anonymous')]
    param (
        [Parameter(ParameterSetName = 'Authenticated')]
        [string]$Bearer,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Legacy Auth')]
        [ValidateLength(5, 256)]
        [string]$ApiKey,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'Legacy Auth')]
        [ValidatePattern('.+\@.+\..+', ErrorMessage = 'Please specify a valid email address')]
        [string]$EmailAddress,

        [Parameter(ParameterSetName = 'Legacy Auth')]
        [switch]$UseLegacyAuthentication,

        [Parameter()]
        [ValidatePattern('^https?:\/\/[a-zA-Z0-9-_]+.[a-zA-Z0-9]+')]
        [string]$BaseUrl,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserAgent,

        [Parameter()]
        [switch]$Force
    )
    if ($Script:PPPBaseURL -and -not $Force) { Write-Debug -Message 'PassPushPosh is already initialized.' }
    else {
        $_baseUrl = $PSBoundParameters.ContainsKey('BaseUrl') ? $BaseUrl : 'https://pwpush.com'
        $_apiKey = $PSBoundParameters.ContainsKey('Bearer') ? $Bearer : $ApiKey

        $apiKeySample = $_apiKey ? (Format-PasswordPusherSecret -Secret $_apiKey -ShowSample) : 'None'

        $_AuthType = $PSCmdlet.ParameterSetName -iin 'Anonymous', 'Authenticated' ? $PSCmdlet.ParameterSetName : $UseLegacyAuthentication ? 'Legacy' : 'Automatic'

        switch ($_AuthType) {
            'Anonymous' {
                # module is reinitialized from an authenticated to an anonymous session
                Remove-Variable -Scope Script -Name PPPHeaders -WhatIf:$false -ErrorAction SilentlyContinue
            }
            'Authenticated' {
                Write-Debug 'Bearer auth specified.'
                Set-Variable -Scope Script -Name PPPHeaders -WhatIf:$false -Value @{
                    'Authorization' = "Bearer $_apiKey"
                }
            }
            'Legacy' {
                Write-Debug 'Legacy auth specified.'
                Set-Variable -Scope Script -Name PPPHeaders -WhatIf:$false -Value @{
                    'X-User-Email' = $EmailAddress
                    'X-User-Token' = $_apiKey
                }
            }
            'Automatic' {
                Write-Debug 'Legacy auth status not specified Checking for /up'
                if ((Invoke-WebRequest "$_baseUrl/up" -SkipHttpErrorCheck).StatusCode -eq 200) {
                    Write-Debug "Current version detected via /up"
                    Set-Variable -Scope Script -Name PPPHeaders -WhatIf:$false -Value @{
                        'Authorization' = "Bearer $_apiKey"
                    }
                } else {
                    Write-Warning 'Instance does not appear to support modern Bearer authentication.'
                    Write-Warning 'The module will fall back to using legacy authentication.'
                    Write-Warning 'If you are connecting to a self-hosted instance, verify it is up to date.'
                    Write-Warning 'If you know you need legacy (X-User-Token) authentication include  Invoke-PassPushPosh -UseLegacyAuth $true'
                    Write-Warning 'To skip the step check and this warning.'
                    Set-Variable -Scope Script -Name PPPHeaders -WhatIf:$false -Force -Value @{
                        'X-User-Email' = $EmailAddress
                        'X-User-Token' = $_apiKey
                    }
                }
            }
        }

        Set-Variable -WhatIf:$false -Scope Script -Name PPPUserAgent -Value ($PSBoundParameters.ContainsKey('UserAgent') ? $UserAgent : (New-PasswordPusherUserAgent))
        Set-Variable -WhatIf:$false -Scope Script -Name PPPBaseURL -Value $_baseUrl.TrimEnd('/')

        Write-Verbose -Message "PassPushPosh Initialized with these settings: Account type: [$_AuthType] API Key: $apiKeySample Base URL: [$_baseUrl]"
        Write-Verbose -Message "User Agent: $Script:PPPUserAgent"
    }
}