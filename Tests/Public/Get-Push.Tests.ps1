BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Get-Push" {
    It "retrieves a push with the correct payload" {
        $payload = 'This is a test payload for Get-Push'
        $push = New-Push -Payload $payload
        $fetchedPush = Get-Push -URLToken $push.UrlToken
        $fetchedPush.Payload | Should -Be $payload
    }
    It "retrieves information on an expired push" {
        $expiredPushToken = '-umtrv6wevyt'
        $fetchedPush = Get-Push -URLToken $expiredPushToken
        $fetchedPush.UrlToken | Should -Be $expiredPushToken
        $fetchedPush.IsExpired | Should -Be $true
        $fetchedPush.DaysRemaining | Should -Be 0
    }
    It "returns an error on an invalid token" {
        Mock -ModuleName PassPushPosh -CommandName Write-Error
        Get-Push -URLToken 'invalid' | Should -Be $null
        Should -Invoke Write-Error -ModuleName PassPushPosh -ParameterFilter { $Message -ieq "Push not found. Check the token you provided. Tokens are case-sensitive." }
    }
}