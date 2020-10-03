$FQDN = Read-Host "Enter External FQDN"
$RegionName = Read-Host "Enter Azure Stack Region Name"
$TenantId = Read-Host "Enter Tenant ID"
$Cluster = Read-Host "Enter Scale Unit Name"


$environment=Add-AzureRmEnvironment -Name Admin -ARMEndpoint https://adminmanagement.$regionname.$FQDN
$account=login-AzureRmAccount -Environment Admin -TenantId $TenantId
$subscription=Get-AzureRmSubscription | ? {$_.name -eq "Default Provider Subscription"}
$subscriptionId=$subscription.Id

  
$tokens = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.TokenCache.ReadItems() 
$token = $tokens |Where Resource -EQ $Environment.ActiveDirectoryServiceEndpointResourceId |Where DisplayableId -EQ $Account.Context.Account.Id |Sort ExpiresOn |Select -Last 1 

 $commonRequestParams = @{
            ContentType = "application/json"
            Headers     = @{ Authorization = "Bearer $($token.accesstoken)" }
        }

$Headers = @{ 'authorization' = "Bearer $($Token.AccessToken)"}

$requestUriStorage = $environment.ResourceManagerUrl+ "/subscriptions/$SubscriptionId/resourceGroups/system.$RegionName/providers/Microsoft.Fabric.Admin/fabricLocations/$RegionName/scaleUnits/$cluster/storageSubSystems?&api-version=2018-10-01"
$QueryStorageSystem = (Invoke-WebRequest -UseBasicParsing @commonRequestParams -Uri $requestUriStorage -ErrorAction Stop).Content | ConvertFrom-Json
$QueryStorageResult=$QueryStorageSystem.value.name
$StorageName=$QueryStorageResult.split('/')[2]


$RequestUriDrive = $environment.ResourceManagerUrl+ "/subscriptions/$SubscriptionId/resourceGroups/system.$RegionName/providers/Microsoft.Fabric.Admin/fabricLocations/$RegionName/scaleUnits/$cluster/storageSubSystems/$storagename/drives?&api-version=2018-10-01"
$QueryDrive = (Invoke-WebRequest -UseBasicParsing @commonRequestParams -Uri $RequestUriDrive -ErrorAction Stop).Content | ConvertFrom-Json
$Drives=$QueryDrive.value.properties

$Whitelist=get-content ".\disks.xml"


Foreach ($drive in $Drives) {

If ($Whitelist -notcontains $Drive.model){
Write-Host "A not support Drive was found, please contact Hardware Partner Support before applying the OEM Update Package. Report the the following drive model "$Drive.model"" -ForegroundColor Red
}


}