---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version: https://pwpush.com/api/1.0/passwords/preview.en.html
schema: 2.0.0
---

# Remove-Push

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Token (Default)
```
Remove-Push [-URLToken <String>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Object
```
Remove-Push [-PushObject <PasswordPush>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -PushObject
{{ Fill PushObject Description }}

```yaml
Type: PasswordPush
Parameter Sets: Object
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Raw
{{ Fill Raw Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URLToken
{{ Fill URLToken Description }}

```yaml
Type: String
Parameter Sets: Token
Aliases: Token

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string] URL Token
### [PasswordPush] representing the Push to remove
## OUTPUTS

### [bool] True on success, otherwise False
## NOTES

## RELATED LINKS
