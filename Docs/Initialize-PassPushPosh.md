# Initialize-PassPushPosh

## SYNOPSIS
Initialize the PassPushPosh module

## SYNTAX

### Anonymous (Default)
```PowerShell
Initialize-PassPushPosh [[-BaseUrl] <String>] [-UserAgent <String>] [-Force]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Authenticated
```PowerShell
Initialize-PassPushPosh [-EmailAddress] <String> -ApiKey <String> [[-BaseUrl] <String>] [-UserAgent <String>]
 [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Pro
```PowerShell
Initialize-PassPushPosh [-AccountType <String>] -ApiKey <String> [-UserAgent <String>] [-Force]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Initialize-PassPushPosh sets variables for the module's use during the remainder of the session.
Server URL and User Agent values are set by default but may be overridden.
If invoked with email address and API key, calls are sent as authenticated.
Otherwise they default to
anonymous.

This function is called automatically if needed, defaulting to the public pwpush.com service.

## EXAMPLES

### Default Settings
```PowerShell
PS > Initialize-PassPushPosh
```
Initializes with default settings - anonymous pushes and pwpush.com for the server.

### Authenticated
```PowerShell
PS > Initialize-PassPushPosh -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose

VERBOSE: Initializing PassPushPosh.
ApiKey: \[x-kdjf\], BaseUrl: https://pwpush.com
```
Initialize with authentication - free account or self-hosted instance.

### Private Server
```PowerShell
PS > Initialize-PassPushPosh -BaseUrl https://myprivatepwpushinstance.com -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose

VERBOSE: Initializing PassPushPosh.
ApiKey: \[x-kdjf\], BaseUrl: https://myprivatepwpushinstance.com
```

Initialize with another server with authentication

### Custom User-Agent
```PowerShell
PS > InitializePassPushPosh -UserAgent "My-CoolUserAgent/1.12.1"
```

## PARAMETERS

### -AccountType
For paid users, specify the account type as Premium or Pro.
Not required for free accounts and self-hosted.

```yaml
Type: String
Parameter Sets: Pro
Aliases:

Required: False
Position: Named
Default value: Pro
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailAddress
Email address for authenticated calls.

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
API key for authenticated calls.

```yaml
Type: String
Parameter Sets: Pro, Authenticated
Aliases:

Required: True
Position: Named
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
Parameter Sets: Anonymous, Authenticated
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- This function does not accept any input from the pipeline

## OUTPUTS

- This function does not return anything to the pipeline

## NOTES
-WhatIf setting for Set-Variable -Script is disabled, otherwise -WhatIf
calls for other functions would return incorrect data in the case this
function has not yet run.

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Initialize-PassPushPosh.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Initialize-PassPushPosh.md)

