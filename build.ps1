Write-Host 'Building Module...' -ForegroundColor Cyan
$PsmPath = './PassPushPosh/PassPushPosh.psm1'
if (Test-Path $PsmPath) { Remove-item $PsmPath }
foreach($folder in @('PassPushPosh/Classes','PassPushPosh/Private', 'PassPushPosh/Public'))
{
    #$root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    $root = $folder
    if(Test-Path -Path $root)
    { 
        Write-Host "Processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

        $files | where-Object{ $_.name -NotLike '*.Tests.ps1'} | 
            ForEach-Object{
                Write-Host $_.name;
                Get-Content $_.FullName -Raw | Add-Content -Path $PsmPath
            }
    }
}

<#
Import-Module ./PassPushPosh -Force

$parameters = @{
    Path = './Docs'
    RefreshModulePage = $true
    AlphabeticParamsOrder = $true
    UpdateInputOutput = $true
    ExcludeDontShow = $true
    LogPath = './LastHelpModuleUpdate.txt'
    Encoding = [System.Text.Encoding]::UTF8
}
Update-MarkdownHelpModule @parameters -Force

$OutputFolder = './Docs'
$parameters = @{
    Module = 'PassPushPosh'
    OutputFolder = $OutputFolder
    AlphabeticParamsOrder = $true
    WithModulePage = $true
    ExcludeDontShow = $true
    Encoding = [System.Text.Encoding]::UTF8
}
New-MarkdownHelp @parameters -force
New-MarkdownAboutHelp -OutputFolder './Docs' -AboutName "PassPushPosh"
#>