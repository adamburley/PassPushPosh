# https://powershellexplained.com/2017-01-21-powershell-module-continious-delivery-pipeline
Write-Verbose "Importing Functions"

# Import everything in these folders
foreach($folder in @('private', 'public', 'classes'))
{
    
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if(Test-Path -Path $root)
    { 
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1

        # dot source each file
        $files | where-Object{ $_.name -NotLike '*.Tests.ps1'} | 
            ForEach-Object{Write-Verbose $_.name; . $_.FullName}
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\public\*.ps1").basename

