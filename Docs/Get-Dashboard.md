---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version:
schema: 2.0.0
---

# Get-Dashboard

## SYNOPSIS
Get a list of active or expired Pushes for an authenticated user

## SYNTAX

```
Get-Dashboard [[-Dashboard] <String>] [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a list of Pushes - active or expired - for an authenticated user.
Active and Expired are different endpoints, so to get both you'll need to make
two calls

## EXAMPLES

### EXAMPLE 1
```
Get-Dashboard
```

### EXAMPLE 2
```
Get-Dashboard Active
```

### EXAMPLE 3
```
Get-Dashboard -Dashboard 'Expired'
```

### EXAMPLE 4
```
Get-Dashboard -Raw
```

\[{"expire_after_days":1,"expire_after_views":5,"expired":false,"url_token":"xm3q7czvtdpmyg","created_at":"2022-11-19T18:10:42.055Z","updated_at":"2022-11-19T18:10:42.055Z","deleted":false,"deletable_by_viewer":true,"retrieval_step":false,"expired_on":null,"note":null,"days_remaining":1,"views_remaining":3}\]

## PARAMETERS

### -Dashboard
URL Token from a secret

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

### -Raw
Return content of API call directly

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

### [string] 'Active' or 'Expired'
## OUTPUTS

### [PasswordPush[]]
## NOTES
TODO rewrite and error-catching

## RELATED LINKS
