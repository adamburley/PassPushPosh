    <#
    .SYNOPSIS
    Retrieve the secret contents of a Push

    .DESCRIPTION
    Get-Push accepts a URL Token string and returns the contents of a Push along with
    metadata regarding that Push. Note: Get-Push will return data on an expired
    Push (datestamps, etc) even if it does not return the Push contents.

    .PARAMETER URLToken
    URL Token for the secret

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush]

    .EXAMPLE
    Get-Push -URLToken gzv65wiiuciy

    .EXAMPLE
    Get-Push -URLToken gzv65wiiuciy -Raw
    {"payload":"I am your payload!","expired":false,"deleted":false,"expired_on":"","expire_after_days":1,"expire_after_views":4,"url_token":"bwzehzem_xu-","created_at":"2022-11-21T13:20:08.635Z","updated_at":"2022-11-21T13:23:45.342Z","deletable_by_viewer":true,"retrieval_step":false,"days_remaining":1,"views_remaining":4}

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Push.md

    .LINK
    https://pwpush.com/api/1.0/passwords/show.en.html

    .LINK
    New-Push

    #>
function Get-Push {
    [CmdletBinding()]
    [OutputType([PasswordPush])]
    param(
        [parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Token')]
        $URLToken
    )
    begin { Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference }
    process {
        Invoke-PasswordPusherAPI -Endpoint "p/$URLToken.json" | Select-Object -ExpandProperty Content | ConvertTo-PasswordPush
    }
}