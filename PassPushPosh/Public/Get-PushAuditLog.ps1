function Get-PushAuditLog {
    <#
    .SYNOPSIS
    Get the view log of an authenticated Push

    .DESCRIPTION
    Retrieves the view log of a Push created under an authenticated session.
    Returns an array of custom objects with view data. If the query is
    successful but there are no results, it returns an empty array.
    If there's an error, a single object is returned with information.
    See "handling errors" under NOTES

    .INPUTS
    [string]

    .OUTPUTS
    [PsCustomObject[]] Array of entries.
    [PsCustomObject] If there's an error in the call, it will be returned an object with a property
    named 'error'.  The value of that member will contain more information

    .EXAMPLE
    Get-PushAuditLog -URLToken 'mytokenfromapush'
    ip         : 75.202.43.56,102.70.135.200
    user_agent : Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101;
    en-US) PowerShell/7.2.7
    referrer   :
    successful : True
    created_at : 11/19/2022 6:32:42 PM
    updated_at : 11/19/2022 6:32:42 PM
    kind       : 0

    .EXAMPLE
    # If there are no views, an empty array is returned
    Get-PushAuditLog -URLToken 'mytokenthatsneverbeenseen'

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-PushAuditLog.md

    .LINK
    https://pwpush.com/api/1.0/passwords/audit.en.html

    .LINK
    Get-Dashboard

    .NOTES
    Handling Errors:
    The API returns different HTTP status codes and results depending where the
    call fails.

    |  HTTP RESPONSE   |            Error Reason         |                Response Body                 |                                    Sample Object Returned                                  |                                                             Note                                                           |
    |------------------|---------------------------------|----------------------------------------------|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
    | 401 UNAUTHORIZED | Invalid API key or email        | None                                         | @{ 'Error'= 'Authentication error. Verify email address and API key.'; 'ErrorCode'= 401 }  |                                                                                                                            |
    | 200 OK           | Push created by another account | {"error":"That push doesn't belong to you."} | @{ 'Error'= "That Push doesn't belong to you"; 'ErrorCode'= 403 }                          | Function transforms error code to 403 to allow easier response management                                                  |
    | 404 NOT FOUND    | Invalid URL token               | None                                         | @{ 'Error'= 'Invalid token. Verify your Push URL token is correct.'; 'ErrorCode'= 404 }    | This is different than the response to a delete Push query - in this case it will only return 404 if the token is invalid. |

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Scope = 'Function', Justification = 'Global variables are used for module session helpers.')]
    [CmdletBinding()]
    [OutputType([PSCustomObject[]],[string])]
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
        if (-not $Script:PPPHeaders) { Write-Error 'Retrieving audit logs requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying.' -ErrorAction Stop -Category AuthenticationError }
    }
    process {
        try {
            $uri = "$Script:PPPBaseUrl/p/$URLToken/audit.json"
            Write-Debug 'Requesting $uri'
            $response = Invoke-WebRequest -Uri $uri -Method Get -Headers $Script:PPPHeaders -ErrorAction Stop
            if ([int]$response.StatusCode -eq 200 -and $response.Content -ieq "{`"error`":`"That push doesn't belong to you.`"}") {
                $result = [PSCustomObject]@{ 'Error' = "That Push doesn't belong to you"; 'ErrorCode' = 403 }
                Write-Warning $result.Error
                return $result
            }
            if ($Raw) { return $response.Content } else { return $response.Content | ConvertFrom-Json }
        }
        catch {
            Write-Verbose "An exception was caught: $($_.Exception.Message)"
            if ([int]$_.Exception.Response.StatusCode -eq 401) { # Could be optimized
                $result = [PSCustomObject]@{ 'Error' = 'Authentication error. Verify email address and API key.'; 'ErrorCode' = 401 }
                Write-Warning $result.Error
                return $result
            } elseif ([int]$_.Exception.Response.StatusCode -eq 404) {
                $result = [PSCustomObject]@{ 'Error' = 'Invalid token. Verify your Push URL token is correct.'; 'ErrorCode' = 404 }
                Write-Warning $result.Error
                return $result
            }
            elseif ($DebugPreference -eq [System.Management.Automation.ActionPreference]::Continue) {
                Set-Variable -Scope Global -Name 'PPPLastError' -Value $_
                Write-Debug -Message 'Response object set to global variable $PPPLastError'
                return [PSCustomObject]@{
                    'Error'        = $_.Exception.Message
                    'ErrorCode'    = [int]$_.Exception.Response.StatusCode
                    'ErrorMessage' = $_.Exception.Response.ReasonPhrase
                }
            }
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