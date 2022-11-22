function Initialize-PassPushPosh {
    <#
    .SYNOPSIS
    Initialize the PassPushPosh module

    .DESCRIPTION
    Sets global variables to handle the server URL, headers (authentication), and language.
    Called automatically by module Functions if it is not called explicitly prior, so you don't actually need
    to call it unless you're going to use the authenticated API or alternate server, etc
    Default parameters use the pwpush.com domain, anonymous authentication, and whatever language your computer
    is set to.

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

    .NOTES
    All variables set by this function start with PPP.
    - PPPHeaders
    - PPPLanguage
    - PPPUserAgent
    - PPPBaseUrl

    -WhatIf setting for Set-Variable -Global is disabled, otherwise -WhatIf
    calls for other functions would return incorrect data in the case this
    function has not yet run.

    TODO: Review API key pattern for parameter validation
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars','',Scope='Function',Justification='Global variables are used for module session helpers.')]
    [CmdletBinding(DefaultParameterSetName='Anonymous')]
    param (
        # Email address to use for authenticated calls.
        [Parameter(Mandatory,Position=0,ParameterSetName='Authenticated')]
        [ValidatePattern('.+\@.+\..+')]
        [string]$EmailAddress,

        # API Key for authenticated calls.
        [Parameter(Mandatory,Position=1,ParameterSetName='Authenticated')]
        [ValidateLength(5,256)]
        [string]$ApiKey,

        # Base URL for API calls. Allows use of module with private instances of Password Pusher
        # Default: https://pwpush.com
        [Parameter(Position=0,ParameterSetName='Anonymous')]
        [Parameter(Position=2,ParameterSetName='Authenticated')]
        [ValidatePattern('^https?:\/\/[a-zA-Z0-9-_]+.[a-zA-Z0-9]+')]
        [string]$BaseUrl,

        # Language to render resulting links in. Defaults to host OS language, or English if
        # host OS language is not available
        [Parameter()]
        [string]
        $Language,

        # Set a specific user agent. Default user agent is a combination of the
        # module info, what your OS reports itself as, and a hash based on
        # your username + workstation or domain name. This way the UA can be
        # semi-consistent across sessions but not identifying.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserAgent,

        # Force setting new information. If module is already initialized you can use this to
        # Re-initialize with default settings. Implied if either ApiKey or BaseUrl is provided.
        [Parameter()][switch]$Force
    )
    if ($Global:PPPBaseURL -and $true -inotin $Force, [bool]$ApiKey, [bool]$BaseUrl, [bool]$UserAgent) { Write-Debug -Message 'PassPushPosh is already initialized.' }
    else {
        $defaultBaseUrl = 'https://pwpush.com'
        $apiKeyOutput = if ($ApiKey) { 'x-' + $ApiKey.Substring($ApiKey.Length-4) } else { 'None' }

        if (-not $Global:PPPBaseURL) { # Not initialized
            if (-not $BaseUrl) { $BaseUrl = $defaultBaseUrl }
            Write-Verbose "Initializing PassPushPosh. ApiKey: [$apiKeyOutput], BaseUrl: $BaseUrl"
        } elseif ($Force -or $ApiKey -or $BaseURL) {
            if (-not $BaseUrl) { $BaseUrl = $defaultBaseUrl }
            $oldApiKeyOutput = if ($Global:PPPApiKey) { 'x-' + $Global:PPPApiKey.Substring($Global:PPPApiKey.Length-4) } else { 'None' }
            Write-Verbose "Re-initializing PassPushPosh. Old ApiKey: [$oldApiKeyOutput] New ApiKey: [$apiKeyOutput], Old BaseUrl: $Global:PPPBaseUrl New BaseUrl: $BaseUrl"
        }
        if ($PSCmdlet.ParameterSetName -eq 'Authenticated') {
            Set-Variable -Scope Global -Name PPPHeaders -WhatIf:$false -Value @{
                'X-User-Email' = $EmailAddress
                'X-User-Token' = $ApiKey
            }
        } elseif ($Global:PPPHeaders) { # Remove if present - covers case where module is reinitialized from an authenticated to an anonymous session
            Remove-Variable -Scope Global -Name PPPHeaders -WhatIf:$false
        }
        $availableLanguages = ('en','ca','cs','da','de','es','fi','fr','hu','it','nl','no','pl','pt-BR','sr','sv')
        if (-not $Language) {
            $Culture = Get-Culture
            Write-Debug "Detected Culture: $($Culture.DisplayName)"
            $matchedLanguage = $Culture.TwoLetterISOLanguageName, $Culture.IetfLanguageTag |
                                Foreach-Object { if ($_ -iin $availableLanguages) { $_ } } |
                                Select-Object -First 1
            if ($matchedLanguage) {
                Write-Debug "Language is supported in Password Pusher."
                $Language = $matchedLanguage
            } else { Write-Warning "Detected language $($Culture.DisplayName) is not supported in PasswordPusher. Defaulting to English." }
        } else {
            if ($Language -iin $availableLanguages) {
                Write-Debug "Language [$Language] is available in PasswordPusher."
            } else
            {
                Write-Warning "Language [$Language] is not available in PasswordPusher. Defaulting to english."
                $Language = 'en'
            }
        }

        if (-not $UserAgent) {
            $osVersion = [System.Environment]::OSVersion
            $userAtDomain = "{0}@{1}" -f [System.Environment]::UserName, [System.Environment]::UserDomainName
            $uAD64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($userAtDomain))
            Write-Debug "$userAtDomain transformed to $uAD64. First 20 characters $($uAD64.Substring(0,20))"
            $UserAgent = "PassPushPosh/$((Get-Module -Name PassPushPosh).Version.ToString()) $Language $osVersion/$($uAD64.Substring(0,20))"
            Write-Verbose "Generated user agent: $UserAgent"
        } else {
            Write-Verbose "Using specified user agent: $UserAgent"
        }

        Set-Variable -WhatIf:$false -Scope Global -Name PPPBaseURL -Value $BaseUrl.TrimEnd('/')
        Set-Variable -WhatIf:$false -Scope Global -Name PPPLanguage -Value $Language
        Set-Variable -WhatIf:$false -Scope Global -Name PPPUserAgent -Value $UserAgent
    }
}