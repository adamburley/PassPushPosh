function New-PasswordPush {
    <#
    .SYNOPSIS
    Create a new blank Password Push object.

    .DESCRIPTION
    Creates a blank [PasswordPush].
    Generally not needed, use ConvertTo-PasswordPush
    See New-Push if you're trying to create a new secret to send

    .INPUTS
    None

    .OUTPUTS
    [PasswordPush]
    
    .EXAMPLE
    New-PasswordPush

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/New-PasswordPush.md

    .NOTES
    TODO Rewrite - make this work including read-only properties
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function', Justification = 'Creates a new object, no risk of overwriting data.')]
    [CmdletBinding()]
    param ()
    return [PasswordPush]::new()
}