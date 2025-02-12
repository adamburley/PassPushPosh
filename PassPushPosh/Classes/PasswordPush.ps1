class PasswordPush {
    [string]$Note
    [string]$Payload
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
    [int]$AccountId
    [string]$UrlToken
    [string]$Link
    [string]$LinkDirect
    [string]$LinkRetrievalStep

    PasswordPush() {
        # Blank constructor
    }

    # Constructor to allow casting or explicit import from a PSObject Representing the result of an API call
    PasswordPush([PSCustomObject]$APIresponseObject) {
        Write-Debug 'New PasswordPush object instantiated from JsonResponse string'
        Initialize-PassPushPosh # Initialize the module if not yet done.

        $_j = $APIresponseObject
        $this.Note = $_j.note
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
        $this.RetrievalStep = $_j.retrieval_step
        $this.AccountId = $_j.account_id
        $this.UrlToken = $_j.url_token
        $this.LinkDirect = $_j.json_url ? $_j.json_url.Replace('.json','') : "$Script:PPPBaseUrl/p/$($this.__UrlToken)"
        $this.LinkRetrievalStep = $this.LinkDirect, '/r' -join ''
        $this.Link = $_.html_url
    }

    # Allow casting or explicit import from the raw Content of an API call
    PasswordPush([string]$JsonResponse) {
        Write-Debug 'New PasswordPush object instantiated from JsonResponse string'
        Initialize-PassPushPosh # Initialize the module if not yet done.

        $_j = $JsonResponse | ConvertFrom-Json
        $this.Note = $_j.note
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
        $this.RetrievalStep = $_j.retrieval_step
        $this.AccountId = $_j.account_id
        $this.UrlToken = $_j.url_token
        $this.LinkDirect = $_j.json_url ? $_j.json_url.Replace('.json','') : "$Script:PPPBaseUrl/p/$($this.__UrlToken)"
        $this.LinkRetrievalStep = $this.LinkDirect, '/r' -join ''
        $this.Link = $_.html_url
    }
}
