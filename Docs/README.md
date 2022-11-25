# PassPushPosh Module

## Technical Description

*PassPushPosh* is a PowerShell Module for interfacing with the Password Pusher website/application API. It utilizes `Invoke-WebRequest` for all calls.
Most functions/cmdlets support reading from / writing to the pipeline and will properly iterate if passed an array of input values.

Authentication and setting User-Agent and language are handled by [Initialize-PassPushPosh](Initialize-PassPushPosh.md), however if you do not need to set any of those settings it is automatically invoked the first time a module function is invoked.  See help file or `Get-Help Initialize-PassPushPosh` for specifics.

Most functions will bubble up errors from `Invoke-WebRequest`, however due to the way `Invoke-WebRequest` handles valid calls that return HTTP error codes (4xx) in some cases the Error is caught and a value returned instead. The documentation for [Get-PushAuditLog](Get-PushAuditLog.md) has a good rundown as to why.

## Classes

### [[PasswordPush](PasswordPush-Class.md)]

Represents a Push with all metadata including Payload (password) value

## Functions

|                         Function                          |                              Summary                               |
| --------------------------------------------------------- | ------------------------------------------------------------------ |
| **[Initialize-PassPushPosh](Initialize-PassPushPosh.md)** | Initialize the PassPushPosh module                                 |
| **[New-Push](New-Push.md)**                               | Create a new Password Push                                         |
| **[Get-Push](Get-Push.md)**                               | Retrieve the secret contents of a Push                             |
| **[Remove-Push](Remove-Push.md)**                         | Remove a Push                                                      |
| **[Get-SecretLink](Get-SecretLink.md)**                   | Returns a fully qualified secret link to a push of given URL Token |
| **[Get-Dashboard](Get-Dashboard.md)**                     | Get a list of active or expired Pushes for an authenticated user   |
| **[Get-PushAuditLog](Get-PushAuditLog.md)**               | Get the view log of an authenticated Push                          |
| **[New-PasswordPush](New-PasswordPush.md)**               | Create a new blank Password Push object.                           |
| **[ConvertTo-PasswordPush](ConvertTo-PasswordPush.md)**   | Convert API call response to a PasswordPush object                 |
