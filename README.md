# PassPushPosh
![Code Coverage](https://img.shields.io/badge/coverage-76%25-yellow.svg?maxAge=60)


*PassPushPosh* is a PowerShell Module for interfacing with the [Password Pusher](https://github.com/pglombardo/PasswordPusher) secure password / string sharing application, primarily through [pwpush.com](https://pwpush.com). It supports creating, retrieving, and deleting anonymous and authenticated pushes, links in any supported language, and getting Push and Dashboard data for authenticated users.

A primary design goal with this module was to provide **simple, beginner-friendly access** to API connections. Cmdlets provide clear responses to errors, support additional messaging via `-Debug` and `-Verbose`, transaction testing via `-Whatif` and `-Confirm`, and in general try to be as "Powershell-y" as possible.

Using *PassPushPosh* can be as simple as:

```powershell
PS> "Here's my secret!" | New-Push | select Link
Link
----
https://pwpush.com/en/p/gzv65wiiuciy
```

Or more completely...

```powershell
PS> Import-Module PassPushPosh
PS> $myPush = New-Push "Here's my secret!"
PS> $myPush.Link
https://pwpush.com/en/p/gzv65wiiuciy
```

See **[Docs](Docs)** or `Get-Help [command]` for more information. Happy sharing!

# How to Get

- Available on [PowerShell Gallery](https://www.powershellgallery.com/packages/PassPushPosh) - `Install-Module -Name PassPushPosh`
- Copy `PassPushPosh/PassPushPosh.psm1` and `PassPushPosh/PassPushPosh.psd1` to a folder called PassPushPosh somewhere on your computer and `Import-Module .\PassPushPosh\`

# Notes

- For `-Verbose` and `-Debug`, output is sanitized to prevent payloads from being written to screen.

# Links

- [Password Pusher API Documentation](https://pwpush.com/api/1.0.en.html)

# TODO

- [ ] Support localization (multiple languages)
- [ ] Implement automatic builds / deploys
- [ ] Add 'burn after reading' option to `Get-Push` and `New-Push` *Under consideration*

