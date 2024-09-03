![Password Pusher Logo](pwpsm.png) ![](plussm.png) ![PowerShell Logo](pslogosm.png)
# PassPushPosh
![PowerShell Gallery Platform Support](https://img.shields.io/powershellgallery/p/passpushposh)
![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/passpushposh)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/passpushposh)
![GitHub License](https://img.shields.io/github/license/adamburley/PassPushPosh)

![GitHub last commit](https://img.shields.io/github/last-commit/adamburley/PassPushPosh)
![Code Coverage](https://img.shields.io/badge/coverage-76%25-yellow.svg?maxAge=60)


*PassPushPosh* is a PowerShell Module for the [Password Pusher](https://github.com/pglombardo/PasswordPusher) secure sharing application API. The public site for this service is [pwpush.com](https://pwpush.com).

This module supports all available endpoints exposed for *Password* pushes. As of v1.0.0 *File* and *Url* pushes are not yet implemented, but are planned.

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

- For `-Verbose` and `-Debug`, output is sanitized to prevent payloads from being written to screen / log.

# Links

- [Password Pusher API Documentation](https://pwpush.com/api/)

# TODO

- [ ] Support localization (multiple languages)
- [ ] Implement automatic builds / deploys
- [ ] Add 'burn after reading' option to `Get-Push` and `New-Push` *Under consideration*

