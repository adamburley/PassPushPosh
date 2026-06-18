$splat = @{
    'uri' = 'https://secret.burley.dev/p.json'
    'method' = 'Post'
    'headers' = @{
        "Authorization" = "Bearer cgthUB5jBJrucAJ5JSQqw4bP"
        "Accept" = 'application/json'
        'Content-Type' = 'application/json'
    }
    'body' = @{ 
        password = @{
            'payload' = 'i am a test'
            #'expire_after_duration' = 1
            'expire_after_days' = $null
        }
    } | ConvertTo-Json
}
irm @splat