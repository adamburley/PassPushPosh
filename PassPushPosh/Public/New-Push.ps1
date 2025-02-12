<#
    .SYNOPSIS
    Create a new Push

    .DESCRIPTION
    Create a new Push on the specified Password Pusher instance. The
    programmatic equivalent of going to pwpush.com and entering info.
    Returns [PasswordPush] object. Link member is a link created based on
    1-step setting however both 1-step and direct links
    are always provided at LinkRetrievalStep and LinkDirect properties.

    .PARAMETER Payload
    The URL password or secret text to share.

    .PARAMETER Passphrase
    Require recipients to enter this passphrase to view the created push.

    .PARAMETER Note
    The note for this push.  Visible only to the push creator. Requires authentication.

    .PARAMETER ExpireAfterDays
    Expire secret link and delete after this many days.

    .PARAMETER ExpireAfterViews
    Expire secret link and delete after this many views.

    .PARAMETER DeletableByViewer
    Allow the recipient of a Push to delete it.

    .PARAMETER RetrievalStep
    Require recipient click an extra link to view Push payload.
    Helps to avoid chat systems and URL scanners from eating up views.
    Note that the retrieval step URL is always available for a push. This
    parameter changes if the 1-click link is used in the Link parameter
    and returned from the secret link helper (Get-SecretLink)

    .PARAMETER AccountId
    Account ID to associate with this push. Requires authentication.

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush] Representation of the submitted push

    .EXAMPLE
    $myPush = New-Push "Here's my secret!"
    PS > $myPush | Select-Object Link, LinkRetrievalStep, LinkDirect

    Link              : https://pwpush.com/p/gzv65wiiuciy   # Requested style
    LinkRetrievalStep : https://pwpush.com/p/gzv65wiiuciy/r # 1-step
    LinkDirect        : https://pwpush.com/p/gzv65wiiuciy   # Direct

    .EXAMPLE
    "Super secret secret" | New-Push -RetrievalStep | Select-Object -ExpandProperty Link

    https://pwpush.com/p/gzv65wiiuciy/r


    .EXAMPLE
    # "Burn after reading" style Push
    PS > New-Push -Payload "Still secret text!" -ExpireAfterViews 1 -RetrievalStep

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/New-Push.md

    .LINK
    https://pwpush.com/api/1.0/passwords/create.en.html

    .LINK
    https://github.com/pglombardo/PasswordPusher/blob/c2909b2d5f1315f9b66939c9fbc7fd47b0cfeb03/app/controllers/passwords_controller.rb#L120

    .LINK
    Get-Push

    .NOTES
    Maximum for -ExpireAfterDays and -ExpireAfterViews is based on the default
    values for Password Pusher and what's used on the public instance
    (pwpush.com). If you're using this with a private instance and want to
    override that value you'll need to fork this module.
    #>
