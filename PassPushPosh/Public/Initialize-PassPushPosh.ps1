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

    .NOTES
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

        # Force setting new information. If module is already initialized you can use this to
        # Re-initialize with default settings. Implied if either ApiKey or BaseUrl is provided.
        [Parameter()][switch]$Force
    )
    if ($Script:PPPBaseURL -and -not $Force -and -not $ApiKey -and -not $BaseUrl) { Write-Debug -Message 'PassPushPosh is already initialized.' }
    else {
        $defaultBaseUrl = 'https://pwpush.com'
        $apiKeyOutput = if ($ApiKey) { 'x-' + $ApiKey.Substring($ApiKey.Length-4) } else { 'None' }

        if (-not $Script:PPPBaseURL) { # Not initialized
            if (-not $BaseUrl) { $BaseUrl = $defaultBaseUrl }
            Write-Verbose "Initializing PassPushPosh. ApiKey: [$apiKeyOutput], BaseUrl: $BaseUrl"
        } elseif ($Force -or $ApiKey -or $BaseURL) {
            if (-not $BaseUrl) { $BaseUrl = $defaultBaseUrl }
            $oldApiKeyOutput = if ($Script:PPPApiKey) { 'x-' + $Script:PPPApiKey.Substring($Script:PPPApiKey.Length-4) } else { 'None' }
            Write-Verbose "Re-initializing PassPushPosh. Old ApiKey: [$oldApiKeyOutput] New ApiKey: [$apiKeyOutput], Old BaseUrl: $Script:PPPBaseUrl New BaseUrl: $BaseUrl"
        }
        if ($PSCmdlet.ParameterSetName -eq 'Authenticated') {
            Set-Variable -Scope Global -Name PPPHeaders -Value @{
                'X-User-Email' = $EmailAddress
                'X-User-Token' = $ApiKey
            }
        } elseif ($Global:PPPHeaders) { # Remove if present - covers case where module is reinitialized from an authenticated to an anonymous session
            Remove-Variable -Scope Global -Name PPPHeaders
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

        Set-Variable -Scope Global -Name PPPBaseURL -Value $BaseUrl.TrimEnd('/')
        Set-Variable -Scope Global -Name PPPLanguage -Value $Language
    }
}