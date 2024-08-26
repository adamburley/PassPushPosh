Function Initialize-DevEnvironment {
    [CmdletBinding()]
    Param (
        [string]$ModuleName = ${Global:Dev-ModuleName},
        [scriptblock]$InitializeCommand = ${Global:Dev-InitializeCommand}
    )
    # If developing for an Azure Function app with environment variables, import.
    if (Test-Path '.\local.settings.json') {
        $environmentVariables = Get-Content -Path '.\local.settings.json' | ConvertFrom-Json -depth 10 | Select-Object -expandproperty Values
        $environmentVariables | Get-Member -MemberType NoteProperty | Foreach-Object {
            $name = $_.Name
            New-Item -Path "Env:\$name" -Value $environmentVariables.$name -Force
        }
    }
    
    Write-Host "`nRebuilding $ModuleName..." -ForegroundColor Yellow
    Build-Module -SourcePath ".\$ModuleName\$ModuleName.psd1" -OutputDirectory '..\Output' -UnversionedOutputDirectory
    
    Write-Host "Importing module..." -ForegroundColor Yellow
    Import-Module -Name ".\Output\$ModuleName" -Force -Global
    
    # Module-specific initializations
    if ($InitializeCommand) {
        $InitializeCommand.Invoke()
    }
}
Function Test-SingleFunction {
    param( 
        $Function,
        $Scope = 'Public'
    )

    # Create a Pester configuration object using `New-PesterConfiguration`
    $config = New-PesterConfiguration

    # Set the test path to specify where your tests are located. In this example, we set the path to the current directory. Pester will look into all subdirectories.
    $config.Run.Path = ".\Tests\$Scope\$Function.Tests.ps1"

    # Code coveragte 
    # $config.CodeCoverage.Enabled = $true
    # $config.CodeCoverage.Path = ".\AxcientAPI\$Scope\$Function.ps1"

    $config.Output.Verbosity = 'Detailed'

    # Run Pester tests using the configuration you've created
    Invoke-Pester -Configuration $config
}