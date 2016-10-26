#Replace the URI with your Runbook's URI from the portal
$uri = "http://my.URI.here/webhooks?token=blah=="

$headers = @{"From"="Marcus";"SafeMode"="$True"}

$computerNames  = @(
            @{ Name="node1.fqdn.com"},
            @{ Name="node2.fqdn.com}
        )
$body = ConvertTo-Json -InputObject $computerNames

$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -Verbose