# Get-PushAccount

## SYNOPSIS
Get a list of accounts for an authenticated user with a Pro account.

## SYNTAX

```PowerShell
Get-PushAccount [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a list of accounts for an authenticated user.
This endpoint is only usable by Pro paid users. It will return an error in any other context.

## EXAMPLES

### Example 1
```PowerShell
PS C:\> Get-PushAccount
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

This function accepts no inputs by the pipeline

## OUTPUTS

[PSCustomObject]
