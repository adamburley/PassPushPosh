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

    .PARAMETER URLToken
    URL Token for the secret

    .PARAMETER PushObject
    PasswordPush object

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
function Remove-Push {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Token')]
    [OutputType([PasswordPush], [bool])]
    param(
        [parameter(ValueFromPipeline, ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        [string]
        $URLToken,

        [Parameter(ValueFromPipeline, ParameterSetName = 'Object')]
        [PasswordPush]
        $PushObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Object') {
            Write-Debug -Message "Remove-Push was passed a PasswordPush object with URLToken: [$($PushObject.URLToken)]"
            if (-not $PushObject.IsDeletableByViewer -and -not $Script:PPPHeaders) {
                #Pre-qualify if this will succeed
                Write-Warning -Message 'Unable to remove Push. Push is not marked as deletable by viewer and you are not authenticated.'
                continue
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
        if ($PSCmdlet.ShouldProcess('Delete', "Push with token [$URLToken]")) {
            Invoke-PasswordPusherAPI -Endpoint "p/$URLToken.json" -Method 'Delete' | ConvertTo-PasswordPush
        }
    }
}