function New-Push {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Passphrase', Justification = "DE0001: SecureString shouldn't be used")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'Text')]
    [OutputType([PasswordPush])]
    param(
        [Parameter(ParameterSetName = 'Text', ValueFromPipeline)]
        [Alias('Password')]
        [ValidateNotNullOrEmpty()]
        [string]$Payload,

        [Parameter(ParameterSetName = 'QR', Mandatory)]
        [string]$QR,

        [Parameter(ParameterSetName = 'URL')]
        [ValidatePattern('^https?:\/\/[a-zA-Z0-9-_]+.[a-zA-Z0-9]+')]
        [string]$URL,

        [Parameter(ParameterSetName = 'Text')]
        [Parameter(ParameterSetName = 'QR')]
        [ValidateCount(1, 10)]
        [ValidateScript({ $null -ne $Script:PPPHeaders.'X-User-Token' -or $null -ne $Script:PPPHeaders.Authorization }, ErrorMessage = 'Adding files requires authentication.')]
        [object[]]$File,

        [Parameter()]
        [string]$Passphrase,

        [Parameter()]
        [ValidateScript({ $null -ne $Script:PPPHeaders.'X-User-Token' -or $null -ne $Script:PPPHeaders.Authorization }, ErrorMessage = 'Adding a note requires authentication.')]
        [ValidateNotNullOrEmpty()]
        [string]$Note,

        [Parameter()]
        [ValidateRange(1, 90)]
        [int]
        $ExpireAfterDays,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]
        $ExpireAfterViews,

        [Parameter()]
        [switch]
        $DeletableByViewer,

        [Parameter()]
        [switch]
        $RetrievalStep,

        [Parameter()]
        [ValidateScript({ $null -ne $Script:PPPHeaders.Authorization }, ErrorMessage = 'Adding an account id requires authentication.')]
        $AccountId,

        [Parameter(ParameterSetName = 'Text')]
        [ValidateSet('Text', 'File', 'QR', 'URL')]
        [string]$Kind = 'Text'
    )

    begin {
        Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference
    }
    process {
        $_Kind = switch ($PSCmdlet.ParameterSetName) {
            'QR' { 'qr' }
            'URL' { 'url' }
            default {
                $File ? 'file' : $Kind.ToLower()
            }
        }
        Write-Debug "Parameter Set: $($PSCmdlet.ParameterSetName)"
        Write-Debug "Kind: $_Kind"

        $passVals = @{ 'kind' = $_Kind }
        $shouldString = "Submit $_Kind push"

        if ($_Payload = $Payload ? $Payload : $QR ? $QR : $URL ? $URL : $Null) {
            $shouldString += ", with payload of length $($_Payload.Length)"
            $passVals.payload = $_Payload
        }
        elseif ($_Kind -ine 'File') {
            Write-Error "A payload is required for all Push types except File." -ErrorAction Stop
        }
        if ($Passphrase) {
            $passVals.passphrase = $Passphrase
            $shouldString += ", with passphrase of length $($Passphrase.Length)"
        }
        if ($Note) {
            $passVals.note = $note
            $shouldString += ", with note $note"
        }
        if ($ExpireAfterDays) {
            $passVals.expire_after_days = $ExpireAfterDays
            $shouldString += ", expire after $ExpireAfterDays days"
        }
        if ($ExpireAfterViews) {
            $passVals.expire_after_views = $ExpireAfterViews
            $shouldString += ", expire after $ExpireAfterViews views"
        }
        if ($PSBoundParameters.ContainsKey('DeletableByViewer')) {
            $passVals.deletable_by_viewer = $DeletableByViewer
            $shouldString += $DeletableByViewer ? ', deletable by viewer' : ', not deletable by viewer'
        }
        if ($PSBoundParameters.ContainsKey('RetrievalStep')) {
            $passVals.retrieval_step = $RetrievalStep
            $shouldString += $RetrievalStep ? ', with a 1-click retrieval step' : ', without a retrieval step'
        }
     
        if ($File) {
            $_Files = Get-ChildItem -Path $File
            Write-Debug "Attaching $($_Files.Name -join '; ')"
            if ($_Files.Count -gt 10) {
                Write-Error "The total number of files is greater than allowed. Only 10 files may be attached to each Push." -ErrorAction Stop
            }
            else {
                $shouldString += ", attaching $($_Files.count) files"
            }
            $Form = @{ }
            $passVals.GetEnumerator() | ForEach-Object { $Form.Add("password[$($_.Name)]", $_.Value) }
            $Form.'password[files][]' = $_Files
            if ($AccountId) {
                $Form.account_id = $AccountId
                $shouldString += ', with account ID {0}' -f $AccountId
            }
            Write-Debug "Form looks like $($Form | Out-String)"
            $invokeSplat = @{
                Form = $Form
            }
        } else {
            $Body = @{ 'password' = $passVals }
            if ($AccountId) {
                $Body.account_id = $AccountId
                $shouldString += ', with account ID {0}' -f $AccountId
            }
            Write-Debug "Body looks like $($Body | ConvertTo-Json -Depth 5)"
            $invokeSplat = @{
                Body = $Body
            }
        }
        if ($PSCmdlet.ShouldProcess($shouldString, $Script:PPPBaseUrl, 'Submit new Push')) {
            $response = Invoke-PasswordPusherAPI -Endpoint 'p.json' -Method Post @invokeSplat
            $response | ConvertTo-PasswordPush
        }
    }
}