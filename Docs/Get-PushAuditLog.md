# Get-PushAuditLog

## SYNOPSIS
Get the view log of an authenticated Push

## SYNTAX

```powershell
Get-PushAuditLog [-URLToken] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the view log of a Push created under an authenticated session.
Returns an array of custom objects with view data.
If the query is
successful but there are no results, it returns an empty array.
If there's an error, a single object is returned with information.
See "handling errors" under NOTES

## EXAMPLES

### EXAMPLE 1
```powershell
Get-PushAuditLog -URLToken 'mytokenfromapush'

ip         : 75.123.13.45,122.77.35.21
user_agent : Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101;
en-US) PowerShell/7.2.7
referrer   :
successful : True
created_at : 11/19/2022 6:32:42 PM
updated_at : 11/19/2022 6:32:42 PM
kind       : 0
```

### EXAMPLE 2
```powershell
# If there are no views, an empty array is returned
PS > $logs = Get-PushAuditLog -URLToken 'mytokenthatsneverbeenseen'
PS > $logs.Count # 0
```

## PARAMETERS

### -URLToken
URL Token from a secret

```yaml
Type: String
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

- [string]

## OUTPUTS

- [PsCustomObject[]] Array of entries.

## NOTES

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-PushAuditLog.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-PushAuditLog.md)

[https://pwpush.com/api/1.0/passwords/audit.en.html](https://pwpush.com/api/1.0/passwords/audit.en.html)