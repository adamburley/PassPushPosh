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

    .EXAMPLE
    Get-Dashboard

    .EXAMPLE
    Get-Dashboard Active

    .EXAMPLE
    Get-Dashboard -Dashboard Expired

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Dashboard.md

    .LINK
    https://pwpush.com/api/1.0/dashboard.en.html

    .LINK
    Get-PushAuditLog

    .NOTES
    TODO update Invoke-Webrequest flow and error-handling to match other functions
    #>
    [CmdletBinding()]
    [OutputType([PasswordPush[]])]
    param(
        # URL Token from a secret
        [parameter(Position = 0)]
        [ValidateSet('Active', 'Expired')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Dashboard = 'Active'
    )
    if (-not $Script:PPPHeaders) { Write-Error 'Dashboard access requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
    try {
        $uri = "d/"
        if ($Dashboard -eq 'Active') { $uri += 'active.json' }
        elseif ($Dashboard -eq 'Expired') { $uri += 'expired.json' }
        Write-Debug "Requesting $uri"
        $response.Content | ConvertTo-PasswordPush
    }
    catch {
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
            Write-Debug -Message 'Response object set to global variable $PPPLastError'
        }
        throw # Re-throw the error
    }
}