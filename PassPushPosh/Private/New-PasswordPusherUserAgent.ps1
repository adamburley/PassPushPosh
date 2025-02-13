function New-PasswordPusherUserAgent {
    [CmdletBinding()]
    param()
    $osVersion = [System.Environment]::OSVersion
    $userAtDomain = '{0}@{1}' -f [System.Environment]::UserName, [System.Environment]::UserDomainName
    $uAD64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($userAtDomain))
    Write-Debug "$userAtDomain transformed to $uAD64. First 20 characters $($uAD64.Substring(0,20))"
        
    Write-Verbose "Generated user agent: $UserAgent"
    # Version tag is replaced by the semantic version number at build time. See PassPushPosh/issues/11 for context
    "PassPushPosh/{{semversion}} $osVersion/$($uAD64.Substring(0,20))"
}