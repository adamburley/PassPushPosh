function New-Push {
    <#
    .SYNOPSIS
    Create a new Password Push

    .DESCRIPTION
    Create a new Push on the specified Password Pusher instance. The
    programmatic equivalent of going to pwpush.com and entering info.
    Returns [PasswordPush] object. Link member is a link created based on
    1-step setting and language specified, however both 1-step and direct links
    are always provided at LinkRetrievalStep and LinkDirect.

    .EXAMPLE
    $myPush = New-Push "Here's my secret!"
    PS > $myPush | Select-Object Link, LinkRetrievalStep, LinkDirect

    Link              : https://pwpush.com/en/p/gzv65wiiuciy   # Requested style
    LinkRetrievalStep : https://pwpush.com/en/p/gzv65wiiuciy/r # 1-step
    LinkDirect        : https://pwpush.com/en/p/gzv65wiiuciy   # Direct

    .EXAMPLE
    "Super secret secret" | New-Push -RetrievalStep | Select-Object -ExpandProperty Link

    https://pwpush.com/en/p/gzv65wiiuciy/r


    .EXAMPLE
    # "Burn after reading" style Push
    PS > New-Push -Payload "Still secret text!" -ExpireAfterViews 1 -RetrievalStep

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush] Push object
    [string] Raw result of API call

    .LINK
    https://pwpush.com/api/1.0/passwords/create.en.html

    .LINK
    Get-Push

    .NOTES
    Maximum for -ExpireAfterDays and -ExpireAfterViews is based on the default
    values for Password Pusher and what's used on the public instance
    (pwpush.com). If you're using this with a private instance and want to
    override that value you'll need to fork this module.

    TODO: Support [PasswordPush] input objects, testing
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars','',Scope='Function',Justification='Global variables are used for module session helpers.')]
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low',DefaultParameterSetName='Anonymous')]
    [OutputType([PasswordPush],[string],[bool])] # Returntype should be [PasswordPush] but I've yet to find a way to add class access to a function on a module...
    param(
        # The password or secret text to share.
        [Parameter(Mandatory=$true,ValueFromPipeline,Position=0)]
        [Alias('Password')]
        [ValidateNotNullOrEmpty()]
        [string]$Payload,

        # Label for this Push (requires Authenticated session)
        [Parameter(ParameterSetName='RequiresAuthentication')]
        [ValidateNotNullOrEmpty()]
        [string]$Note,

        # Expire secret link and delete after this many days.
        [Parameter()]
        [ValidateRange(1,90)]
        [int]
        $ExpireAfterDays,

        # Expire secret link after this many views.
        [Parameter()]
        [ValidateRange(1,100)]
        [int]
        $ExpireAfterViews,

        # Allow the recipient of a Push to delete it.
        [Parameter()]
        [switch]
        $DeletableByViewer,

        # Require recipient click an extra link to view Push payload.
        # Helps to avoid chat systems and URL scanners from eating up views.
        # Note that the retrieval step URL is always available for a push. This
        # parameter changes if the 1-click link is used in the Link parameter
        # and returned from the secret link helper (Get-SecretLink)
        [Parameter()]
        [switch]
        $RetrievalStep,

        # Override Language. Useful if sending to someone who speaks a
        # different language. You can change this after the fact by changing
        # the URL by hand or by requesting a link for the given token from the
        # preview helper endpoint ( See Request-SecretLink )
        [Parameter()]
        [string]
        $Language,

        # Return the raw response body from the API call
        [Parameter()]
        [switch]
        $Raw
    )

    begin {
        Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'RequiresAuthentication' -and -not $Global:PPPHeaders.'X-User-Token') { Write-Error -Message 'Setting a note requires an authenticated call.'; return $false }

        $body = @{
            'password' = @{
                'payload' = $Payload
            }
        }
        $shouldString = 'Submit {0} push with Payload of length {1}' -f $PSCmdlet.ParameterSetName, $Payload.Length
        if ($Note) {
            $body.password.note = $note
            $shouldString += " with note $note"
        }
        if ($ExpireAfterDays) {
            $body.password.expire_after_days = $ExpireAfterDays
            $shouldString += ', expire after {0} days' -f $ExpireAfterDays
        }
        if ($ExpireAfterViews) {
            $body.password.expire_after_views = $ExpireAfterViews
            $shouldString += ', expire after {0} views' -f $ExpireAfterViews
        }
        $body.password.deletable_by_viewer = if ($DeletableByViewer) {
            $shouldString += ', deletable by viewer'
            $true
        } else {
            $shouldString += ', NOT deletable by viewer'
            $false
        }
        $body.password.retrieval_step = if ($RetrievalStep) {
            $shouldString += ', with a 1-click retrieval step'
            $true
        } else {
            $shouldString += ', with a direct link'
            $false
        }
        if (-not $Language) { $Language = $Global:PPPLanguage }
        $shouldString += ' in language "{0}"' -f $Language
        if ($VerbosePreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            # Sanitize input so we're not logging or outputting the payload
            $vBody = $body.Clone()
            $vBody.password.payload = "A payload of length $($body.password.payload.Length.ToString())"
            $vBs = $vBody | ConvertTo-Json | Out-String
            Write-Verbose "Call Body (sanitized): $vBs"
        }

        $iwrSplat = @{
            'Method' = 'Post'
            'ContentType' = 'application/json'
            'Body' = ($body | ConvertTo-Json)
            'Uri' = "$Global:PPPBaseUrl/$Language/p.json"
            'UserAgent' = $Global:PPPUserAgent
        }
        if ($Global:PPPHeaders.'X-User-Token') { $iwrSplat['Headers'] = $Global:PPPHeaders }
        Write-Verbose "Sending HTTP request (minus body): $($iwrSplat | Select-Object Method,ContentType,Uri,UserAgent,Headers | Out-String)"
        if ($PSCmdlet.ShouldProcess($shouldString, $iwrSplat.Uri, 'Submit new Push')) {
            try {
                $response = Invoke-WebRequest -Uri "$Global:PPPBaseUrl/$Language/p.json" -Method Post -ContentType 'application/json' -Body ($body | ConvertTo-Json)
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
            }
        }
    }
}