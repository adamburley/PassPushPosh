BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Remove-Push" {
    Context "deletable by viewer" {
        BeforeAll {
            Initialize-PassPushPosh -Force
            Mock -ModuleName PassPushPosh -CommandName Write-Error { }
        }
        It "should remove a push marked deletable by viewer" {
            $payload = 'This is a test payload'
            $push = New-Push -Payload $payload -DeletableByViewer
            $push.IsDeletableByViewer | Should -Be $true
            $removed = Remove-Push -URLToken $push.UrlToken
            $removed.IsDeleted | Should -Be $true
        }
        It "should error when trying to delete a push not marked deletable by viewer" {
            $payload = 'This is a test payload'
            $push2 = New-Push -Payload $payload
            $push2.IsDeletableByViewer | Should -Be $false
            Remove-Push -URLToken $push2.UrlToken | Should -Be $false
            Should -Invoke Write-Error -ModuleName PassPushPosh -ParameterFilter { $Message -ieq "Unable to remove Push with token [$($push2.UrlToken)]. Error: That push is not deletable by viewers." }
        }
    }
}