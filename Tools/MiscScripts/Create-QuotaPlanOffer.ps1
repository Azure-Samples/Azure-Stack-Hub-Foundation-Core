$FQDN = Read-Host "Enter External FQDN"
$RegionName = Read-Host "Enter Azure Stack Region Name"
$TenantID = Read-Host "Enter TenantID"
$OfferName = Read-Host "Enter New Offer Name"
$PlanName = Read-Host "Enter New Plan Name"
$RGName = Read-Host "Enter New Resource Group Name"



#Add Environment & Authenticate
Add-AzureRmEnvironment -Name AzureStackAdmin -ARMEndpoint https://adminmanagement.$RegionName.$FQDN |Out-Null
Login-AzureRmAccount -Environment AzureStackAdmin -TenantId $TenantID |Out-Null

#Create Compute Quota
$ComputeQuota=New-AzsComputeQuota -Name ComputeQuota -CoresLimit 100 -AvailabilitySetCount 50 -VmScaleSetCount 50 -VirtualMachineCount 100

#Create Network Quota
$NetworkQuota=New-AzsNetworkQuota -Name NetworkQuota -MaxNicsPerSubscription 100 -MaxPublicIpsPerSubscription 5 -MaxVirtualNetworkGatewaysPerSubscription 1 -MaxVirtualNetworkGatewayConnectionsPerSubscription 2 -MaxVnetsPerSubscription 50 -MaxSecurityGroupsPerSubscription 50 -MaxLoadBalancersPerSubscription 50

#Create Storage Quota
$StorageQuota=New-AzsStorageQuota -Name StorageQuota -CapacityInGb 1024 -NumberOfStorageAccounts 10

#Get KeyVault Quota
$KeyVaultQuota=Get-AzsKeyVaultQuota

#Create new Plan & Assign Quotas
$quota=($ComputeQuota.id,$NetworkQuota.id,$StorageQuota.Id,$KeyVaultQuota.Id)
$ResoureGroup=New-AzureRmResourceGroup -Name $RGName -Location local
$Plan=New-AzsPlan -Name $PlanName -ResourceGroupName $ResoureGroup.ResourceGroupName -DisplayName SamplePlan -QuotaIds $quota

#Create Offer
$Offer=New-AzsOffer -Name $OfferName -DisplayName SampleOffer -ResourceGroupName $ResoureGroup.ResourceGroupName -BasePlanIds $plan.Id

#Make Offer Public
Set-AzsOffer -Name $offer.Name -State public -ResourceGroupName $ResoureGroup.ResourceGroupName


#Create Subcription
$sub=New-AzsUserSubscription -OfferId $Offer.Id -Owner subscriptionowner@fabrikam.com -DisplayName MySubscription
$Id=$sub.SubscriptionId

# Create AddOn Plan and assign to single subscription
#1 Create new Plan that will be used as add on Plan, using same resources & Quotas as base plan
$PlanAddOn=New-AzsPlan -Name "MyAddOn" -ResourceGroupName $ResoureGroup.ResourceGroupName -DisplayName MyAddOnPlan -QuotaIds $quota
#2 Create AddOn PLan definition Object
$addondef=New-AzsAddonPlanDefinitionObject -PlanId $planAddOn.Id -MaxAcquisitionCount 1
#3Assign AddOn Plan to Subscription
New-AzsSubscriptionPlan -PlanId $addondef.PlanId -TargetSubscriptionId $Id 


#Login into the Tenant Subscription as Owner
Add-AzureRmEnvironment -Name AzureStackUser -ARMEndpoint https://management.$RegionName.$FQDN |Out-Null
Login-AzureRmAccount -Environment AzureStackUser  |Out-Null

#RBAC Additional User
New-AzureRmRoleAssignment -SignInName "bob@fabrikam.com" -RoleDefinitionName Contributor -Scope "/subscriptions/$id"







