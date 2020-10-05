$FQDN = Read-Host "Enter External FQDN"
$RegionName = Read-Host "Enter Azure Stack Region Name"
$TenantId = Read-Host "Enter Tenant ID"
$keyVaultName = Read-Host "Enter New Vault Name"
$resourceGroupName= Read-Host "Enter New Resource Group Name"
$userPrincipalName= Read-Host "Enter User Principal"
$secretname= Read-Host "New Secret Name"

$environment=Add-AzureRmEnvironment -Name User -ARMEndpoint https://management.$regionname.$FQDN
$account=login-AzureRmAccount -Environment User -TenantId $TenantId

New-AzureRmResourceGroup -Name $resourceGroupName -Location $RegionName |out-null

New-AzureRmKeyVault `
  -VaultName $keyVaultName `
  -resourceGroupName $resourceGroupName `
  -Location $RegionName `
  -EnabledForTemplateDeployment


 
  
$tokens = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.TokenCache.ReadItems() 
$token = $tokens |Where Resource -EQ $Environment.ActiveDirectoryServiceEndpointResourceId |Where DisplayableId -EQ $Account.Context.Account.Id |Sort ExpiresOn |Select -Last 1 

 $commonRequestParams = @{
            ContentType = "application/json"
            Headers     = @{ Authorization = "Bearer $($token.accesstoken)" }
        }

$Headers = @{ 'authorization' = "Bearer $($Token.AccessToken)"} 
$requestUri = $environment.GraphUrl + $TenantId + "/users?`$filter=startswith(userPrincipalName,'$($userPrincipalName)')&api-version=1.6"
$userObject = (Invoke-WebRequest -UseBasicParsing @commonRequestParams -Uri $requestUri -ErrorAction Stop).Content | ConvertFrom-Json



Set-AzureRmKeyVaultAccessPolicy -BypassObjectIdValidation  -VaultName $keyVaultName -PermissionsToSecrets set,delete,get,list -ObjectId $userObject.value.objectId |out-null

#Adding an example Secret 
Add-Type -AssemblyName System.Web |out-null
$password = [System.Web.Security.Membership]::GeneratePassword(16,3)
write-host "Please store the passowrd secure" -ForegroundColor Green
write-host  $password -ForegroundColor Green
$secretvalue = ConvertTo-SecureString $password -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name "$secretname" -SecretValue $secretvalue |Out-Null

