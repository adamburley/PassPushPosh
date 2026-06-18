BeforeDiscovery {
    $targets = Get-Content -Path $PSScriptRoot\..\..\testdata.json | ConvertFrom-Json -AsHashtable
    Write-host "Test Targets:" $targets.Keys -ForegroundColor Cyan
}

BeforeAll {
    Import-Module $PSScriptRoot\..\..\Output\PassPushPosh -Force
}

Describe "Get-PushApiVersion" {
    Context "<Type> API Version" -ForEach ($targets.HostedFree, $targets.OSSCurrent, $targets.HostedProDomain) {
        BeforeAll {
            Initialize-PassPushPosh -Force -BaseUrl $Url
        }

        It "should return the API version" {
            $version = Get-PushApiVersion
            $version.GetType().Name | Should -Be 'PSCustomObject'
            $version.PSObject.Properties.Name | Should -Contain 'api_version'
        }
    }
}
