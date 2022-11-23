# PassPushPosh Module

## Description

        *PassPushPosh* is a PowerShell Module for interfacing with the Password Pusher website/application API.
        It supports anonymous and authenticated pushes, provides verbose responses to errors, -Whatif and -Confirm,
        and in general tries to be as "Powershell-y" as possible.

        Using *PassPushPosh* can be as simple as:

        ```powershell
        PS> Import-Module PassPushPosh
        PS> $myPush = New-Push "Here's my secret!"
        PS> $myPush.Link
        https://pwpush.com/en/p/gzv65wiiuciy
        ```
        
        See documentation here or `Get-Help [command]` on any function for more information. Happy sharing!

## Classes

### [[PasswordPush](PasswordPush-Class.md)]

Represents a Push with all metadata including Payload (password) value

## Functions

| Function | Summary |
|--|--|
| **[ConvertTo-PasswordPush](ConvertTo-PasswordPush.md)** | Convert API call response to a PasswordPush object |
| **[Get-Dashboard](Get-Dashboard.md)** | Get a list of active or expired Pushes for an authenticated user |
| **[Get-Push](Get-Push.md)** | Retrieve the secret contents of a Push |
| **[Get-PushAuditLog](Get-PushAuditLog.md)** | Get the view log of an authenticated Push |
| **[Get-SecretLink](Get-SecretLink.md)** | Returns a fully qualified secret link to a push of given URL Token |
| **[Initialize-PassPushPosh](Initialize-PassPushPosh.md)** | Initialize the PassPushPosh module |
| **[New-PasswordPush](New-PasswordPush.md)** | Create a new blank Password Push object. |
| **[New-Push](New-Push.md)** | Create a new Password Push |
| **[Remove-Push](Remove-Push.md)** | Remove a Push |
