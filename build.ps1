# Builds the module file and documentation.
# Documentation still needs manual massaging after build to look right online so keep that in mind
# Biggest issue is it not detecting the end of codeblocks properly in examplesd

param ( [switch]$BuildDocs, [switch]$NoTweaks )
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

if ($BuildDocs){
    Import-Module ./PassPushPosh -Force

    # Using the Update- functions in PlatyPS seems broken. Maybe it's just
    # the modifications to the files I'm making...
    $docPath = 'Docs'
    Remove-Item $docPath/*
    $parameters = @{
        AlphabeticParamsOrder = $false
        Encoding = [System.Text.Encoding]::UTF8
        ModulePagePath = 'Docs/README.md'
        Module         = 'PassPushPosh'
        OutputFolder   = $docPath
        WithModulePage = $false
        NoMetadata     = $true
    }
    Write-Host "Generating new markdown help" -ForegroundColor Cyan
    New-MarkdownHelp @parameters -force
    New-MarkdownAboutHelp -OutputFolder './Docs' -AboutName "PassPushPosh"

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
            if ($docFile.Basename -ine 'about_PassPushPosh') {
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
            }
            $outRows = ($outRows -join "`n").Trim() -split "`n" # ugly way to remove trailing whitespaces
            $outRows | Out-File -FilePath $docFile.FullName
        }

        $classesReadmeBlock = @()
        # Handle classes
        foreach ($class in $tweaksModuleClasses) {
            Write-Host "Building class documentation: $class " -ForegroundColor Gray
            # Copy readme to docs
            Copy-Item "./PassPushPosh/Classes/$class.md" -Destination "./Docs/$class-Class.md"
            # Get summary
            $classReadme = Get-Content "./PassPushPosh/Classes/$class.md"
            $cRmStartIndex = $classReadme.IndexOf('## SUMMARY') + 1
            $cRmStopIndex = $classReadme.IndexOf('## DESCRIPTION') - 1
            $cSummary = $classReadme[$cRmStartIndex..$cRmStopIndex]
            # Add reference to readme
            $classesReadmeBlock += ''
            $classesReadmeBlock += "### [[$class]($class-Class.md)]"
            $classesReadmeBlock += $cSummary
        }

        # Manually build README.md
        $readMe = @("# $tweaksModuleName Module", '', '## Description', '')
        $readMe += @"
*PassPushPosh* is a PowerShell Module for interfacing with the Password Pusher website/application API.
It supports anonymous and authenticated pushes, provides verbose responses to errors, `-Whatif` and `-Confirm`,
and in general tries to be as "Powershell-y" as possible.

Using *PassPushPosh* can be as simple as:

``````powershell
PS> Import-Module PassPushPosh
PS> `$myPush = New-Push "Here's my secret!"
PS> `$myPush.Link
https://pwpush.com/en/p/gzv65wiiuciy
``````

See documentation here or ``Get-Help [command]`` on any function for more information. Happy sharing!

"@

        $readMe += '## Classes'
        $readMe += $classesReadmeBlock
        $readMe += '## Functions','','| Function | Summary |','|--|--|'
        foreach ($f in $moduleFunctions) {
            $s = Get-Help $f | select -ExpandProperty Synopsis
            $readMe += "| **[$f]($f.md)** | $s |"
        }

        $readMe | Out-File -FilePath 'Docs/README.md'


        # The old method
        <#
        # Add class references
        $newReadmeBlock = @("## $tweaksModulename Classes","")
        foreach ($class in $tweaksModuleClasses) {
            Write-Host "Building class documentation: $class " -ForegroundColor Gray
            # Copy readme to docs
            Copy-Item "./PassPushPosh/Classes/$class.md" -Destination "./Docs/$class-Class.md"

            # Get summary
            $classReadme = Get-Content "./PassPushPosh/Classes/$class.md"
            $cRmStartIndex = $classReadme.IndexOf('## SUMMARY') + 1
            $cRmStopIndex = $classReadme.IndexOf('## DESCRIPTION') - 1
            $cSummary = $classReadme[$cRmStartIndex..$cRmStopIndex]
            # Add reference to readme
            $newReadmeBlock += "### [[$class]($class-Class.md)]"
            $newReadmeBlock += $cSummary
        }
        $readmeContent = Get-Content 'Docs/README.md'
        $cmdLetHeaderIndex = $readmeContent.IndexOf(($readmeContent | where { $_ -ilike "## * Cmdlets"}))
        $assembledReadme = $readmeContent[0..($cmdLetHeaderIndex-1)] + $newReadmeBlock + $readmeContent[$cmdLetHeaderIndex..($readmeContent.Count-1)]
        $assembledReadme | Out-File -FilePath 'Docs/README.MD'
        #>
    }
}