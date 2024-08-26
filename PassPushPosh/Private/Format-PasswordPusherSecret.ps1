function Format-PasswordPusherSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Secret,

        [Parameter()]
        [switch]$ShowSample
    )
    process {
        $length = $Secret.Length
        $last4 = $Secret.Substring($length - 4)
        if ($ShowSample) {
            "length $length ending [$last4]"
        }
        else {
            "length $length"
        }
    }
}