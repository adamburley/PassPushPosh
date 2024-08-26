# This script sets up the dev environment for this module.
# run .\dev\setup.ps1 with the prompt at the root of your repo

$minimumVersion = 7.0
$requiredModules = @(
    @{ Name = 'ModuleBuilder'; MinimumVersion = '3.1.0'}
    @{ Name = 'Pester'; MinimumVersion = '5.6.0' }
    @{ Name = 'PSScriptAnalyzer'; MinimumVersion = '1.22.0' }
    @{ Name = 'PowerShellGet'; MinimumVersion = '2.2.5' }
    @{ Name = 'Microsoft.PowerShell.PSResourceGet'; MinimumVersion = '1.0.5' }
    @{ Name = 'platyPS'; MinimumVersion = '0.14.0' }
)
$moduleName = 'PassPushPosh'
$initializeCommand = { Initialize-AxcientAPI -ApiKey ${env:AxcientApiKey-Prod} -ReturnErrors }
$rootPath = $PSScriptRoot | Split-Path -Parent

If ($PSVersionTable.PSVersion -lt $minimumVersion) {
    Write-Host "This module requires at least PowerShell $minimumVersion and is unlikely to work in this PowerShell instance." -ForegroundColor Red
}

$requiredModules | ForEach-Object {
    $module = Get-Module -Name $_.Name -ListAvailable
    if ($module -eq $null) {
        Write-Host "PowerShell Module $($_.Name) not found. Please install it." -ForegroundColor Red
    } elseif (($module.Version | Sort-Object -Descending | Select-Object -First 1) -lt $_.MinimumVersion) {
        Write-Host "PowerShell Module $($_.Name) version $($module.Version) is less than required version $($_.MinimumVersion). Please update it." -ForegroundColor Red
    }
}

# Import the development helper module and configure aliases
Import-Module "$rootPath\dev\devmodule.psm1" -Force

#Initialize-DevEnvironment -ModuleName $moduleName -InitializeCommand $initializeCommand

Set-Variable -Name 'Dev-ModuleName' -Value $moduleName -Scope Global
Set-Variable -Name 'Dev-InitializeCommand' -Value $initializeCommand -Scope Global
Set-Alias -Name 'redo' -Value Initialize-DevEnvironment -Scope Global
Set-Alias -Name 'build' -Value .\dev\build.ps1 -Scope Global -Force
Set-Alias -Name 'test' -Value Test-SingleFunction -Scope Global -Force