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
    $tweaksModuleName = 'PassPushPosh'
    $tweaksModuleClasses = @('PasswordPush')
    $moduleOnlineDocumentationRoot = 'https://github.com/adamburley/PassPushPosh/blob/main/Docs'
    $moduleFunctions = Get-Command -Module $tweaksModuleName | select -ExpandProperty Name
    
    # Fixing some problems with the markdown PlatyPs outputs...
    Write-Host 'Markdown tweaks...' -ForegroundColor Yellow

    foreach ($docFile in (Get-ChildItem -Path ./Docs -Recurse)) {
        Write-Host '--- ' $docFile.Name ' ---'
        $fileContent = Get-Content -Path $docFile.FullName
        $outRows = @()
        for ($i = 0; $i -lt $fileContent.Count; $i++) {
            $row = $fileContent[$i]
            if ($row -ilike "#*" -and $fileContent[$i+1] -ne '') { # Blank lines after headings
                $outRows += $row
                $outRows += ''
            }
            elseif ($row -eq '```' -and $fileContent[$i+1] -ne '') {
                $outRows += '```powershell' # Language marker for code blocks
            }
            else { $outRows += $row }
        }

        # Fix Links
        $thisFunctionHelp = Get-Help $docFile.BaseName
        if ($thisFunctionHelp.relatedLinks) { # Has help links
            $outRows = $outRows[0..$outRows.IndexOf('## RELATED LINKS')]
            $outRows += ''
            for ($ri = 0; $ri -lt $thisFunctionHelp.relatedLinks.navigationLink.Count; $ri++) {
                $link = $thisFunctionHelp.relatedLinks.navigationLink[$ri]
                if ($link.uri) { # Link was detected as a web URI
                    if ($link.uri -ilike "$moduleOnlineDocumentationRoot*") {
                        Write-Host "Skipping" $link.uri -ForegroundColor Yellow
                    } else {
                        Write-Host $link.uri -ForegroundColor DarkCyan
                        $outRows += "- [Password Pusher API Documentation]($($link.uri))"
                    }
                } elseif ($link.linkText) {
                    $linkString = $link.linkText.Trim()
                    if ($linkString -iin $moduleFunctions) {
                        Write-Host "Function: $linkString" -ForegroundColor Magenta
                        $outRows += "- [$linkString]($linkString.md)"
                    }
                } else {
                    Write-Host "Unknown: " $link -ForegroundColor Red
                }
            }
        }
        $outRows = ($outRows -join "`n").Trim() -split "`n" # ugly way to remove trailing whitespaces
        $outRows | Out-File -FilePath $docFile.FullName
    }

    # Add class references
    $newReadmeBlock = @("## $tweaksModulename Classes","")
    foreach ($class in $tweaksModuleClasses) {
        Write-Host "Tweaking $class documentation" -ForegroundColor Gray
        # Add reference to readme
        $newReadmeBlock += "### [[$class](../Public/Classes/$class.md)]"
        $newReadmeBlock += ""
        $newReadmeBlock += "Somedescriptiongoeshere"
        $newReadmeBlock += ""
    }
    $readmeContent = Get-Content $parameters.ModulePagePath
    $cmdLetHeaderIndex = $readmeContent.IndexOf(($readmeContent | where { $_ -ilike "## * Cmdlets"}))
    $assembledReadme = $readmeContent[0..($cmdLetHeaderIndex-1)] + $newReadmeBlock + $readmeContent[$cmdLetHeaderIndex..($readmeContent.Count-1)]
    $assembledReadme | Out-File -FilePath $parameters.ModulePagePath
}