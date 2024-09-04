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
    https://pwpush.com/api/1.0/passwords.en.html

    .LINK
    https://github.com/pglombardo/PasswordPusher/blob/c2909b2d5f1315f9b66939c9fbc7fd47b0cfeb03/app/controllers/passwords_controller.rb#L89

    .LINK
    New-Push

    #>
function Get-Push {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Passphrase", Justification = "DE0001: SecureString shouldn't be used")]
    [CmdletBinding()]
    [OutputType([PasswordPush])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        $URLToken,

        [Parameter()]
        [String]$Passphrase
    )
    begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }
    process {
        $endpoint = $Passphrase ? "p/$URLToken.json?passphrase=$Passphrase" : "p/$URLToken.json"
        $result = Invoke-PasswordPusherAPI -Endpoint $endpoint -ReturnErrors
        switch ($result.error){
            'not-found' { Write-Error -Message "Push not found. Check the token you provided. Tokens are case-sensitive." }
            'This push has a passphrase that was incorrect or not provided.' { if ($Passphrase) { Write-Error -Message "Incorrect passphrase provided." } else { Write-Error -Message "Passphrase required. Specify with the -Passphrase parameter." } }
            default { $result | ConvertTo-PasswordPush }
        }
    }
}