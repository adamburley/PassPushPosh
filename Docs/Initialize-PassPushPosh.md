# Initialize-PassPushPosh

## SYNOPSIS
Initialize the PassPushPosh module

## SYNTAX

### Anonymous (Default)
```powershell
Initialize-PassPushPosh [-BaseUrl <String>] [-UserAgent <String>] [-Force] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Authenticated
```powershell
Initialize-PassPushPosh [-Bearer <String>] [-BaseUrl <String>] [-UserAgent <String>] [-Force]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Legacy Auth
```powershell
Initialize-PassPushPosh [-ApiKey] <String> [-EmailAddress] <String> [-UseLegacyAuthentication]
 [-BaseUrl <String>] [-UserAgent <String>] [-Force] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Initialize-PassPushPosh sets variables for the module's use during the remainder of the session.
Server URL and User Agent values are set by default but may be overridden.
If invoked with email address and API key, calls are sent as authenticated.
Otherwise they default to
anonymous.

This function is called automatically if needed, defaulting to the public pwpush.com service.

## EXAMPLES

### Default settings
```powershell
PS > Initialize-PassPushPosh
```

### Authentication
```powershell
PS > Initialize-PassPushPosh -Bearer 'myreallylongapikey'
```

### Custom domain

Initialize with another domain - may be a private instance or a hosted instance with custom domain

```powershell
PS > Initialize-PassPushPosh -BaseUrl https://myprivatepwpushinstance.example.com -Bearer 'myreallylongapikey'
```

### Legacy authentication support

```powershell
PS > Initialize-PassPushPosh -ApiKey 'myreallylongapikey' -EmailAddress 'myregisteredemail@example.com' -UseLegacyAuthentication -BaseUrl https://myprivatepwpushinstance.example.com
```

### Custom user agent
```powershell
PS > InitializePassPushPosh -UserAgent "My-CoolUserAgent/1.12.1"
```

## PARAMETERS

### -Bearer
API key for authenticated calls.
Supported on hosted instance and OSS v1.51.0 and newer.

```yaml
Type: String
Parameter Sets: Authenticated
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiKey
API key for authenticated calls.
Supports older OSS installs.
Also supports Bearer autodetection.
This will be removed in a future version.

```yaml
Type: String
Parameter Sets: Legacy Auth
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailAddress
Email address for authenticated calls.
NOTE: This is only required for legacy X-User-Token authentication.
If using hosted pwpush.com
services or OSS v1.51.0 or newer use -Bearer

```yaml
Type: String
Parameter Sets: Legacy Auth
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseLegacyAuthentication
{{ Fill UseLegacyAuthentication Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Legacy Auth
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseUrl
Base URL for API calls.
Allows use of custom domains with hosted Password Pusher as well as specifying
a private instance.

Default: https://pwpush.com

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

### -UserAgent
Set a specific user agent.
Default user agent is a combination of the
module info, what your OS reports itself as, and a hash based on
your username + workstation or domain name.
This way the UA can be
semi-consistent across sessions but not identifying.

Note: User agent must meet \[RFC9110\](https://www.rfc-editor.org/rfc/rfc9110#name-user-agent) specifications or the Password Pusher API will reject the call.

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
re-initialize the module.
If not specified and there is an existing session the request is ignored.

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
The use of X-USER-TOKEN for authentication is depreciated and will be removed in a future release of the API.
This module will support it via legacy mode, initially by attempting to auto-detect if Bearer is supported.
New code using this module should use -Bearer (most cases) or -UseLegacyAuthentication (self-hosted older versions).
In a future release the module will default to Bearer unless the -UseLegacyAuthentication switch is set.

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Initialize-PassPushPosh.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Initialize-PassPushPosh.md)

