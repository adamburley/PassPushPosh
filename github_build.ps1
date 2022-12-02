param (
    # Path to save output
    [string]$Path = '/tmp/PassPushPosh',

    # New semantic version number e.g. 0.2.3
    [string]$Version,

    # Release notes as an array of strings. each entry will be a separate line item in the output
    [string[]]$ReleaseNotes
)
Write-Host 'Building Module...' -ForegroundColor Cyan
$PsmPath = "$Path/PassPushPosh.psm1"

# Build the module
foreach ($folder in @('PassPushPosh/Classes', 'PassPushPosh/Private', 'PassPushPosh/Public')) {
    $root = $folder
    if (Test-Path -Path $root) { 
        Write-Host  "Processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

        $files | where-Object { $_.name -NotLike '*.Tests.ps1' } | 
        ForEach-Object {
            Write-Host $_.name;
            Get-Content $_.FullName -Raw | Add-Content -Path $PsmPath
        }
    }
}

# Import
Import-Module $Path -Force
$existingReleaseNotes = Get-Module -Name PassPushPosh | Select-Object -ExpandProperty ReleaseNotes
$ReleaseNotes += "`n" + $existingReleaseNotes