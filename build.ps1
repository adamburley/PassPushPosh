param ( [switch]$New, [switch]$NoTweaks )
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

Import-Module ./PassPushPosh -Force


$docPath = 'Docs'
$parameters = @{

    AlphabeticParamsOrder = $false
    Encoding = [System.Text.Encoding]::UTF8
    ModulePagePath = 'Docs/README.md'
}
if ($New) {
    $parameters.Module = 'PassPushPosh'
    $parameters.OutputFolder = $docPath
    $parameters.WithModulePage = $true
    $parameters.NoMetadata = $true
    Write-Host "Generating new markdown help" -ForegroundColor Cyan
    New-MarkdownHelp @parameters -force
    #New-MarkdownAboutHelp -OutputFolder './Docs' -AboutName "PassPushPosh"
} else {
    $parameters.Path = $docPath
    $parameters.RefreshModulePage = $true
    $parameters.LogPath = '.LastHelpModuleUpdate.txt'
    Update-MarkdownHelpModule @parameters -Force
}

if (-not $NoTweaks) {
    # Fixing some problems with the markdown PlatyPs outputs...
    Write-Host 'Markdown tweaks...' -ForegroundColor Yellow
    foreach ($docFile in (Get-ChildItem -Path ./Docs -Recurse)) {
        Write-Host $docFile.Name
        $fileContent = Get-Content -Path $docFile.FullName
        $outRows = @()
        for ($i = 0; $i -lt $fileContent.Count; $i++) {
            $row = $fileContent[$i]
            if ($row -ilike "#*" -and $fileContent[$i+1] -ne '') {
                $outRows += $row
                $outRows += ''
            }
            elseif ($row -eq '```' -and $fileContent[$i+1] -ne '') {
                $outRows += '```powershell'
            }
            else { $outRows += $row }
        }
        $outRows[0..($outRows.Count-2)] | Out-File -FilePath $docFile.FullName
    }
}