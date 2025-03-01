<#
    .SYNOPSIS
    Retrieve the secret contents of a Push

    .DESCRIPTION
    Get-Push accepts a URL Token string and returns the contents of a Push along with
    metadata regarding that Push. Note: Get-Push will return data on an expired
    Push (datestamps, etc) even if it does not return the Push contents.

    .PARAMETER URLToken
    URL Token for the secret

    .PARAMETER Passhrase
    An additional phrase required to view the secret. Required if the Push was created with a Passphrase.

    .PARAMETER OutFolder
    For File pushes, a folder path to save files. If the folder path does not exist
    it will be created. Files are saved with their original names.

    .PARAMETER IncludePushObject
    When saving files from a file push, also save the push data itself. This will
    create a JSON object in the same path as the files with the

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush]

    .EXAMPLE
    Get-Push -URLToken gzv65wiiuciy

    .EXAMPLE
    Get-Push -URLToken gzv65wiiuciy -Passphrase "My Passphrase"

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Push.md

    .LINK
    New-Push

    #>
function Get-Push {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Passphrase", Justification = "DE0001: SecureString shouldn't be used")]
    [CmdletBinding(DefaultParameterSetName = 'Text')]
    [OutputType([PasswordPush])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        $URLToken,

        [Parameter()]
        [String]$Passphrase,

        [Parameter(ParameterSetName = 'Out File')]
        [Alias('OutFile')]
        [System.IO.DirectoryInfo]$OutFolder,

        [Parameter(ParameterSetName = 'Out File')]
        [switch]$IncludePushObject
    )
    begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }
    process {
        $endpoint = $Passphrase ? "p/$URLToken.json?passphrase=$Passphrase" : "p/$URLToken.json"
        $result = Invoke-PasswordPusherAPI -Endpoint $endpoint -ReturnErrors
        if ($result.error){
            if ($result.error -eq 'not-found') { Write-Error -Message "Push not found. Check the token you provided. Tokens are case-sensitive." }
            if ($result.error -eq 'This push has a passphrase that was incorrect or not provided.') { if ($Passphrase) { Write-Error -Message "Incorrect passphrase provided." } else { Write-Error -Message "Passphrase required. Specify with the -Passphrase parameter." } }
        }
        $pushObject = $result | ConvertTo-PasswordPush
        if ($OutFolder) {
            if ($pushObject.Files.Count -gt 0) {
                if (-not (Test-Path -Path $OutFolder -PathType Container)) {
                    New-Item -Path $OutFolder -ItemType Directory | Out-Null
                    Write-Verbose "$OutFolder does not exist and was created."
                } else {
                    Write-Verbose "Saving files to $OutFolder"
                }
                foreach ($f in $pushObject.Files){
                    Write-Verbose "Saving $($f.filename) [$($f.content_type)]"
                    Invoke-WebRequest -Uri $f.url -OutFile (Join-Path -Path $OutFolder -ChildPath $f.filename)
                }
                if ($IncludePushObject) {
                    $pushObject | ConvertTo-Json -Depth 10 | Out-File (Join-Path $OutFolder -ChildPath "Push_$($pushObject.UrlToken).json")
                }
            } else {
                Write-Warning "No files were included in this push. Nothing was saved."
            }
            $pushObject
        }
        else {
            $pushObject
        }
    }
}