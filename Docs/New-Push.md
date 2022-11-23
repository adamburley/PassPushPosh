---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
schema: 2.0.0
---

# New-Push

## SYNOPSIS

Create a new Password Push

## SYNTAX

### Anonymous (Default)

```powershell
New-Push [-Payload] <String> [-ExpireAfterDays <Int32>] [-ExpireAfterViews <Int32>] [-DeletableByViewer]
 [-RetrievalStep] [-Language <String>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RequiresAuthentication

```powershell
New-Push [-Payload] <String> [-Note <String>] [-ExpireAfterDays <Int32>] [-ExpireAfterViews <Int32>]
 [-DeletableByViewer] [-RetrievalStep] [-Language <String>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Create a new Push on the specified Password Pusher instance.
The
programmatic equivalent of going to pwpush.com and entering info.
Returns \[PasswordPush\] object.
Link member is a link created based on
1-step setting and language specified, however both 1-step and direct links
are always provided at LinkRetrievalStep and LinkDirect.

## EXAMPLES

### EXAMPLE 1

```powershell
$myPush = New-Push "Here's my secret!"
PS > $myPush | Select-Object Link, LinkRetrievalStep, LinkDirect
```

Link              : https://pwpush.com/en/p/gzv65wiiuciy   # Requested style
LinkRetrievalStep : https://pwpush.com/en/p/gzv65wiiuciy/r # 1-step
LinkDirect        : https://pwpush.com/en/p/gzv65wiiuciy   # Direct

### EXAMPLE 2

```powershell
"Super secret secret" | New-Push -RetrievalStep | Select-Object -ExpandProperty Link
```

https://pwpush.com/en/p/gzv65wiiuciy/r

### EXAMPLE 3

```powershell
# "Burn after reading" style Push

PS > New-Push -Payload "Still secret text!" -ExpireAfterViews 1 -RetrievalStep
```

## PARAMETERS

### -Payload

The password or secret text to share.

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

### -Note

Label for this Push (requires Authenticated session)

```yaml
Type: String
Parameter Sets: RequiresAuthentication
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

Expire secret link after this many views.

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

### -Language

Override Language.
Useful if sending to someone who speaks a
different language.
You can change this after the fact by changing
the URL by hand or by requesting a link for the given token from the
preview helper endpoint ( See Request-SecretLink )

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

### -Raw

Return the raw response body from the API call

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

### [string]

## OUTPUTS

### [PasswordPush] Push object* Note this is defined as [PSCustomObject] in the

### OutputType function attribute. See Issue [TODO: add issue number]

### [string] Raw result of API call

### [bool] Fail on error

## NOTES

Maximum for -ExpireAfterDays and -ExpireAfterViews is based on the default
values for Password Pusher and what's used on the public instance
(pwpush.com).
If you're using this with a private instance and want to
override that value you'll need to fork this module.

TODO: Support \[PasswordPush\] input objects

## RELATED LINKS

[https://pwpush.com/api/1.0/passwords/create.en.html
Get-Push](https://pwpush.com/api/1.0/passwords/create.en.html
Get-Push)

[https://pwpush.com/api/1.0/passwords/create.en.html
Get-Push]()
