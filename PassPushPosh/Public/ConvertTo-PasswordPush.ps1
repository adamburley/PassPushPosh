function ConvertTo-PasswordPush {
    <#
    .SYNOPSIS
    Convert API call response to a PasswordPush object

    .DESCRIPTION
    Accepts a JSON string returned from the Password Pusher API and converts it to a [PasswordPush] object.
    This allows calculated push retrieval URLs, language enumeration, and a more "PowerShell" experience.
    Generally you won't need to use this directly, it's automatically invoked within Register-Push and Request-Push.

    .INPUTS
    [string]

    .OUTPUTS
    [PasswordPush] for single object
    [PasswordPush[]] for Json array data

    .EXAMPLE
    # Common usage - from within the Register-Push cmdlet
    PS> $myPush = Register-Push -Payload "This is my secret!"
    PS> $myPush.Link  # The link parameter always presents the URL as it would appear with the same settings selected on pwpush.com

    https://pwpush.com/en/p/rz6nryvl-d4

    .EXAMPLE
    # Manually invoking the API
    PS> $rawJson = Invoke-WebRequest  `
                    -Uri https://pwpush.com/en/p.json `
                    -Method Post `
                    -Body '{"password": { "payload": "This is my secret!"}}' `
                    -ContentType 'application/json' |
                    Select-Object -ExpandProperty Content
    PS> $rawJson
    {"expire_after_days":7,"expire_after_views":5,"expired":false,"url_token":"rz6nryvl-d4","created_at":"2022-11-18T14:16:29.821Z","updated_at":"2022-11-18T14:16:29.821Z","deleted":false,"deletable_by_viewer":true,"retrieval_step":false,"expired_on":null,"days_remaining":7,"views_remaining":5}
    PS> $rawJson | ConvertTo-PasswordPush
    UrlToken            : rz6nryvl-d4
    LinkDirect          : https://pwpush.com/en/p/rz6nryvl-d4
    LinkRetrievalStep   : https://pwpush.com/en/p/rz6nryvl-d4/r
    Link                : https://pwpush.com/en/p/rz6nryvl-d4
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

    .LINK
    https://github.com/adamburley/PassPushPosh/blob/main/Docs/ConvertTo-PasswordPush.md
    
    .NOTES
    Needs a rewrite / cleanup
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function', Justification = 'Creates a new object, no risk of overwriting data.')]
    [CmdletBinding()]
    [OutputType([PasswordPush])]
    param(
        # The string result of an API call from the Password Pusher application
        [parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$JsonResponse
    )
    process {
        try {
            $jsonObject = $JsonResponse | ConvertFrom-Json
            foreach ($o in $jsonObject) {
                [PasswordPush]($o | ConvertTo-Json) # TODO fix this mess
            }
        }
        catch {
            Write-Debug 'Error in ConvertTo-PasswordPush coercing JSON object to PasswordPush object'
            Write-Debug "JsonResponse parameter value: [[$JsonResponse]]"
            Write-Error $_
        }
    }
}