# Remove-Push

## SYNOPSIS
Remove a Push

## SYNTAX

### Token (Default)
```powershell
Remove-Push [-URLToken <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Object
```powershell
Remove-Push [-PushObject <PasswordPush>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Remove (invalidate) an active push.
Requires the Push be either set as
deletable by viewer, or that you are authenticated as the creator of the
Push.

If you have authorization to delete a push (deletable by viewer TRUE or
you are the Push owner) the endpoint will always return 200 OK with a Push
object, regardless if the Push was previously deleted or expired.

If the Push URL Token is invalid OR you are not authorized to delete the
Push, the endpoint returns 404 and this function returns $false

## EXAMPLES

### EXAMPLE 1
```powershell
Remove-Push -URLToken bwzehzem_xu-
```

### EXAMPLE 2
```powershell
Remove-Push -URLToken
```

## PARAMETERS

### -URLToken
URL Token for the secret

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

### -PushObject
PasswordPush object

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

- [string] URL Token
- [PasswordPush] representing the Push to remove. **Note** this is not functional as of 1.0.0

## OUTPUTS

- [PasswordPush] The removed push

## NOTES

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Remove-Push.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Remove-Push.md)

[https://pwpush.com/api/1.0/passwords/destroy.en.html](https://pwpush.com/api/1.0/passwords/destroy.en.html)

