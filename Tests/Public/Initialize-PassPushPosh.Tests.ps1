BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Initialize-PassPushPosh" {
    Context "General tests" {
        It "Should create a new session with the default URL" {
            Initialize-PassPushPosh -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPBaseURL | Should -Be "https://pwpush.com"
            }
        }
        It "Should create a new session with a custom base URL" {
            Initialize-PassPushPosh -BaseUrl "https://example.com" -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPBaseURL | Should -Be "https://example.com"
            }
        }
        It "Should create a user agent with a consistent result" {
            Initialize-PassPushPosh -Force
            InModuleScope -ModuleName PassPushPosh {
                $Global:Ua1 = $Script:PPPUserAgent
            }
            Initialize-PassPushPosh -Force
            InModuleScope -ModuleName PassPushPosh {
                $Global:Ua2 = $Script:PPPUserAgent
            }
            $Global:Ua1 | Should -Be $Global:Ua2
        }
        It "Default user-agent should contain the module version" {
            Initialize-PassPushPosh -Force
            $Global:semVer = (Get-Module PassPushPosh).Version.ToString()
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPUserAgent | Should -Match "PassPushPosh/$Global:semVer"
            }
        }
        It "Should support a custom user-agent" {
            Initialize-PassPushPosh -UserAgent "Test/1.0" -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPUserAgent | Should -Be "Test/1.0"
            }
        }
    }
    Context 'Authentication - Bearer' {
        It "Should create a new session with authentication" {
            Initialize-PassPushPosh -Bearer "iamaverycoolapikey" -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPHeaders.Authorization | Should -Be "Bearer iamaverycoolapikey"
            }
        }
        It "Should create an authenticated session with a custom URL" {
            Initialize-PassPushPosh -Bearer "iamaverycoolapikey" -BaseUrl 'https://pwp.example.com' -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPHeaders.Authorization | Should -Be "Bearer iamaverycoolapikey"
                $Script:PPPBaseUrl | Should -Be "https://pwp.example.com"
            }
        }
    }
    Context 'Authentication - Legacy' {
        It "Should use legacy auth when specified" {
            Initialize-PassPushPosh -EmailAddress "test@example.com" -ApiKey "Tree-Ents" -UseLegacyAuthentication -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPHeaders.'X-User-Email' | Should -Be "test@example.com"
                $Script:PPPHeaders.'X-User-Token' | Should -Be "Tree-Ents"
            }
        }
        It "Should require a valid email address" {
            { Initialize-PassPushPosh -EmailAddress "test" -ApiKey "Tree-Ents" -Force } | Should -Throw
        }
        It "Should autodetect Bearer support if not specified" {
            Initialize-PassPushPosh -EmailAddress "test@example.com" -ApiKey "iamaverycoolapikey" -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPHeaders.Authorization | Should -Be "Bearer iamaverycoolapikey"
            }
        }
        It "Should autodetect and fall back to legacy authentication with a warning to the user" {
            Mock -ModuleName .\PassPushPosh -CommandName Write-Warning { }
            Initialize-PassPushPosh -EmailAddress "test@example.com" -ApiKey "iamaverycoolapikey" -BaseUrl 'https://example.com' -Force
            InModuleScope -ModuleName PassPushPosh {
                $Script:PPPHeaders.'X-User-Email' | Should -Be "test@example.com"
                $Script:PPPHeaders.'X-User-Token' | Should -Be "iamaverycoolapikey"
            }
            Should -ModuleName PassPushPosh -Invoke Write-Warning -Times 5
        }
    }
}