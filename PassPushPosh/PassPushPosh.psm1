class PasswordPush {
    [string]$Payload
    [string] hidden $__UrlToken
    [string] hidden $__LinkBase
    [string]$Language
    [bool]$RetrievalStep
    [bool]$IsExpired
    [bool]$IsDeleted
    [bool]$IsDeletableByViewer
    [int]$ExpireAfterDays
    [int]$DaysRemaining
    [int]$ExpireAfterViews
    [int]$ViewsRemaining
    [DateTime]$DateCreated
    [DateTime]$DateUpdated
    [DateTime]$DateExpired
    # Added by constructors:
    #[string]$URLToken
    #[string]$Link
    #[string]$LinkDirect
    #[string]$LinkRetrievalStep

    PasswordPush() {
        # Blank constructor
    }

    # Constructor to allow casting or explicit import from a PSObject Representing the result of an API call
    PasswordPush([PSCustomObject]$APIresponseObject) {
        throw NotImplementedException
    }
    
    # Allow casting or explicit import from the raw Content of an API call
    PasswordPush([string]$JsonResponse) {
        Write-Debug 'New PasswordPush object instantiated from JsonResponse string'
        Initialize-PassPushPosh # Initialize the module if not yet done.

        $_j = $JsonResponse | ConvertFrom-Json
        $this.Payload = $_j.payload
        $this.IsExpired = $_j.expired
        $this.IsDeleted = $_j.deleted
        $this.IsDeletableByViewer = $_j.deletable_by_viewer
        $this.ExpireAfterDays = $_j.expire_after_days
        $this.DaysRemaining = $_j.days_remaining
        $this.ExpireAfterViews = $_j.expire_after_views
        $this.ViewsRemaining = $_j.views_remaining
        $this.DateCreated = $_j.created_at
        $this.DateUpdated = $_j.updated_at
        $this.DateExpired = if ($_j.expired_on) { $_j.expired_on } else { [DateTime]0 }

        $this.Language = $Global:PPPLanguage

        $this | Add-Member -Name 'UrlToken' -MemberType ScriptProperty -Value {
                return $this.__UrlToken
            } -SecondValue {
                $this.__UrlToken = $_
                $this.__LinkBase = "$Global:PPPBaseUrl/$($this.Language)/p/$($this.__UrlToken)"
            }
        $this.__UrlToken = $_j.url_token
        $this.__LinkBase = "$Global:PPPBaseUrl/$($this.Language)/p/$($this.__UrlToken)"
        $this | Add-Member -Name 'LinkDirect' -MemberType ScriptProperty -Value { return $this.__LinkBase } -SecondValue {
            Write-Warning 'LinkDirect is a read-only calculated member.'
            Write-Debug 'Link* members are calculated based on the Global BaseUrl and Language and Push Retrieval Step values'
        }
        $this | Add-Member -Name 'LinkRetrievalStep' -MemberType ScriptProperty -Value { return "$($this.__LinkBase)/r" } -SecondValue {
            Write-Warning 'LinkRetrievalStep is a read-only calculated member.'
            Write-Debug 'Link* members are calculated based on the Global BaseUrl and Language and Push Retrieval Step values'
        }
        $this | Add-Member -Name 'Link' -MemberType ScriptProperty -Value {
                $_Link = if ($this.RetrievalStep) { $this.LinkRetrievalStep } else { $this.LinkDirect }
                Write-Debug "Presented Link: $_link"
                return $_Link
            } -SecondValue {
                Write-Warning 'Link is a read-only calculated member.'
                Write-Debug 'Link* members are calculated based on the Global BaseUrl and Language and Push Retrieval Step values'
            }
    }
}

