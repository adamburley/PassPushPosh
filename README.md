# PassPushPosh

PassPushPosh is a PowerShell module for the [Password Pusher](/pglombardo/PasswordPusher) secure password / string sharing application. It fully enumerates the [Password Pusher API](https://pwpush.com/api)

# Functions

- 🟢 **Class:** PasswordPush
  - ⚫️ Format File
- 🟡 Get-Dashboard
- 🟡 Get-Push
- 🟡 Get-PushAuditLog
- 🟡 Get-SecretLink
- 🟢 Initialize-PassPushPosh
- 🟢 New-Push
- 🟡 Remove-Push

# Notes

- The 'last call' does not return expired true or expired_on with a datetime, but does show views_remaining = 0
- If Get-Push is made on an expired push it will return a blank line for payload
- [Password Pusher API Documentation](https://pwpush.com/api/1.0.en.html)
- Read-only class properties: [OCRam85:  PowerShell Read Only Class Properties](https://ocram85.com/posts/pwsh-read-only-class-properties/)
- [PowerShell Utility Modules](https://learn.microsoft.com/en-us/powershell/utility-modules/overview?view=ps-modules) including PSScriptAnalyizer

# TODO

- [ ] Support localization (multiple languages)
- [ ] Support localization in secret link and 1-step link
- [ ] Documentation for [PasswordPush] class
- [ ] Finish documentation in /Docs
- [ ] Implement automated testing with Pester
- [ ] Implement automatic builds / deploys
- [ ] Module documentation
- [ ] Align validation requirements in functions for the same data (e.g. URL Token)
- [ ] Fix inconsistent indentation
- [ ] Issue: Importing class to use in returntype for function [e.g. New-Push]