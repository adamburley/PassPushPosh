---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
schema: 2.0.0
---

# Remove-Push

## SYNOPSIS

Remove a Push

## SYNTAX

### Token (Default)

```powershell
Remove-Push [-URLToken <String>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Object

```powershell
Remove-Push [-PushObject <PasswordPush>] [-Raw] [-WhatIf] [-Confirm] [<CommonParameters>]
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
Remove-Push -URLToken -Raw
```

{"expired":true,"deleted":true,"expired_on":"2022-11-21T13:23:45.341Z","expire_after_days":1,"expire_after_views":4,"url_token":"bwzehzem_xu-","created_at":"2022-11-21T13:20:08.635Z","updated_at":"2022-11-21T13:23:45.342Z","deletable_by_viewer":true,"retrieval_step":false,"days_remaining":1,"views_remaining":4}

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

### [string] URL Token

### [PasswordPush] representing the Push to remove

## OUTPUTS

### [bool] True on success, otherwise False

## NOTES

TODO testing and debugging

## RELATED LINKS

[https://pwpush.com/api/1.0/passwords/destroy.en.html](https://pwpush.com/api/1.0/passwords/destroy.en.html)
