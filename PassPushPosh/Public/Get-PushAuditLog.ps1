function Get-PushAuditLog {
    <#
    .SYNOPSIS
    Get the view log of an authenticated Push
    
    .DESCRIPTION
    Retrieves the view log of a Push created under an authenticated session.
    
    .INPUTS
    [string] 
    
    .OUTPUTS
    [PsCustomObject[]] Array of entries.
    [PsCustomObject] If there's an error in the call, it will be returned an object with a property
    named 'error'.  The value of that member will contain more information

    .EXAMPLE
    Get-PushAuditLog -URLToken 'mytokenfromapush'
    
    .NOTES
    General notes
    #>
  [CmdletBinding()]
  param(
    # URL Token from a secret
    [parameter(ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string]
    $URLToken,

    # Return content of API call directly
    [Parameter()]
    [switch]
    $Raw
  )
  begin {
    if (-not $Global:PPPHeaders) { Write-Error 'Retrieving audit logs requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
  }
  process {
    try { 
        $uri = "$Script:PPPBaseUrl/p/$URLToken/audit.json"
        Write-Debug 'Requesting $uri'
        Invoke-WebRequest -Uri $uri -Method Get -Headers $Global:PPPHeaders -ErrorAction Stop
    } catch {
        Write-Verbose "An exception was caught: $($_.Exception.Message)"
        if ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
            Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
            Write-Debug -Message 'Response object set to global variable $PPPLastError'
            return @{
                'Error'        = $_.Exception.Message
                'ErrorCode'    = [int]$_.Exception.Response.StatusCode
                'ErrorMessage' = $_.Exception.Response.ReasonPhrase
            }
        }
        return 
    }    
  }
}

# Invalid API key / email - 401
# Invalid URL Token - 404
# Valid token but not mine - 200, content =  {"error":"That push doesn't belong to you."}
# Success but no views - 200, content = : {"views":[]}
# Success with view history {"views":[{"ip":"75.118.137.58,172.70.135.200","user_agent":"Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101; en-US) PowerShell/7.2.7","referrer":"","successful":true,"created_at":"2022-11-19T18:32:42.277Z","updated_at":"2022-11-19T18:32:42.277Z","kind":0}]}
# Content.Views
<#
ip         : 75.118.137.58,172.70.135.200
user_agent : Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101; 
             en-US) PowerShell/7.2.7
referrer   : 
successful : True
created_at : 11/19/2022 6:32:42 PM
updated_at : 11/19/2022 6:32:42 PM
kind       : 0
#>