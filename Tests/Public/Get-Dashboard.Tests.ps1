BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Get-Dashboard" {
    BeforeAll {
        Initialize-PassPushPosh -EmailAddress $env:pwpEmail -ApiKey $env:pwpKey -Force
    }
    It "retrieves active pushes" {
        $testPush = New-Push -Payload 'This is a test payload for Get-Dashboard'
        $activePushes = Get-Dashboard -Dashboard Active
        $activePushes | Should -Not -BeNullOrEmpty
        $activePushes.UrlToken | Should -Contain $testPush.UrlToken
    }
    It "retrieves active pushes by default" {
        $defaultPushes = Get-Dashboard
        $defaultPushes.Count | Should -BeGreaterThan 1
        $defaultPushes[0].IsExpired | Should -Be $false
        $defaultPushes[0].IsDeleted | Should -Be $false
    }
    It "retrieves expired pushes" {
        $expiredPushes = Get-Dashboard -Dashboard Expired
        $expiredPushes | Should -Not -BeNullOrEmpty
        $expiredPushes.Count | Should -BeGreaterThan 1
        $expiredPushes[0].IsExpired -or $expiredPushes[0].IsDeleted | Should -Be $true
    }
    It "requires authentication" {
        Initialize-PassPushPosh -Force
        { Get-Dashboard } | Should -Throw
    }
}