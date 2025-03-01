BeforeDiscovery {
    $targets = Get-Content -Path $PSScriptRoot\..\..\testdata.json | ConvertFrom-Json -AsHashtable
    Write-host "Test Targets:" $targets.Keys -ForegroundColor Cyan
}
BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}
Describe "Get-Push" {
    Context "<Type>" -ForEach ($targets.HostedFree, $targets.OSSCurrent) {
        BeforeAll {
            Initialize-PassPushPosh -Force -BaseUrl $Url
        }
        It "retrieves a push with the correct payload" {
            $payload = 'This is a test payload for Get-Push'
            $push = New-Push -Payload $payload
            $fetchedPush = Get-Push -URLToken $push.UrlToken
            $fetchedPush.Payload | Should -Be $payload
        }
        It "correctly formats output links depending on RetrievalStep true" {
            $push = New-Push -Payload "test" -RetrievalStep:$true
            $getPush = Get-Push -URLToken $push.UrlToken
            $getPush.RetrievalStep | Should -Be $true
            $getPush.LinkDirect | Should -Be "$($Url)/p/$($push.UrlToken)"
            $getPush.LinkRetrievalStep | Should -Be "$($Url)/p/$($push.UrlToken)/r"
            $getPush.Link | Should -Be $getPush.LinkRetrievalStep
        }
        It "correctly formats output links depending on RetrievalStep false" {
            $push = New-Push -Payload "test" -RetrievalStep:$false
            $getPush = Get-Push -URLToken $push.UrlToken
            $getPush.RetrievalStep | Should -Be $false
            $getPush.LinkDirect | Should -Be "$($Url)/p/$($push.UrlToken)"
            $getPush.LinkRetrievalStep | Should -Be "$($Url)/p/$($push.UrlToken)/r"
            $getPush.Link | Should -Be $getPush.LinkDirect
        }
        <#
        It "retrieves information on an expired push" {
            $expiredPushToken = '-umtrv6wevyt'
            $fetchedPush = Get-Push -URLToken $expiredPushToken
            $fetchedPush.UrlToken | Should -Be $expiredPushToken
            $fetchedPush.IsExpired | Should -Be $true
            $fetchedPush.DaysRemaining | Should -Be 0
        }
            #>
        It "returns an error on an invalid token" {
            Mock -ModuleName PassPushPosh -CommandName Write-Error
            Get-Push -URLToken 'invalid' | Should -Be $null
            Should -Invoke Write-Error -ModuleName PassPushPosh -ParameterFilter { $Message -ieq "Push not found. Check the token you provided. Tokens are case-sensitive." }
        }
    }
}