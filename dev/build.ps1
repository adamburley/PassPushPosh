# Execute from the repo root
# Usage: .\dev\build.ps1 -Version 1.0.0

param(
    [string]$Version
)

Import-Module PSScriptAnalyzer


# Sanity checks
Invoke-ScriptAnalyzer -Path '.\PassPushPosh' -Recurse -ReportSummary
Invoke-ScriptAnalyzer -Path '.\PassPushPosh' -Recurse -ReportSummary -Fix
if ($Version) { 
    Write-Host "Updating version to $Version" -ForegroundColor Yellow -BackgroundColor Blue
    Update-ModuleManifest -Path '.\PassPushPosh\PassPushPosh.psd1' -ModuleVersion $Version
} else {
    $Version = (Test-ModuleManifest '.\PassPushPosh\PassPushPosh.psd1').Version.ToString()
    Write-Host "Using version $Version" -ForegroundColor Yellow -BackgroundColor Blue

}
Write-Host "`nRebuilding Module..." -ForegroundColor Yellow

Build-Module -Version $Version -SourcePath '.\PassPushPosh\PassPushPosh.psd1' -OutputDirectory '..\Output' -UnversionedOutputDirectory

# Custom build modifications for this module
(Get-Content -Path '.\Output\PassPushPosh\PassPushPosh.psm1').Replace('{{semversion}}',$version) | Set-Content -Path '.\Output\PassPushPosh\PassPushPosh.psm1'

Remove-Module -Name PassPushPosh -Force

Write-Host "`nTesting Module..." -ForegroundColor Yellow
$pesterResults = & .\dev\test.ps1

# Rebuild Docs
Import-Module '.\PassPushPosh\PassPushPosh.psd1' -Force
New-MarkdownHelp -Module PassPushPosh -OutputFolder .\docs -ExcludeDontShow -Force -NoMetadata

# Readme Updates
$ReadmeContent = Get-Content -Path '.\README.md' -Raw

# Update Code coverage icon
# Thanks to https://wragg.io/add-a-code-coverage-badge-to-your-powershell-deployment-pipeline/
$codeCoverage = [math]::Round($pesterResults.CodeCoverage.CoveragePercent)
$BadgeColor = switch ($codeCoverage) {
    {$_ -in 90..100} { 'brightgreen' }
    {$_ -in 75..89}  { 'yellow' }
    {$_ -in 60..74}  { 'orange' }
    default          { 'red' }
}

$ReadmeContent = $ReadmeContent -replace "\!\[Code Coverage\]\(.*?\)", "![Code Coverage](https://img.shields.io/badge/coverage-$CodeCoverage%25-$BadgeColor.svg?maxAge=60)"

# Create summary page
$summaryContent = "## Functions`n`n| Function | Synopsis |`n| --- | --- |`n"
$commands = (Get-Module -Name PassPushPosh).ExportedCommands.Keys
foreach ($command in $commands) {
    $cHelpSummary = Get-Help -Name $command -Full | Select-Object -ExpandProperty Synopsis
    $summaryContent += "| [$command](./docs/$command.md) | $cHelpSummary |`n"
}
$summaryContent += "`n#"
$summaryContent | Set-Content -Path '.\docs\README.md'
$ReadmeContent = [regex]::Replace($ReadmeContent,"## Functions\n\n(?'helpfiles'.*?)\n\n#{1}",$summaryContent,[System.Text.RegularExpressions.RegexOptions]::Singleline)

$ReadmeContent | Set-Content -Path '.\README.md'