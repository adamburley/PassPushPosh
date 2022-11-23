# Get-PushAuditLog

## SYNOPSIS

Get the view log of an authenticated Push

## SYNTAX

```powershell
Get-PushAuditLog [[-URLToken] <String>] [-Raw] [<CommonParameters>]
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
```

ip         : 75.202.43.56,102.70.135.200
user_agent : Mozilla/5.0 (Macintosh; Darwin 21.6.0 Darwin Kernel Version 21.6.0: Mon Aug 22 20:20:05 PDT 2022; root:xnu-8020.140.49~2/RELEASE_ARM64_T8101;
en-US) PowerShell/7.2.7
referrer   :
successful : True
created_at : 11/19/2022 6:32:42 PM
updated_at : 11/19/2022 6:32:42 PM
kind       : 0

### EXAMPLE 2

```powershell
# If there are no views, an empty array is returned

Get-PushAuditLog -URLToken 'mytokenthatsneverbeenseen'
```

## PARAMETERS

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

### [string]

## OUTPUTS

### [PsCustomObject[]] Array of entries.

### [PsCustomObject] If there's an error in the call, it will be returned an object with a property

### named 'error'.  The value of that member will contain more information

## NOTES

Handling Errors:
The API returns different HTTP status codes and results depending where the
call fails.

|  HTTP RESPONSE   |            Error Reason         |                Response Body                 |                                    Sample Object Returned                                  |                                                             Note                                                           |
|------------------|---------------------------------|----------------------------------------------|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| 401 UNAUTHORIZED | Invalid API key or email        | None                                         | @{ 'Error'= 'Authentication error. Verify email address and API key.'; 'ErrorCode'= 401 }  |                                                                                                                            |
| 200 OK           | Push created by another account | {"error":"That push doesn't belong to you."} | @{ 'Error'= "That Push doesn't belong to you"; 'ErrorCode'= 403 }                          | Function transforms error code to 403 to allow easier response management                                                  |
| 404 NOT FOUND    | Invalid URL token               | None                                         | @{ 'Error'= 'Invalid token. Verify your Push URL token is correct.'; 'ErrorCode'= 404 }    | This is different than the response to a delete Push query - in this case it will only return 404 if the token is invalid. |

## RELATED LINKS

- [Password Pusher API Documentation](https://pwpush.com/api/1.0/passwords/audit.en.html)
