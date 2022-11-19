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