---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version:
schema: 2.0.0
---

# Get-Push

## SYNOPSIS

Retrieve the secret contents of a Push

## SYNTAX

```powershell
Get-Push [-URLToken] <Object> [-Raw] [<CommonParameters>]
```

## DESCRIPTION

Accepts a URL Token string, returns a Push object

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Push -URLToken gzv65wiiuciy

TODO example output
```

### EXAMPLE 2

```powershell
Get-Push -URLToken gzv65wiiuciy -Raw

TODO example output
```

## PARAMETERS

### -Raw

Returns raw json response from call

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

### -URLToken

URL Token for the secret

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Token

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string]

## OUTPUTS

### [PasswordPush]

## NOTES

TODO rewrite

## RELATED LINKS
