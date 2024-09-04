BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Initialize-PassPushPosh" {
    It "Should create a new session" {
        Initialize-PassPushPosh
        InModuleScope -ModuleName PassPushPosh {
            $Script:PPPBaseURL | Should -Be "https://pwpush.com"
        }
    }
    It "Should create a new session with a custom base URL" {
        Initialize-PassPushPosh -BaseUrl "https://example.com"
        InModuleScope -ModuleName PassPushPosh {
            $Script:PPPBaseURL | Should -Be "https://example.com"
        }
    }
    It "Should create a new session with authentication" {
        Initialize-PassPushPosh -EmailAddress "test@example.com" -ApiKey "Tree-Ents"
        InModuleScope -ModuleName PassPushPosh {
            $Script:PPPHeaders.'X-User-Email' | Should -Be "test@example.com"
            $Script:PPPHeaders.'X-User-Token' | Should -Be "Tree-Ents"
        }
    }
    It "Should require a valid email address" {
        { Initialize-PassPushPosh -EmailAddress "test" -ApiKey "Tree-Ents" } | Should -Throw
    }
    It "Should create a user agent with a consistent result" {
        Initialize-PassPushPosh
        InModuleScope -ModuleName PassPushPosh {
            $Global:Ua1 = $Script:PPPUserAgent
        }
        Initialize-PassPushPosh
        InModuleScope -ModuleName PassPushPosh {
            $Global:Ua2 = $Script:PPPUserAgent
        }
        $Global:Ua1 | Should -Be $Global:Ua2
    }
    It "Default user-agent should contain the module version" {
        Initialize-PassPushPosh
        $Global:semVer = (Get-Module PassPushPosh).Version.ToString()
        InModuleScope -ModuleName PassPushPosh {
            $Script:PPPUserAgent | Should -Match "PassPushPosh/$Global:semVer"
        }
    }
    It "Should support a custom user-agent" {
        Initialize-PassPushPosh -UserAgent "Test/1.0"
        InModuleScope -ModuleName PassPushPosh {
            $Script:PPPUserAgent | Should -Be "Test/1.0"
        }
    }
}