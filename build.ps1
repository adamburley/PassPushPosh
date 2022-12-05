# Builds the module file and documentation.
# Documentation still needs manual massaging after build to look right online so keep that in mind
# Biggest issue is it not detecting the end of codeblocks properly in examplesd

param ( [switch]$BuildDocs, [switch]$NoTweaks, [string]$NewVersion, [string[]]$ReleaseNotes )
Write-Host 'Building Module...' -ForegroundColor Cyan
$PsmPath = './PassPushPosh/PassPushPosh.psm1'
$PsdPath = './PassPushPosh/PassPushPosh.psd1'

if (Test-Path $PsmPath) { Remove-item $PsmPath }
foreach($folder in @('PassPushPosh/Classes','PassPushPosh/Private', 'PassPushPosh/Public'))
{
    if(Test-Path -Path $folder)
    { 
        Write-Host "Processing folder $folder"
        Write-Host "Linting"
        Invoke-ScriptAnalyzer -Path $folder -Recurse -ReportSummary
        Invoke-ScriptAnalyzer -Path $folder -Recurse -ReportSummary -Fix
        Write-Host "Building files"
        $files = Get-ChildItem -Path $folder -Filter *.ps1 -Recurse

        $files | where-Object{ $_.name -NotLike '*.Tests.ps1'} | 
            ForEach-Object{
                Write-Host $_.name;
                Get-Content $_.FullName -Raw | Add-Content -Path $PsmPath
            }
    }
}
Write-Host "Updating module manifest"
$functionList = Get-ChildItem 'PassPushPosh/Public' -Filter *.ps1 | Select -ExpandProperty BaseName
$currentNotes = Test-ModuleManifest -Path $PsdPath | Select-Object -ExpandProperty ReleaseNotes
$ReleaseNotes = ($ReleaseNotes | % { "- $_" }) -join "`n"
$newNotes = @"
### $NewVersion
$ReleaseNotes

$currentNotes
"@
Update-ModuleManifest -Path $PsdPath -ModuleVersion $NewVersion -FunctionsToExport $functionList -ReleaseNotes $newNotes

Write-Host "Copying files to published directory..."
Copy-Item $PsdPath -Destination ./published/PassPushPosh/PassPushPosh.psd1
Copy-Item $PsmPath -Destination ./published/PassPushPosh/PassPushPosh.psm1

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
        #$moduleFunctions = Get-Command -Module $tweaksModuleName | select -ExpandProperty Name | Sort-Object
        $moduleFunctions = @(
            'Initialize-PassPushPosh'
            'New-Push'
            'Get-Push'
            'Remove-Push'
            'Get-SecretLink'
            'Get-Dashboard'
            'Get-PushAuditLog'
            'New-PasswordPush'
            'ConvertTo-PasswordPush'
        )
        
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
        $readMe = @("# $tweaksModuleName Module", '', '## Technical Description', '')
        $readMe += @"
*PassPushPosh* is a PowerShell Module for interfacing with the Password Pusher website/application API. It utilizes ``Invoke-WebRequest`` for all calls.
Most functions/cmdlets support reading from / writing to the pipeline and will properly iterate if passed an array of input values.

Authentication and setting User-Agent and language are handled by [Initialize-PassPushPosh](Initialize-PassPushPosh.md), however if you do not need to set any of those settings it is automatically invoked the first time a module function is invoked.  See help file or ``Get-Help Initialize-PassPushPosh`` for specifics.

Most functions will bubble up errors from ``Invoke-WebRequest``, however due to the way ``Invoke-WebRequest`` handles valid calls that return HTTP error codes (4xx) in some cases the Error is caught and a value returned instead. The documentation for [Get-PushAuditLog](Get-PushAuditLog.md) has a good rundown as to why.

"@
        $readMe += '## Classes'
        $readMe += $classesReadmeBlock
        $readMe += '## Functions',''

        # Calculate the width of the Function column
        $longestFunctionNameLength = $modulefunctions | Sort-Object -Property Length | Select -expandproperty Length -Last 1 
        $functionColumnTotalWidth = $longestFunctionNameLength * 2 + 11 # each function is the function name twice plus 11 for other characters
        $fPaddingLeft, $fPaddingRight = [math]::DivRem($functionColumnTotalWidth - 8, 2) | % { $_.Item1, ($_.Item1 + $_.Item2) } # the function line width is 8 less, need half (plus the remainder)
        $paddedFunction = (' ' * $fPaddingLeft), 'Function', (' ' * $fPaddingRight) -join ''
        $fDashes = '-' * $functionColumnTotalWidth

        # Calculate the width of the Summary column
        $helpData = $moduleFunctions | % { Get-Help $_ | Select Name, Synopsis }
        $longestHelpDataLength = $helpData | select -ExpandProperty Synopsis | Sort-Object -Property Length |  select -ExpandProperty length -Last 1 
        $sPaddingLeft, $sPaddingRight = [math]::DivRem($longestHelpDataLength - 7, 2) | % { $_.Item1, ($_.Item1 + $_.Item2) } # the summary line width is 7 less, need half (plus the remainder)
        $paddedSummary = (' ' * $sPaddingLeft), 'Summary', (' ' * $sPaddingRight) -join ''
        $pDashes = '-' * $longestHelpDataLength

        # make the table headers
        $readMe += "| $paddedFunction | $paddedSummary |"
        $readMe += "| $fDashes | $pDashes |"

        # Make the rows
        foreach ($hD in $helpData) {
            $f = $hD.Name
            $s = $hD.Synopsis
            $readMe += "| " + "**[$f]($f.md)**".PadRight($functionColumnTotalWidth) + ' | ' + $s.PadRight($longestHelpDataLength) + ' |'
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