# Get-Push

## SYNOPSIS
Retrieve the secret contents of a Push

## SYNTAX

```powershell
Get-Push [-URLToken] <Object> [[-Passphrase] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-Push accepts a URL Token string and returns the contents of a Push along with
metadata regarding that Push.
Note: Get-Push will return data on an expired
Push (datestamps, etc) even if it does not return the Push contents.

## EXAMPLES

### EXAMPLE: Basic use
```powershell
Get-Push -URLToken gzv65wiiuciy
```

### EXAMPLE: Passphrase-protected Push
```powershell
Get-Push -URLToken gzv65wiiuciy -Passphrase "My Passphrase"
```

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

### -Passphrase
Passphrase required to view the secret. Required only if set for the original
Push.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- [string]

## OUTPUTS

- [PasswordPush]

## NOTES

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Push.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Push.md)

[https://pwpush.com/api/1.0/passwords.en.html](https://pwpush.com/api/1.0/passwords.en.html)

[https://github.com/pglombardo/PasswordPusher/blob/c2909b2d5f1315f9b66939c9fbc7fd47b0cfeb03/app/controllers/passwords_controller.rb#L89](https://github.com/pglombardo/PasswordPusher/blob/c2909b2d5f1315f9b66939c9fbc7fd47b0cfeb03/app/controllers/passwords_controller.rb#L89)