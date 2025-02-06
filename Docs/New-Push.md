# New-Push

## SYNOPSIS
Create a new Push

## SYNTAX

### Anonymous (Default)
```PowerShell
New-Push [-Payload] <String> [-Passphrase <String>] [-ExpireAfterDays <Int32>] [-ExpireAfterViews <Int32>]
 [-DeletableByViewer] [-RetrievalStep] [-AccountId <Object>] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Authenticated
```PowerShell
New-Push [-Payload] <String> [-Passphrase <String>] [-Note <String>] [-ExpireAfterDays <Int32>]
 [-ExpireAfterViews <Int32>] [-DeletableByViewer] [-RetrievalStep] [-AccountId <Object>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new Push on the specified Password Pusher instance.
The
programmatic equivalent of going to pwpush.com and entering info.
Returns \[PasswordPush\] object.
Link member is a link created based on
1-step setting however both 1-step and direct links
are always provided at LinkRetrievalStep and LinkDirect properties.

## EXAMPLES

### Basic Usage
```PowerShell
$myPush = New-Push "Here's my secret!"
PS > $myPush | Select-Object Link, LinkRetrievalStep, LinkDirect

Link              : https://pwpush.com/p/gzv65wiiuciy   # Requested style
LinkRetrievalStep : https://pwpush.com/p/gzv65wiiuciy/r # 1-step
LinkDirect        : https://pwpush.com/p/gzv65wiiuciy   # Direct
```

### PipeLine
```PowerShell
PS > "Super secret secret" | New-Push -RetrievalStep | Select-Object -ExpandProperty Link

https://pwpush.com/p/gzv65wiiuciy/r
```

### "Burn after reading" style
```PowerShell
PS > New-Push -Payload "Still secret text!" -ExpireAfterViews 1 -RetrievalStep
```

## PARAMETERS

### -Payload
The URL password or secret text to share.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Password

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Passphrase
Require recipients to enter this passphrase to view the created push.

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

### -Note
The note for this push. 
Visible only to the push creator.
Requires authentication.

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

### -ExpireAfterDays
Expire secret link and delete after this many days.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireAfterViews
Expire secret link and delete after this many views.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeletableByViewer
Allow the recipient of a Push to delete it.

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

### -RetrievalStep
Require recipient click an extra link to view Push payload.
Helps to avoid chat systems and URL scanners from eating up views.
Note that the retrieval step URL is always available for a push.
This
parameter changes if the 1-click link is used in the Link parameter
and returned from the secret link helper (Get-SecretLink)

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

### -AccountId
Account ID to associate with this push.
Requires a Pro subscription.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- [string] A password to send

## OUTPUTS

- [PasswordPush] Representation of the submitted push

## NOTES
Maximum for -ExpireAfterDays and -ExpireAfterViews is based on the default
values for Password Pusher and what's used on the public instance
(pwpush.com).
If you're using this with a private instance and want to
override that value you'll need to fork this module.

## RELATED LINKS

[New-Push](https://github.com/adamburley/PassPushPosh/blob/main/Docs/New-Push.md)

[Get-Push](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Push.md)

