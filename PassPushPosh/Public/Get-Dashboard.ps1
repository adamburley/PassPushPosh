function Get-Dashboard {
    <#
    .SYNOPSIS
    Get a list of active or expired Pushes for an authenticated user

    .DESCRIPTION
    Retrieves a list of Pushes - active or expired - for an authenticated user.
    Active and Expired are different endpoints, so to get both you'll need to make
    two calls.

    .INPUTS
    [string] 'Active' or 'Expired'

    .OUTPUTS
    [PasswordPush[]] Array of pushes with data
    [string] raw response body from API call

    .EXAMPLE
    Get-Dashboard

    .EXAMPLE
    Get-Dashboard Active

    .EXAMPLE
    Get-Dashboard -Dashboard Expired

    .EXAMPLE
    Get-Dashboard -Raw
    [{"expire_after_days":1,"expire_after_views":5,"expired":false,"url_token":"xm3q7czvtdpmyg","created_at":"2022-11-19T18:10:42.055Z","updated_at":"2022-11-19T18:10:42.055Z","deleted":false,"deletable_by_viewer":true,"retrieval_step":false,"expired_on":null,"note":null,"days_remaining":1,"views_remaining":3}]

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Dashboard.md

    .LINK
    https://pwpush.com/api/1.0/dashboard.en.html

    .LINK
    Get-PushAuditLog

    .NOTES
    TODO update Invoke-Webrequest flow and error-handling to match other functions
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope = 'Function', Justification = 'Global variables are used for module session helpers.')]
    [CmdletBinding()]
    [OutputType([PasswordPush[]],[string])]
    param(
        # URL Token from a secret
        [parameter(Position=0)]
        [ValidateSet('Active','Expired')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Dashboard = 'Active',

        # Return content of API call directly
        [Parameter()]
        [switch]
        $Raw
    )
    if (-not $Script:PPPHeaders) { Write-Error 'Dashboard access requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
    try {
        $uri = "$Script:PPPBaseUrl/d/"
        if ($Dashboard -eq 'Active') { $uri += 'active.json' }
        elseif ($Dashboard -eq 'Expired') { $uri += 'expired.json' }
        Write-Debug "Requesting $uri"
        $response = Invoke-WebRequest -Uri $uri -Method Get -Headers $Script:PPPHeaders -ErrorAction Stop
        if ($Raw) { return $response.Content }
        else {
            return $response.Content | ConvertTo-PasswordPush
        }
    } catch {
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
            Write-Debug -Message 'Response object set to global variable $PPPLastError'
        }
        throw # Re-throw the error
    }
}