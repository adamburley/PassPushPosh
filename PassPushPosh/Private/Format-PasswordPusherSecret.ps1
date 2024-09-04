function Format-PasswordPusherSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Secret,

        [Parameter()]
        [switch]$ShowSample
    )
    process {
        if ($Secret -eq '') {
            "length 0"
            continue
        }
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