# Get-SecretLink

## SYNOPSIS
Returns a fully qualified secret link to a push of given URL Token

## SYNTAX

```
Get-SecretLink [-URLToken] <String> [-Raw] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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
https://pwpush.com/p/gzv65wiiuciy/r
```

### EXAMPLE 2
```
Get-SecretLink -URLToken gzv65wiiuciy -Raw
{ "url": "https://pwpush.com/p/0fkapnbo_pwp4gi8uy0/r" }
```

## PARAMETERS

### -URLToken
URL Token for the secret

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

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-SecretLink.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/Get-SecretLink.md)

[https://pwpush.com/api/1.0/passwords/preview.en.html](https://pwpush.com/api/1.0/passwords/preview.en.html)

