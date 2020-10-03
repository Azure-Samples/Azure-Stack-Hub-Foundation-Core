
#function used to capture the token used to auth from TokenCache
function Get-AzsResourceManagerAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object] $context
    )



    $profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile



    $profileClient = [Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient]::new($profile)



    $token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)



    return $token.AccessToken
}


#set the ARM-user-management-endpoint of the AzStackHub
$armendpoint="https://management.fqdn.of.the.stamp/"
Add-AzureRmEnvironment -Name "AzStackHub" -ARMEndpoint $armendpoint
$creds = [pscredential]::new("delegatedprovideruser@domainname.onmicrosoft.com", (ConvertTo-SecureString "password" -AsPlainText -Force))

Login-AzureRmAccount -Environment AzStackHub -Credential $Creds -Tenant 'tenantId'



$m = irm -Method Get -Uri $armendpoint/metadata/endpoints?api-version=1.0
$token=Get-AzsResourceManagerAccessToken -context (Get-AzureRMCOntext)
$g = [guid]::NewGuid()
$n = "nameofthenewusersub"
$b=@"
{
"id":"",
"subscriptionId":"$g",
"displayName":"$n",
"offerId":"/subscriptions/84b4ce01-1234-1234-1234-8f4c301e/resourceGroups/testRP/providers/Microsoft.Subscriptions/offers/offerd",
"state":"Enabled",
"owner":"enduser@domainname.onmicrosoft.com"
}
"@
$u = "${armendpoint}subscriptions/84b4ce01-1234-1234-1234-8f4c301e/providers/Microsoft.Subscriptions/subscriptions/${g}?api-version=2018-04-01"
Invoke-RestMethod -Method PUT -Uri $u -Headers @{  Authorization = "Bearer $token" } -ContentType "application/json" -Body $b 
