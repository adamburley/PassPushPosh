function Get-PushApiVersion {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    Initialize-PassPushPosh -Verbose:$VerbosePreference -Debug:$DebugPreference
    Invoke-PasswordPusherAPI -Endpoint 'api/v1/version.json'
}