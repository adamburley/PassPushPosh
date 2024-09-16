![Password Pusher Logo](pwpsm.png) ![](plussm.png) ![PowerShell Logo](pslogosm.png)
# PassPushPosh
[![PowerShell Gallery Platform Support](https://img.shields.io/powershellgallery/p/passpushposh)](https://www.powershellgallery.com/packages/PassPushPosh/)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/passpushposh)](https://www.powershellgallery.com/packages/PassPushPosh/)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/passpushposh)](https://www.powershellgallery.com/packages/PassPushPosh/)
![GitHub License](https://img.shields.io/github/license/adamburley/PassPushPosh)

![GitHub last commit](https://img.shields.io/github/last-commit/adamburley/PassPushPosh)
![Code Coverage](https://img.shields.io/badge/coverage-80%25-yellow.svg?maxAge=60)


*PassPushPosh* is a PowerShell 7 Module for [Password Pusher](https://pwpush.com), a secure sharing web service.

## Status

- ✅ **Passwords**: (text) All functions supported
- ⬜ **URLs**: (link forwarding) Planned
- ⬜ **Files**: Planned

In August 2024 the author of Password Pusher
[announced a commercial edition](https://docs.pwpush.com/posts/feature-pipeline/) of the application,
with features trickling into the free / OSS edition over time.

This module will track features available at the public API documentation (https://pwpush.com/api) currently
at schema version 1.1. It's not known if full testing will be available going forward but all reasonable
efforts will be made to keep this module current and stable as the environment evolves.

## Getting Started

### Install
- `Install-Module -Name PassPushPosh` or `Install-PSResource PassPushPosh`
- Download from **Releases** on this repo

### Use

```powershell
PS > "Here's my secret!" | New-Push

UrlToken            : m0nkz-xa1vlp5blcvb8
LinkDirect          : https://pwpush.com/p/m0nkz-xa1vlp5blcvb8
LinkRetrievalStep   : https://pwpush.com/p/m0nkz-xa1vlp5blcvb8/r
Link                : https://pwpush.com/p/m0nkz-xa1vlp5blcvb8
Note                : 
Payload             : 
RetrievalStep       : False
IsExpired           : False
IsDeleted           : False
IsDeletableByViewer : False
ExpireAfterDays     : 5
DaysRemaining       : 5
ExpireAfterViews    : 5
ViewsRemaining      : 5
DateCreated         : 9/4/2024 12:20:02 PM
DateUpdated         : 9/4/2024 12:20:02 PM
DateExpired         : 1/1/0001 12:00:00 AM
```

### Docs

See **[Docs](Docs)** or `Get-Help [command]` for more information. Happy sharing!

## Notes

- A primary design goal with this module is to provide simple, consistent results. Functions provide clear responses to errors, support additional messaging via `-Debug` and `-Verbose`, transaction testing via `-Whatif` and `-Confirm`, and include comment-based help.
- For `-Verbose` and `-Debug`, output is sanitized to prevent payloads from being written to screen / log.

## Links

- [Password Pusher](https://github.com/pglombardo/PasswordPusher/) Open-source repository
- [Password Pusher API Documentation](https://pwpush.com/api/)

## Other

- Used in the popular Microsoft 365 Partner management portal [CIPP](https://cipp.app/)!

