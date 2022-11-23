# Get-Push

## SYNOPSIS

Retrieve the secret contents of a Push

## SYNTAX

```powershell
Get-Push [-URLToken] <Object> [-Raw] [<CommonParameters>]
```

## DESCRIPTION

Accepts a URL Token string, returns the contents of a Push along with
metadata regarding that Push.
Note, Get-Push will return data on an expired
Push (datestamps, etc) even if it does not return the Push contents.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Push -URLToken gzv65wiiuciy
```

### EXAMPLE 2

```powershell
Get-Push -URLToken gzv65wiiuciy -Raw
```

{"payload":"I am your payload!","expired":false,"deleted":false,"expired_on":"","expire_after_days":1,"expire_after_views":4,"url_token":"bwzehzem_xu-","created_at":"2022-11-21T13:20:08.635Z","updated_at":"2022-11-21T13:23:45.342Z","deletable_by_viewer":true,"retrieval_step":false,"days_remaining":1,"views_remaining":4}

## PARAMETERS

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string]

## OUTPUTS

### [PasswordPush] or [string]

## NOTES

## RELATED LINKS

- [Password Pusher API Documentation](https://pwpush.com/api/1.0/passwords/show.en.html)
- [New-Push](New-Push.md)
