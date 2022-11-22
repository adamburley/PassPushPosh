---
external help file: PassPushPosh-help.xml
Module Name: PassPushPosh
online version:
schema: 2.0.0
---

# ConvertTo-PasswordPush

## SYNOPSIS

Convert API call response to a PasswordPush object

## SYNTAX

```powershell
ConvertTo-PasswordPush [-JsonResponse] <String> [<CommonParameters>]
```

## DESCRIPTION

Accepts a JSON string returned from the Password Pusher API and converts it to a \[PasswordPush\] object.
This allows calculated push retrieval URLs, language enumeration, and a more "PowerShell" experience.
Generally you won't need to use this directly, it's automatically invoked within Register-Push and Request-Push.

## EXAMPLES

### EXAMPLE 1

```powershell
# Common usage - from within the Register-Push cmdlet
PS> $myPush = Register-Push -Payload "This is my secret!"
PS> $myPush.Link  # The link parameter always presents the URL as it would appear with the same settings selected on pwpush.com
https://pwpush.com/en/p/rz6nryvl-d4
```

### EXAMPLE 2

```powershell
# Example with manually invoking the API
PS> $rawJson = Invoke-WebRequest  `
                -Uri https://pwpush.com/en/p.json `
                -Method Post `
                -Body '{"password": { "payload": "This is my secret!"}}' `
                -ContentType 'application/json' |
                Select-Object -ExpandProperty Content
PS> $rawJson

{"expire_after_days":7,"expire_after_views":5,"expired":false,"url_token":"rz6nryvl-d4","created_at":"2022-11-18T14:16:29.821Z","updated_at":"2022-11-18T14:16:29.821Z","deleted":false,"deletable_by_viewer":true,"retrieval_step":false,"expired_on":null,"days_remaining":7,"views_remaining":5}

PS\> $rawJson | ConvertTo-PasswordPush

UrlToken            : rz6nryvl-d4
LinkDirect          : <https://pwpush.com/en/p/rz6nryvl-d4>
LinkRetrievalStep   : <https://pwpush.com/en/p/rz6nryvl-d4/r>
Link                : <https://pwpush.com/en/p/rz6nryvl-d4>
Payload             :
Language            : en
RetrievalStep       : False
IsExpired           : False
IsDeleted           : False
IsDeletableByViewer : True
ExpireAfterDays     : 7
DaysRemaining       : 7
ExpireAfterViews    : 5
ViewsRemaining      : 5
DateCreated         : 11/18/2022 2:16:29 PM
DateUpdated         : 11/18/2022 2:16:29 PM
DateExpired         : 1/1/0001 12:00:00 AM
```

### EXAMPLE 3

```powershell
# Invoking for a multi-Push response - only coming from the Dashboard endpoint at this time.
PS > $webRequestResponse.Content | ConvertTo-PasswordPush -JsonIsArray
```

## PARAMETERS

### -JsonResponse

The string result of an API call from the Password Pusher application

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

### [string]

## OUTPUTS

### [PasswordPush] for single object

### [PasswordPush[]] for Json array data

## NOTES

Needs a rewrite / cleanup

## RELATED LINKS
