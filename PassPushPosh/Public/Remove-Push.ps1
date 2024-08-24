﻿function Remove-Push {
    <#
    .SYNOPSIS
    Remove a Push

    .DESCRIPTION
    Remove (invalidate) an active push. Requires the Push be either set as
    deletable by viewer, or that you are authenticated as the creator of the
    Push.

    If you have authorization to delete a push (deletable by viewer TRUE or
    you are the Push owner) the endpoint will always return 200 OK with a Push
    object, regardless if the Push was previously deleted or expired.

    If the Push URL Token is invalid OR you are not authorized to delete the
    Push, the endpoint returns 404 and this function returns $false

    .INPUTS
    [string] URL Token
    [PasswordPush] representing the Push to remove

    .OUTPUTS
    [bool] True on success, otherwise False

    .EXAMPLE
    Remove-Push -URLToken bwzehzem_xu-

    .EXAMPLE
    Remove-Push -URLToken

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Remove-Push.md

    .LINK
    https://pwpush.com/api/1.0/passwords/destroy.en.html

    .NOTES
    TODO testing and debugging
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Token')]
    [OutputType([PasswordPush], [bool])]
    param(
        # URL Token for the secret
        [parameter(ValueFromPipeline, ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        [string]
        $URLToken,

        # PasswordPush object
        [Parameter(ValueFromPipeline, ParameterSetName = 'Object')]
        [PasswordPush]
        $PushObject
    )
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Object') {
                Write-Debug -Message "Remove-Push was passed a PasswordPush object with URLToken: [$($PushObject.URLToken)]"
                if (-not $PushObject.IsDeletableByViewer -and -not $Script:PPPHeaders) {
                    #Pre-qualify if this will succeed
                    Write-Warning -Message 'Unable to remove Push. Push is not marked as deletable by viewer and you are not authenticated.'
                    return $false
                }
                if ($PushObject.IsDeletableByViewer) {
                    Write-Verbose "Push is flagged as deletable by viewer, should be deletable."
                }
                else { Write-Verbose "In an authenticated API session. Push will be deletable if it was created by authenticated user." }
                $URLToken = $PushObject.URLToken
            }
            else {
                Write-Debug -Message "Remove-Push was passed a URLToken: [$URLToken]"
            }
            Write-Verbose -Message "Push with URL Token [$URLToken] will be deleted if 'Deletable by viewer' was enabled or you are the creator of the push and are authenticated."
            $iwrSplat = @{
                'Method'      = 'Delete'
                'ContentType' = 'application/json'
                'Uri'         = "$Script:PPPBaseUrl/p/$URLToken.json"
                'UserAgent'   = $Script:PPPUserAgent
            }
            if ($Script:PPPHeaders) { $iwrSplat['Headers'] = $Script:PPPHeaders }
            Write-Verbose "Sending HTTP request: $($iwrSplat | Out-String)"
            if ($PSCmdlet.ShouldProcess('Delete', "Push with token [$URLToken]")) {
                $response = Invoke-PasswordPusherAPI -Endpoint "p/$URLToken.json" -Method 'Delete'
                if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                    Set-Variable -Scope Global -Name PPPLastCall -Value $response
                    Write-Debug 'Response to Invoke-WebRequest set to PPPLastCall Global variable'
                }
                $response.Content | ConvertTo-PasswordPush
            }
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 404) {
                Write-Warning "Failed to delete Push. This can indicate an invalid URL Token, that the password was not marked deletable, or that you are not the owner."
                return $false
            }
            else {
                Write-Verbose "An exception was caught: $($_.Exception.Message)"
                if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                    Set-Variable -Scope Global -Name PPPLastError -Value $_
                    Write-Debug -Message 'Response object set to global variable $PPPLastError'
                }
                $_
            }
        }
    }
}