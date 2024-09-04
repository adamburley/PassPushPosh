BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Get-PushAuditLog" {
    BeforeAll {
    }
    It "retrieves audit logs" {
        Initialize-PassPushPosh -EmailAddress $env:pwpEmail -ApiKey $env:pwpKey -Force
        $testPush = Get-Dashboard -Dashboard Active | Select-Object -First 1
        $auditLogs = Get-PushAuditLog -URLToken $testPush.UrlToken
        $auditLogs | Should -Not -BeNullOrEmpty
    }
    It "requires a token owned by the authenticated user" {
        Mock -ModuleName PassPushPosh -CommandName Write-Error { }
        Initialize-PassPushPosh -Force
        $anonymousPush = New-Push -Payload 'this is anonymous'
        Initialize-PassPushPosh -EmailAddress $env:pwpEmail -ApiKey $env:pwpKey -Force
        Get-PushAuditLog -URLToken $anonymousPush.UrlToken
        Should -Invoke Write-Error -ModuleName PassPushPosh -ParameterFilter { $Message -ieq "That push doesn't belong to you." }
    }
    It "requires a valid token" {
        Mock -ModuleName PassPushPosh -CommandName Write-Error { }
        Initialize-PassPushPosh -EmailAddress $env:pwpEmail -ApiKey $env:pwpKey -Force
        Get-PushAuditLog -URLToken 'invalidtoken'
        Should -Invoke Write-Error -ModuleName PassPushPosh -ParameterFilter { $Message -ieq "Push not found. Check the token you provided. Tokens are case-sensitive." }
    }
    It "requires a url token" {
        { Get-PushAuditLog -URLToken $null } | Should -Throw "Cannot bind argument to parameter 'URLToken' because it is an empty string."
    }
    It "requires authentication" {
        Initialize-PassPushPosh -Force
        { Get-PushAuditLog -URLToken 'test' } | Should -Throw "Retrieving audit logs requires authentication. Run Initialize-PassPushPosh and pass your email address and API key before retrying."
    }
}