function ConvertTo-PasswordPush {
    <#
    .SYNOPSIS
    Convert API call response to a PasswordPush object
    
    .DESCRIPTION
    Accepts a JSON string returned from the Password Pusher API and converts it to a [PasswordPush] object.
    This allows calculated push retrieval URLs, language enumeration, and a more "PowerShell" experience.
    Generally you won't need to use this directly, it's automatically invoked within Register-Push and Request-Push.
    
    .EXAMPLE
    # Common usage - from within the Register-Push cmdlet
    PS> $myPush = Register-Push -Payload "This is my secret!"
    PS> $myPush.Link  # The link parameter always presents the URL as it would appear with the same settings selected on pwpush.com

    https://pwpush.com/en/p/rz6nryvl-d4

    .EXAMPLE
    # Example with manually invoking the API
    PS> $rawJson = Invoke-WebRequest  `
                    -Uri https://pwpush.com/en/p.json `
                    -Method Post `
                    -Body '{"password": { "payload": "This is my secret!"}}' `
                    -ContentType 'application/json' |
                    Select-Object -ExpandProperty Content
    PS> $rawJson

    {"expire_after_days":7,"expire_after_views":5,"expired":false,"url_token":"rz6nryvl-d4","created_at":"2022-11-18T14:16:29.821Z","updated_at":"2022-11-18T14:16:29.821Z","deleted":false,"deletable_by_viewer":true,"retrieval_step":false,"expired_on":null,"days_remaining":7,"views_remaining":5}

    PS> $rawJson | ConvertTo-PasswordPush

    UrlToken            : rz6nryvl-d4
    LinkDirect          : https://pwpush.com/en/p/rz6nryvl-d4
    LinkRetrievalStep   : https://pwpush.com/en/p/rz6nryvl-d4/r
    Link                : https://pwpush.com/en/p/rz6nryvl-d4
    Payload             : 
    Language            : en
    RetrievalStep       : False
    IsExpired           : False
    IsDeleted           : False
    IsDeletableByViewer : True
    ExpireAfterDays     : 7
    DaysRemaining       : 7
    ExpireAfterViews    : 5
    ViewsRemaining      : 5
    DateCreated         : 11/18/2022 2:16:29 PM
    DateUpdated         : 11/18/2022 2:16:29 PM
    DateExpired         : 1/1/0001 12:00:00 AM
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    [OutputType([PasswordPush])]
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$JsonResponse
    )
    process {
        try {
            return [PasswordPush]$JsonResponse
        } catch {
            Write-Debug 'Error in ConvertTo-PasswordPush coercing JSON object to PasswordPush object'
            Write-Debug "JsonResponse parameter value: [[$JsonResponse]]"
            Write-Error $_
        }
    }
}
function Get-Push {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [parameter(Mandatory,ValueFromPipeline,Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        $URLToken,

        # Returns raw json response from call
        [Parameter()]
        [switch]
        $Raw

    )
    begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }

    process {
        try {
            $response = Invoke-WebRequest -Uri $Script:PPPBaseUrl/p/$URLToken.json -Method Get -ErrorAction Stop
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
function Get-PushAuditLog {
    <#
    .SYNOPSIS
    Get the view log of an authenticated Push
    
    .DESCRIPTION
    Retrieves the view log of a Push created under an authenticated session.
    
    .INPUTS
    [string] 
    
    .OUTPUTS
    [PsCustomObject[]] Array of entries.
    [PsCustomObject] If there's an error in the call, it will be returned an object with a property
    named 'error'.  The value of that member will contain more information

    .EXAMPLE
    Get-PushAuditLog -URLToken 'mytokenfromapush'
    
    .NOTES
    General notes
    #>
  [CmdletBinding()]
  param(
    # URL Token from a secret
    [parameter(ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string]
    $URLToken,

    # Return content of API call directly
    [Parameter()]
    [switch]
    $Raw
  )
  begin {
    if (-not $Global:PPPHeaders) { Write-Error 'Retrieving audit logs requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
  }
  process {
    try { 
        $uri = "$Script:PPPBaseUrl/p/$URLToken/audit.json"
        Write-Debug 'Requesting $uri'
        Invoke-WebRequest -Uri $uri -Method Get -Headers $Global:PPPHeaders -ErrorAction Stop
    } catch {
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
            Write-Debug -Message 'Response object set to global variable $PPPLastError'
            return @{
                'Error'        = $_.Exception.Message
                'ErrorCode'    = [int]$_.Exception.Response.StatusCode
                'ErrorMessage' = $_.Exception.Response.ReasonPhrase
            }
        }
        return 
    }    
  }
}

# Invalid API key / email - 401
# Invalid URL Token - 404
# Valid token but not mine - 200, content =  {"error":"That push doesn't belong to you."}
# Success but no views - 200, content = : {"views":[]}
# Success with view history {"views":[{"ip":"75.118.137.58,172.70.135.200","user_agent":"Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101; en-US) PowerShell/7.2.7","referrer":"","successful":true,"created_at":"2022-11-19T18:32:42.277Z","updated_at":"2022-11-19T18:32:42.277Z","kind":0}]}
# Content.Views
<#
ip         : 75.118.137.58,172.70.135.200
user_agent : Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101; 
             en-US) PowerShell/7.2.7
referrer   : 
successful : True
created_at : 11/19/2022 6:32:42 PM
updated_at : 11/19/2022 6:32:42 PM
kind       : 0
#>
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
  [CmdletBinding()]
  param(
    # Secret URL token of a previously created push.
    [parameter(Mandatory, ValueFromPipeline)]
    [ValidateLength(5,256)]
    [string]$URLToken,

    # Language for returned links. Defaults to system language, can be overridden here.
    [Parameter()]
    [string]
    $Language = 'en'
  )
  begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }
  process {
    try { 
        $uri = "$Script:PPPBaseUrl/p/$URLToken/preview.json"
        if ($Language -ine 'en') { $uri += "?push_locale=$Language" }
        Invoke-WebRequest -Uri $uri -Method Get -ErrorAction Stop | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty url
    } catch {
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
            Write-Debug -Message 'Response object set to global variable $PPPLastError'
            return @{
                'Error'        = $_.Exception.Message
                'ErrorCode'    = [int]$_.Exception.Response.StatusCode
                'ErrorMessage' = $_.Exception.Response.ReasonPhrase
            }
        }
        return 
    }
  }
}

