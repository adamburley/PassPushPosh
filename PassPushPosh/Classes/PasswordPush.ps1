class PasswordPush {
    [string]$Payload
    [string] hidden $__UrlToken
    [string] hidden $__LinkBase
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


        $this | Add-Member -Name 'UrlToken' -MemberType ScriptProperty -Value {
                return $this.__UrlToken
            } -SecondValue {
                $this.__UrlToken = $_
                $this.__LinkBase = "$Global:PPPBaseUrl/p/$($this.__UrlToken)"
            }
        $this.__UrlToken = $_j.url_token
        $this.__LinkBase = "$Global:PPPBaseUrl/p/$($this.__UrlToken)"
        $this | Add-Member -Name 'LinkDirect' -MemberType ScriptProperty -Value { return $this.__LinkBase } -SecondValue {
            Write-Warning 'LinkDirect is a read-only calculated member.'
            Write-Debug 'Link* members are calculated based on the Global BaseUrl and Push Retrieval Step values'
        }
        $this | Add-Member -Name 'LinkRetrievalStep' -MemberType ScriptProperty -Value { return "$($this.__LinkBase)/r" } -SecondValue {
            Write-Warning 'LinkRetrievalStep is a read-only calculated member.'
            Write-Debug 'Link* members are calculated based on the Global BaseUrl and Push Retrieval Step values'
        }
        $this | Add-Member -Name 'Link' -MemberType ScriptProperty -Value {
                $_Link = if ($this.RetrievalStep) { $this.LinkRetrievalStep } else { $this.LinkDirect }
                Write-Debug "Presented Link: $_link"
                return $_Link
            } -SecondValue {
                Write-Warning 'Link is a read-only calculated member.'
                Write-Debug 'Link* members are calculated based on the Global BaseUrl and Push Retrieval Step values'
            }
    }
}
