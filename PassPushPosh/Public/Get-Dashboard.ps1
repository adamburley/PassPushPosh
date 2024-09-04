<#
    .SYNOPSIS
    Get a list of active or expired Pushes for an authenticated user

    .DESCRIPTION
    Retrieves a list of Pushes - active or expired - for an authenticated user.
    Active and Expired are different endpoints, so to get both you'll need to make
    two calls.

    .PARAMETER Dashboard
    The type of dashboard to retrieve. Active or Expired.

    .INPUTS
    [string] 'Active' or 'Expired'

    .OUTPUTS
    [PasswordPush[]] Array of pushes with data

    .EXAMPLE
    Get-Dashboard

    .EXAMPLE
    Get-Dashboard Active

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Dashboard.md

    .LINK
    https://pwpush.com/api/1.0/passwords/active.en.html

    .LINK
    Get-PushAuditLog

    #>
function Get-Dashboard {
    [CmdletBinding()]
    [OutputType([PasswordPush[]])]
    param(
        [parameter(Position = 0)]
        [ValidateSet('Active', 'Expired')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Dashboard = 'Active'
    )
    process {
        if (-not $Script:PPPHeaders) { Write-Error 'Dashboard access requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
        $uri = "p/$($Dashboard -eq 'Active' ? 'active.json' : 'expired.json')"
        Invoke-PasswordPusherAPI -Endpoint $uri -Method Get | ConvertTo-PasswordPush
    }
}