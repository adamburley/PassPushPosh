function Remove-Push {
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
    Remove-Push -URLToken -Raw

    {"expired":true,"deleted":true,"expired_on":"2022-11-21T13:23:45.341Z","expire_after_days":1,"expire_after_views":4,"url_token":"bwzehzem_xu-","created_at":"2022-11-21T13:20:08.635Z","updated_at":"2022-11-21T13:23:45.342Z","deletable_by_viewer":true,"retrieval_step":false,"days_remaining":1,"views_remaining":4}
    
    .LINK
    https://pwpush.com/api/1.0/passwords/destroy.en.html

    .NOTES
    TODO testing and debugging
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars','',Scope='Function',Justification='Global variables are used for module session helpers.')]
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='Token')]
    [OutputType([PasswordPush],[string],[bool])]
    param(
        # URL Token for the secret
        [parameter(ValueFromPipeline,ParameterSetName='Token')]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        [string]
        $URLToken,

        # PasswordPush object
        [Parameter(ValueFromPipeline,ParameterSetName='Object')]
        [PasswordPush]
        $PushObject,

        # Return the raw response body from the API call
        [parameter()]
        [switch]
        $Raw
    )
    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Object') {
                Write-Debug -Message "Remove-Push was passed a PasswordPush object with URLToken: [$($PushObject.URLToken)]"
                if (-not $PushObject.IsDeletableByViewer -and -not $Global.PPPHeaders) { #Pre-qualify if this will succeed
                    Write-Warning -Message 'Unable to remove Push. Push is not marked as deletable by viewer and you are not authenticated.'
                    return $false
                }
                if ($PushObject.IsDeletableByViewer) { 
                    Write-Verbose "Push is flagged as deletable by viewer, should be deletable."
                } else { Write-Verbose "In an authenticated API session. Push will be deletable if it was created by authenticated user." }
                $URLToken = $PushObject.URLToken
            } else {
                Write-Debug -Message "Remove-Push was passed a URLToken: [$URLToken]"
            }
            Write-Verbose -Message "Push with URL Token [$URLToken] will be deleted if 'Deletable by viewer' was enabled or you are the creator of the push and are authenticated."
            $iwrSplat = @{
                'Method' = 'Delete'
                'ContentType' = 'application/json'
                'Uri' = "$Global:PPPBaseUrl/p/$URLToken.json"
                'UserAgent' = $Global:PPPUserAgent
            }
            if ($Global:PPPHeaders) { $iwrSplat['Headers'] = $Global:PPPHeaders }
            Write-Verbose "Sending HTTP request: $($iwrSplat | Out-String)"
            if ($PSCmdlet.ShouldProcess('Delete',"Push with token [$URLToken]")) {
                $response = Invoke-WebRequest @iwrSplat
                if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                    Set-Variable -Scope Global -Name PPPLastCall -Value $response
                    Write-Debug 'Response to Invoke-WebRequest set to PPPLastCall Global variable'
                }
                if ($Raw) { 
                    Write-Debug "Returning raw object: $($response.Content)"
                    return $response.Content
                }
                return $response.Content | ConvertTo-PasswordPush
            }
        } catch { 
            if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Failed to delete Push. This can indicate an invalid URL Token, that the password was not marked deletable, or that you are not the owner."
            return $false
            } else {
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