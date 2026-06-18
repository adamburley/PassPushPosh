# New-Push

## SYNOPSIS
Create a new Push

## SYNTAX

### Text (Default)
```powershell
New-Push [[-Payload] <String>] [-File <Object[]>] [-Passphrase <String>] [-Note <String>]
 [-ExpireAfterDays <Int32>] [-ExpireAfterViews <Int32>] [-DeletableByViewer] [-RetrievalStep]
 [-AccountId <Object>] [-Kind <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### QR
```powershell
New-Push -QR <String> [-File <Object[]>] [-Passphrase <String>] [-Note <String>] [-ExpireAfterDays <Int32>]
 [-ExpireAfterViews <Int32>] [-DeletableByViewer] [-RetrievalStep] [-AccountId <Object>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### URL
```powershell
New-Push -URL <String> [-Passphrase <String>] [-Note <String>] [-ExpireAfterDays <Int32>]
 [-ExpireAfterViews <Int32>] [-DeletableByViewer] [-RetrievalStep] [-AccountId <Object>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new Push on the specified Password Pusher instance.
The
programmatic equivalent of going to pwpush.com and entering info.
Returns \[PasswordPush\] object.
Link member is a link created based on
1-step setting however both 1-step and direct links
are always provided at LinkRetrievalStep and LinkDirect properties.

## EXAMPLES

### Basic Use
```powershell
$myPush = New-Push "Here's my secret!"
PS > $myPush | Select-Object Link, LinkRetrievalStep, LinkDirect

Link              : https://pwpush.com/p/gzv65wiiuciy   # Requested style
LinkRetrievalStep : https://pwpush.com/p/gzv65wiiuciy/r # 1-step
LinkDirect        : https://pwpush.com/p/gzv65wiiuciy   # Direct
```

### EXAMPLE 2
```powershell
"Super secret secret" | New-Push -RetrievalStep | Select-Object -ExpandProperty Link

https://pwpush.com/p/gzv65wiiuciy/r
```

### EXAMPLE 3
```powershell
# "Burn after reading" style Push
PS > New-Push -Payload "Still secret text!" -ExpireAfterViews 1 -RetrievalStep
```

### EXAMPLE 4
```powershell
Create a URL push
PS > New-Push -URL 'https://example.com/coolplacetoforwardmyrecipientto'
```

### EXAMPLE 5
```powershell
Create a QR push
PS > New-Push -QR 'thing i want to show up when someone reads the QR code'
```

### EXAMPLE 6
```powershell
Create a file push
PS > New-Push -File 'C:\mytwofiles\mycoolfile.txt', 'C:\mytwofiles\mycoolfile2.txt'
#or
PS > New-Push -File 'C:\mytwofiles'
#or
PS > $myFolder = Get-ChildItem C:\mytwofiles
PS > New-Push -File $myFolder
```

### EXAMPLE 7
```powershell
Create a QR push using -Payload
PS > New-Push -Payload 'this is my qr code value' -Kind QR
```

## PARAMETERS

### -Payload
Generic text value to share.
Use with -Kind to create arbitrary push types.
Payload is required for all types except File.
For QR and URL pushes you
may directly specify those types by using the -QR and -URL parameters.

```yaml
Type: String
Parameter Sets: Text
Aliases: Password

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -QR
Create a QR-type secret with this text value.
May be a link or other text.

```yaml
Type: String
Parameter Sets: QR
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URL
Create a URL-type secret redirecting to this link.
A fully-qualified URL is
required

```yaml
Type: String
Parameter Sets: URL
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -File
Attach files to a push.
Up to 10 files in all referenced folders and paths
may be specified by passing a file or folder path or array of paths or a
DirectoryInfo or FileInfo object.

File pushes can be files only, files with text, or files with a QR code.
To add text, simply use -Payload.
To specify a QR code, use -QR or use
-Payload 'your value' -Type QR

```yaml
Type: Object[]
Parameter Sets: Text, QR
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passphrase
Require recipients to enter this passphrase to view the created push.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Note
The note for this push.
Visible only to the push creator.
Requires authentication.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireAfterDays
Expire secret link and delete after this many days.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpireAfterViews
Expire secret link and delete after this many views.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeletableByViewer
Allow the recipient of a Push to delete it.

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

### -RetrievalStep
Require recipient click an extra link to view Push payload.
Helps to avoid chat systems and URL scanners from eating up views.
Note that the retrieval step URL is always available for a push.
This
parameter changes if the 1-click link is used in the Link parameter
and returned from the secret link helper (Get-SecretLink)

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

### -AccountId
Account ID to associate with this push.
Requires authentication.
If you have multiple accounts and you do not specify an account ID
Password Pusher will use the first account available, UNLESS you have a custom domain.
In that case it will default to the custom domain account IF you're connecting
to the custom domain for the API session.
If you're connecting to pwpush.com,
it will use the unbranded / non-domain account.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind
The kind of Push to send.
Defaults to text.
If using -QR, -URL, or -File parameters
the correct kind is automatically selected and this parameter is ignored.

```yaml
Type: String
Parameter Sets: Text
Aliases:

Required: False
Position: Named
Default value: Text
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

### [string]
## OUTPUTS

### [PasswordPush] Representation of the submitted push
## NOTES
Maximum for -ExpireAfterDays and -ExpireAfterViews is based on the default
values for Password Pusher and what's used on the public instance
(pwpush.com).

## RELATED LINKS

[https://github.com/adamburley/PassPushPosh/blob/main/Docs/New-Push.md](https://github.com/adamburley/PassPushPosh/blob/main/Docs/New-Push.md)

[Get-Push]()

