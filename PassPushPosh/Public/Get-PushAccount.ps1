<#
    .SYNOPSIS
    Get a list of accounts for an authenticated user

    .DESCRIPTION
    Retrieves a list of accounts for an authenticated user.

    .LINK
    Get-PushAuditLog

    #>
function Get-PushAccount {
    [CmdletBinding()]
    [OutputType([PasswordPush[]])]
    param()
    process {
        if (-not $Script:PPPHeaders) { Write-Error 'Dashboard access requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
        $uri = 'api/v1/accounts'
        Invoke-PasswordPusherAPI -Endpoint $uri -Method Get
    }
}