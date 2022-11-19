---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version:
schema: 2.0.0
---

# Get-PushAuditLog

## SYNOPSIS
Get the view log of an authenticated Push

## SYNTAX

```
Get-PushAuditLog [[-URLToken] <String>] [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the view log of a Push created under an authenticated session.

## EXAMPLES

### EXAMPLE 1
```
Get-PushAuditLog -URLToken 'mytokenfromapush'
```

## PARAMETERS

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

### -URLToken
URL Token from a secret

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### [PsCustomObject[]] Array of entries.
### [PsCustomObject] If there's an error in the call, it will be returned an object with a property
### named 'error'.  The value of that member will contain more information
## NOTES
General notes

## RELATED LINKS