<# Sample response
{ "url": "https://pwpush.com/es/p/0fkapnbo_pwp4gi8uy0/r" }
#>
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
            $Global:PPPHeaders = @{
                'X-User-Email' = $EmailAddress
                'X-User-Token' = $ApiKey
            }
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

        $Script:PPPBaseUrl = $BaseUrl.TrimEnd('/')
        $Script:PPPLanguage = $Language
    }
}
function New-Push {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        # The password or secret text to share.
        [parameter(Mandatory=$true,Position=0)]
        [Alias('Password')]
        [ValidateNotNullOrEmpty()]
        [string]$Payload,

        # If authenticated, the note to label this push.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Note,

        # Expire secret link and delete after this many days.
        # Default maximum is 90 days but we'll use 365 here for a bit more flexibility.
        # Note if server does not support the lifetime you specify you'll receive an error.
        [Parameter()]
        [ValidateRange(1,365)]
        [int]
        $ExpireAfterDays,

        # Expire secret link and delete after this many views.
        # Default max is 100, if using a larger default you may need to fork this function
        [Parameter()]
        [ValidateRange(1,100)]
        [int]
        $ExpireAfterViews,

        # Allow users to delete passwords once retrieved.
        [Parameter()]
        [switch]
        $DeletableByViewer,

        # PassPushPosh requests a 1-click retrieval step by default. Set this to disable it.
        # Helps to avoid chat systems and URL scanners from eating up views.
        # Note that the retrieval step URL is always available for a push. This switch only changes
        # the link provided by the preview helper endpoint. This cmdlet will return all links
        [Parameter()]
        [switch]
        $DisableRetrievalStep,

        # Override Language set in global variable PPPLanguage (default: Host OS Language)
        # You can change this after the fact by changing the URL or by requesting a link for the given
        # token from the preview helper endpoint ( See @Request-SecretLink )
        [Parameter()]
        [string]
        $Language = 'en',

        # Return the raw response from the API as a PSCustomObject
        [Parameter()]
        [switch]
        $Raw
    )

    begin {
        Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference
    }

    process {
        if ($Note -and -not $Script:PPPHeaders.'X-User-Token') { Write-Error -Message 'Setting a note requires an authenticated call.'; return $false }

        $body = @{
            'password' = @{
                'payload' = $Payload
            }
        }
        if ($Note) { $body.password.note = $note }
        if ($ExpireAfterDays) { $body.password.expire_after_days = $ExpireAfterDays }
        if ($ExpireAfterViews) { $body.password.expire_after_views = $ExpireAfterViews }
        if ($DeletableByViewer) { $body.password.deletable_by_viewer = $DeletableByViewer }
        $body.password.retrieval_step = if ($DisableRetrievalStep) { $false } else { $true }
        Write-Debug ($body | ConvertTo-Json).tostring()
        try {
            $response = Invoke-WebRequest -Uri "$Script:PPPBaseUrl/$Language/p.json" -Method Post -ContentType 'application/json' -Body ($body | ConvertTo-Json)
            if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name PPPLastCall -Value $response
                Write-Debug 'Response to Invoke-WebRequest set to PPPLastCall Global variable'
            }
            if ($Raw) { 
                Write-Debug "Returning raw object: $($response.Content)"
                return $response.Content
            }
            return $response.Content | ConvertTo-PasswordPush
        } catch { 
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name PPPLastError -Value $_
                Write-Debug -Message 'Response object set to global variable $PPPLastError'
            }
            return @{
                'Error' = $_.Exception.Message
                'ErrorCode' = [int]$_.Exception.Response.StatusCode
                'ErrorMessage' = $_.Exception.Response.ReasonPhrase
            }
        }
    }
}


