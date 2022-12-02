[CmdletBinding(DefaultParameterSetName="Validate")]
param (
    # Validate
    [Parameter(ParameterSetName="Validate")]
    [switch]
    $Validate,

    # Publish
    [Parameter(ParameterSetName="Publish")]
    [switch]
    $Publish,

    # New version e.g. 0.2.2
    [Parameter()]
    [string]
    $VersionString
)
if ($Validate -eq $Publish) { Write-Error "Must select Validate or Publish"; return $false }
<#
    "Build"
    Update module manifest
    Copy psd1, psm1, other files to Publish folder

    "Publish"
    test module manifest

#>
Copy-Item
Update-ModuleManifest
Test-ModuleManifest
Publish-Module