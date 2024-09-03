# Get-Dashboard

## SYNOPSIS
Get a list of active or expired Pushes for an authenticated user

## SYNTAX

```
Get-Dashboard [[-Dashboard] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a list of Pushes - active or expired - for an authenticated user.
Active and Expired are different endpoints, so to get both you'll need to make
two calls.

## EXAMPLES

### EXAMPLE 1
```
Get-Dashboard
```

### EXAMPLE 2
```
Get-Dashboard Active
```

## PARAMETERS

### -Dashboard
The type of dashboard to retrieve.
Active or Expired.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Active
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string] 'Active' or 'Expired'
## OUTPUTS

### [PasswordPush[]] Array of pushes with data
## NOTES

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Dashboard.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-Dashboard.md)

[https://pwpush.com/api/1.0/passwords/active.en.html](https://pwpush.com/api/1.0/passwords/active.en.html)

[Get-PushAuditLog]()

