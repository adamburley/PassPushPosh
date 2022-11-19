function Remove-Push {
  [CmdletBinding(DefaultParameterSetName='Token')]
  [OutputType([PasswordPush],[string],[bool])]
  param(
    # URL Token string from a Push
    [parameter(ValueFromPipeline,ParameterSetName='Token')]
    [string]
    $URLToken,

    # PasswordPush object
    [Parameter(ValueFromPipeline,ParameterSetName='Object')]
    [PasswordPush]
    $PushObject,

    # Return raw result of API call
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
        $response = Invoke-WebRequest -Uri "$Script:PPPBaseUrl/p/$URLToken.json" -Method Delete
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
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Failed to delete Push. This can indicate an invalid URL Token, that the password was not marked deletable, or that you are not the owner."
            return $false
        } else {
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
}