<# Sample API Response
Raw:
    {"expire_after_days":1,"expire_after_views":1,"expired":false,"url_token":"esqz_4hyfvjvrmpcka","created_at":"2022-11-17T16:16:10.731Z","updated_at":"2022-11-17T16:16:10.731Z","deleted":false,"deletable_by_viewer":true,"retrieval_step":false,"expired_on":null,"days_remaining":1,"views_remaining":1}

PSCustomObject:
    expire_after_days   : 1
    expire_after_views  : 1
    expired             : False
    url_token           : esqz_4hyfvjvrmpcka
    created_at          : 11/17/2022 4:16:10 PM
    updated_at          : 11/17/2022 4:16:10 PM
    deleted             : False
    deletable_by_viewer : True
    retrieval_step      : False
    expired_on          : 
    days_remaining      : 1
    views_remaining     : 1
#>
function Remove-Push {
  [CmdletBinding(DefaultParameterSetName='Token')]
  [OutputType([PasswordPush],[string],[bool])]
  param(
    # URL Token string from a Push
    [parameter(ValueFromPipeline,ParameterSetName='Token')]
    [string]
    $URLToken,

    # PasswordPush object
    [Parameter(ValueFromPipeline,ParameterSetName='Object')]
    [PasswordPush]
    $PushObject,

    # Return raw result of API call
    [parameter()]
    [switch]
    $Raw
  )

  process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Object') {
            Write-Debug -Message "Remove-Push was passed a PasswordPush object with URLToken: [$($PushObject.URLToken)]"
            if (-not $PushObject.IsDeletableByViewer -and -not $Global.PPPHeaders) { #Pre-qualify if this will succeed
                Write-Warning -Message 'Unable to remove Push. Push is not marked as deletable by viewer and you are not authenticated.'
                return $false
            }
            if ($PushObject.IsDeletableByViewer) { 
                Write-Verbose "Push is flagged as deletable by viewer, should be deletable."
            } else { Write-Verbose "In an authenticated API session. Push will be deletable if it was created by authenticated user." }
            $URLToken = $PushObject.URLToken
        } else {
            Write-Debug -Message "Remove-Push was passed a URLToken: [$URLToken]"
        }
        Write-Verbose -Message "Push with URL Token [$URLToken] will be deleted if 'Deletable by viewer' was enabled or you are the creator of the push and are authenticated."
        $response = Invoke-WebRequest -Uri "$Script:PPPBaseUrl/p/$URLToken.json" -Method Delete
        if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            Set-Variable -Scope Global -Name PPPLastCall -Value $response
            Write-Debug 'Response to Invoke-WebRequest set to PPPLastCall Global variable'
        }
        if ($Raw) { 
            Write-Debug "Returning raw object: $($response.Content)"
            return $response.Content
        }
        return $response.Content | ConvertTo-PasswordPush
    } catch { 
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Failed to delete Push. This can indicate an invalid URL Token, that the password was not marked deletable, or that you are not the owner."
            return $false
        } else {
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name PPPLastError -Value $_
                Write-Debug -Message 'Response object set to global variable $PPPLastError'
            }
            return @{
                'Error' = $_.Exception.Message
                'ErrorCode' = [int]$_.Exception.Response.StatusCode
                'ErrorMessage' = $_.Exception.Response.ReasonPhrase
            }
        }
    }
  }
}
