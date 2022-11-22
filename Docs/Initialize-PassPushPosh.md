---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version: https://pwpush.com/api/1.0/passwords/preview.en.html
schema: 2.0.0
---

# Initialize-PassPushPosh

## SYNOPSIS
Initialize the PassPushPosh module

## SYNTAX

### Anonymous (Default)
```
Initialize-PassPushPosh [[-BaseUrl] <String>] [-Language <String>] [-UserAgent <String>] [-Force]
 [<CommonParameters>]
```

### Authenticated
```
Initialize-PassPushPosh [-EmailAddress] <String> [-ApiKey] <String> [[-BaseUrl] <String>] [-Language <String>]
 [-UserAgent <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Sets global variables to handle the server URL, headers (authentication), and language.
Called automatically by module Functions if it is not called explicitly prior, so you don't actually need
to call it unless you're going to use the authenticated API or alternate server, etc
Default parameters use the pwpush.com domain, anonymous authentication, and whatever language your computer
is set to.

## EXAMPLES

### EXAMPLE 1
```
# Initialize with default settings
PS > Initialize-PassPushPosh
```

### EXAMPLE 2
```
# Initialize with authentication
PS > Initialize-PassPushPosh -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose
```

VERBOSE: Initializing PassPushPosh.
ApiKey: \[x-kdjf\], BaseUrl: https://pwpush.com

### EXAMPLE 3
```
# Initialize with another server with authentication
PS > Initialize-PassPushPosh -BaseUrl https://myprivatepwpushinstance.com -EmailAddress 'youremail@example.com' -ApiKey '239jf0jsdflskdjf' -Verbose
```

VERBOSE: Initializing PassPushPosh.
ApiKey: \[x-kdjf\], BaseUrl: https://myprivatepwpushinstance.com

## PARAMETERS

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

### -Language
Language to render resulting links in.
Defaults to host OS language, or English if
host OS language is not available

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
Set a specific user agent. Default user agent is a combination of the
module info, what your OS reports itself as, and a hash based on
your username + workstation or domain name. This way the UA can be
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
TODO: Review API key pattern for parameter validation

## RELATED LINKS
