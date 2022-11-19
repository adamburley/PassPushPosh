---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version: https://pwpush.com/api/1.0/passwords/preview.en.html
schema: 2.0.0
---

# Get-SecretLink

## SYNOPSIS
Returns a fully qualified secret link to a push of given URL Token

## SYNTAX

```
Get-SecretLink [-URLToken] <String> [[-Language] <String>] [<CommonParameters>]
```

## DESCRIPTION
Accepts a string value for a URL Token and retrieves a full URL link to the secret.
Returned value is a 1-step retrieval link depending on option selected during Push creation.
Returns false if URL Token is invalid, however it will return a URL if the token is valid
but the Push is expired or deleted.

## EXAMPLES

### EXAMPLE 1
```
Get-SecretLink -URLToken gzv65wiiuciy
https://pwpush.com/en/p/gzv65wiiuciy/r
```

### EXAMPLE 2
```
# En France
PS > Get-SecretLink -URLToken gzv65wiiuciy -Language fr
https://pwpush.com/fr/p/gzv65wiiuciy/r
```

## PARAMETERS

### -Language
Language for returned links.
Defaults to system language, can be overridden here.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: En
Accept pipeline input: False
Accept wildcard characters: False
```

### -URLToken
Secret URL token of a previously created push.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string] URL Token value
## OUTPUTS

### [string] Fully qualified URL
### [bool] $False if Push URL Token is invalid. Note: Expired or deleted Pushes will still return a link.
## NOTES
Including this endpoint for completeness - however it is generally unnecessary.
The only thing this endpoint does is return a different value depending if "Use 1-click retrieval step"
was selected when the Push was created. 
Since both the 1-click and the direct links are available
regardless if that option is selected, the links are calculable and both are included by default in a
\[PasswordPush\] object.

As it returns false if a Push URL token is not valid you can use it to test if a Push exists without
burning a view.

## RELATED LINKS

[https://pwpush.com/api/1.0/passwords/preview.en.html](https://pwpush.com/api/1.0/passwords/preview.en.html)

