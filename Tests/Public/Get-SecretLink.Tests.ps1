BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Get-SecretLink" {
    It "URLToken parameter is mandatory" {
        # https://github.com/PowerShell/PowerShell/issues/2408#issuecomment-251140889
        ((Get-Command Get-SecretLink).Parameters['URLToken'].Attributes | Where-Object { $_ -is [parameter] }).Mandatory | Should -Be $true
    }
    It "requires a URL token" {
        { Get-SecretLink -URLToken $null } | Should -Throw
    }
    It "Should return a secret link" {
        $push = New-Push -Payload 'I am a payload!'
        $secretLink = Get-SecretLink -URLToken $push.URLToken
        $secretLink | Should -Be $push.LinkDirect
    }
}