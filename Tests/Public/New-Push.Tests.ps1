BeforeDiscovery {
    $targets = Get-Content -Path $PSScriptRoot\..\..\testdata.json | ConvertFrom-Json -AsHashtable
    Write-host "Test Targets:" $targets.Keys -ForegroundColor Cyan
}
BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "New-Push" {
    Context "<Type> Anonymous pushes" -ForEach ($targets.HostedFree, $targets.OSSCurrent) {
        BeforeAll {
            Initialize-PassPushPosh -Force -BaseUrl $Url
        }
        It "should create a new push and set the payload correctly" {
            $payload = 'This is a test payload'
            $push = New-Push -Payload $payload
            $push.GetType().Name | Should -Be 'PasswordPush' # -BeOfType [PasswordPush] raises an error
            $fetchedPush = Get-Push -URLToken $push.UrlToken
            $fetchedPush.Payload | Should -Be $payload
        }
        It "should set -ExpireAfterDays and -ExpireAfterViews properly" {
            $payload = 'This is a test payload'
            $expireAfterDays = 1
            $expireAfterViews = 12
            $push = New-Push -Payload $payload -ExpireAfterDays $expireAfterDays -ExpireAfterViews $expireAfterViews
            $push.ExpireAfterDays | Should -Be $expireAfterDays
            $push.ExpireAfterViews | Should -Be $expireAfterViews
        }
        It "should set -DeletableByViewer properly" {
            $payload = 'This is a test payload'
            $push = New-Push -Payload $payload -ExpireAfterDays 1 -DeletableByViewer
            $push.IsDeletableByViewer | Should -Be $true
        }
        It "should set -RetrievalStep properly" {
            $payload = 'This is a test payload'
            $push = New-Push -Payload $payload -ExpireAfterDays 1 -RetrievalStep
            $push.RetrievalStep | Should -Be $true
        }
        It "Should raise an error if -Note parameter is set" {
            $payload = 'This is a test payload'
            { New-Push -Payload $payload -Note 'This is a note' } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'Note'. Adding a note requires authentication."
        }
    }
    Context "<Type> Authenticated pushes" -ForEach ($targets.HostedProDomain, $targets.HostedFree, $targets.OSSCurrent) {
        BeforeAll {
            Initialize-PassPushPosh -Bearer $ApiKey -BaseUrl $Url -Force
        }
        It "sends a push with a note" {
            $Global:authpayload = 'This is a test payload'
            $Global:note = 'This is a note'
            $Global:authpush = New-Push -Payload $authpayload -Note $note
        }
        It "retrieves the push with the correct payload" {
            $returnedPush = Get-Push -URLToken $authpush.UrlToken
            $returnedPush.Payload | Should -Be $authpayload
        }
        It "sets the correct note" {
            $dash = Get-Dashboard -Dashboard Active
            $thisDash = $dash | Where-Object { $_.UrlToken -eq $authpush.UrlToken }
            $thisDash.Note | Should -Be $note
        }
    }
    Context "<Type> Account-based pushes" -ForEach ($targets.HostedProAccountId, $targets.HostedFreeAccountId) {
        BeforeAll {
            Initialize-PassPushPosh -Bearer $ApiKey -BaseUrl $Url -Force
        }
        It "Allows specifying account with an ID" {
            $push = New-Push -Payload 'test' -AccountId $AccountId
            $receivedPush = Get-Push -URLToken $push.UrlToken
            $push.AccountId | Should -Be $AccountId
            $receivedPush.AccountId | Should -Be $AccountId
        }
    }
}