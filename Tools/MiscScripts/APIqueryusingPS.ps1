#use PS to pull API queries for Alerts

$regionName ="local"
$armEndpoint = "https://adminmanagement.local.azurestack.external"
$tenantName = "asdktest1.onmicrosoft.com"

function Get-AzureRmCachedAccessToken()
{
    $ErrorActionPreference = 'Stop'
  
    if(-not (Get-Module AzureRm.Profile)) {
        Import-Module AzureRm.Profile
    }
    $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
    # refactoring performed in AzureRm.Profile v3.0 or later
    if($azureRmProfileModuleVersion.Major -ge 3) {
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        if(-not $azureRmProfile.Accounts.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    } else {
        # AzureRm.Profile < v3.0
        $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
        if(-not $azureRmProfile.Context.Account.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
  
    $currentAzureContext = Get-AzureRmContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Tenant.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    $token.AccessToken
}

function Get-AzureRmBearerToken()
{
    $ErrorActionPreference = 'Stop'
    ('Bearer {0}' -f (Get-AzureRmCachedAccessToken))
}

# Generic method to call an API with a Bearer token
function Send-WebRequest {
    param(
    [string] $Uri
    )

    $request = @{
        Uri = $Uri
        Method = "GET"
        Headers = @{ "Authorization" = Get-AzureRmBearerToken }
        ContentType = "application/json"
    }

    return Invoke-RestMethod @request

}

#connect to AzStackHub env
Add-AzureRmEnvironment -Name "admin" -ARMEndpoint  $armEndpoint
Add-AzureRmAccount -Environment "admin" -TenantId $tenantName


#Get Subscription Id for $subscriptionName
$defaultProviderSubscriptionId = ((Send-WebRequest -Uri ("{0}/subscriptions?api-version=2014-04-01-preview" -f $armEndpoint)).value | Where-Object {$_.displayName -eq "Default Provider Subscription"}).subscriptionId

#ALERT PROPERTIES
$state="State%20%20eq%20'Active'%20or%20Properties%2FState%20%20eq%20'Closed'"
#$state="State%20%20eq%20'Active'"

$alerts = @((Send-WebRequest -Uri ("{0}/subscriptions/{1}/resourceGroups/system.{2}/providers/Microsoft.InfrastructureInsights.Admin/regionHealths/{2}/Alerts?api-version=2016-05-01&%24filter=(Properties%2F{3})%20and%20(Properties%2FSeverity%20%20eq%20'Critical'%20or%20Properties%2FSeverity%20%20eq%20'Warning')&%24orderby=Properties%2FLastUpdatedTimestamp%20desc" -f $armEndpoint, $defaultProviderSubscriptionId, $regionName, $state)).value)

# $alerts.Count

# $alerts | select id

# Filter from a list of all alerts Alerts by ID
$alerts | where {$_.id -eq $alertID} | ConvertTo-Json

# Get Alert by ID

$alertDetails = Send-WebRequest -Uri ("{0}{1}?api-version=2016-05-01" -f $armEndpoint, $alertID) 
$alertDetails | ConvertTo-Json
