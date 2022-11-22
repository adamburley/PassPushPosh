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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope = 'Function', Justification = 'Global variables are used for module session helpers.')]
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

function New-PasswordPush {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function', Justification = 'Creates a new object, no risk of overwriting data.')]
    [CmdletBinding()]
    param (

    )
    return [PasswordPush]::new()

}
function ConvertTo-PasswordPush {
    <#
    .SYNOPSIS
    Convert API call response to a PasswordPush object

    .DESCRIPTION
    Accepts a JSON string returned from the Password Pusher API and converts it to a [PasswordPush] object.
    This allows calculated push retrieval URLs, language enumeration, and a more "PowerShell" experience.
    Generally you won't need to use this directly, it's automatically invoked within Register-Push and Request-Push.

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush] for single object
    [PasswordPush[]] for Json array data

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

    .EXAMPLE
    # Invoking for a multi-Push response - only coming from the Dashboard endpoint at this time.
    PS > $webRequestResponse.Content | ConvertTo-PasswordPush -JsonIsArray

    .NOTES
    Needs a rewrite / cleanup
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function', Justification = 'Creates a new object, no risk of overwriting data.')]
    [CmdletBinding()]
    [OutputType([PasswordPush])]
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$JsonResponse
    )
    process {
        try {
            $jsonObject = $JsonResponse | ConvertFrom-Json
            foreach ($o in $jsonObject) {
                [PasswordPush]($o | ConvertTo-Json) # TODO fix this mess
            }
        } catch {
            Write-Debug 'Error in ConvertTo-PasswordPush coercing JSON object to PasswordPush object'
            Write-Debug "JsonResponse parameter value: [[$JsonResponse]]"
            Write-Error $_
        }
    }
}