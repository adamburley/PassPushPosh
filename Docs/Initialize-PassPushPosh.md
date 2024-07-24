# Initialize-PassPushPosh

## SYNOPSIS

Initialize the PassPushPosh module

## SYNTAX

### Anonymous (Default)

```powershell
Initialize-PassPushPosh [[-BaseUrl] <String>] [-UserAgent <String>] [-Force]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Authenticated

```powershell
Initialize-PassPushPosh [-EmailAddress] <String> [-ApiKey] <String> [[-BaseUrl] <String>] [-UserAgent <String>]
 [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Sets global variables to handle the server URL and headers (authentication).
Called automatically by module Functions if it is not called explicitly prior, so you don't actually need
to call it unless you're going to use the authenticated API or alternate server, etc
Default parameters use the pwpush.com domain and anonymous authentication.

## EXAMPLES

### EXAMPLE 1

```powershell
# Initialize with default settings

PS > Initialize-PassPushPosh
```

### EXAMPLE 2

```powershell
# Initialize with authentication

PS > Initialize-PassPushPosh -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose
```

VERBOSE: Initializing PassPushPosh.
ApiKey: \[x-kdjf\], BaseUrl: https://pwpush.com

### EXAMPLE 3

```powershell
# Initialize with another server with authentication

PS > Initialize-PassPushPosh -BaseUrl https://myprivatepwpushinstance.com -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose
```

VERBOSE: Initializing PassPushPosh.
ApiKey: \[x-kdjf\], BaseUrl: https://myprivatepwpushinstance.com

### EXAMPLE 4

```powershell
# Set a custom User Agent

PS > InitializePassPushPosh -UserAgent "I'm a cool dude with a cool script."
```

## PARAMETERS

### -EmailAddress

Email address to use for authenticated calls.

```yaml
Type: String
Parameter Sets: Authenticated
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiKey

API Key for authenticated calls.

```yaml
Type: String
Parameter Sets: Authenticated
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseUrl

Base URL for API calls.
Allows use of module with private instances of Password Pusher
Default: https://pwpush.com

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserAgent

Set a specific user agent.
Default user agent is a combination of the
module info, what your OS reports itself as, and a hash based on
your username + workstation or domain name.
This way the UA can be
semi-consistent across sessions but not identifying.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Force setting new information.
If module is already initialized you can use this to
Re-initialize with default settings.
Implied if either ApiKey or BaseUrl is provided.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction

{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

All variables set by this function start with PPP.
- PPPHeaders
- PPPUserAgent
- PPPBaseUrl

-WhatIf setting for Set-Variable -Global is disabled, otherwise -WhatIf
calls for other functions would return incorrect data in the case this
function has not yet run.

TODO: Review API key pattern for parameter validation

## RELATED LINKS
