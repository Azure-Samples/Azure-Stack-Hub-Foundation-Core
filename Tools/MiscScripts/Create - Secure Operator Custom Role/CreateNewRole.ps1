
# Set up Azure Stack Hub admin environment
$ArmEndpoint="https://adminmanagement.region.fqnd"
Add-AzEnvironment -ARMEndpoint $ArmEndpoint -Name AdminARM
connect-azaccount -Environment AdminARM

# Select admin subscription
$providerSubscriptionId = (Get-AzSubscription -SubscriptionName "Default Provider Subscription").Id
Write-Output "Put the following ID into the JSON Role Template for Scope: $providerSubscriptionId"
Set-AzContext -Subscription $providerSubscriptionId

Read-Host -prompt "Only proceed after updating the Template with the deafult provider subscriotion ID"
#Create New Operator Role
New-AzRoleDefinition -InputFile ./SecureOperatorRole.json