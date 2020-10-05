# Secure Operator Role

Sample script and role template that creates a new RBAC role with all permissions except to create or update user subscriptions

## Scenario

Every user object that has Owner or Contributor permission to the default provider subscription can overwrite the owner of ANY user subscription.  This is by design for example to change the billing owner of a subscription when a user leaves your organization.  This is described in the [Change the billing owner for an Azure Stack Hub user subscription](https://docs.microsoft.com/azure-stack/operator/azure-stack-change-subscription-owner) article.

## Best Practices

- The Owner permissions to the default provider subscription should only be granted to a single user with a secure password and locked away.
- Create custom roles with only permissions required for the day to day operations
- Use strong passwords
- Multi Factor authentication should be enabled for all users having access to the default provider subscription
- When using Azure Active Directory use conditional access


## Samples

- Secure Operator Role grants the same permission as the Onwer Role except the permission to create or update any user subscription.
- To create your own 'roleDefinition.json' file, you can follow these steps to get the original 'Owner' rights which you can then change:

    ``` powershell
    $ArmEndpoint="https://adminmanagement.region.fqnd"
    Add-AzEnvironment -ARMEndpoint $ArmEndpoint -Name AdminARM
    connect-azaccount -Environment AdminARM

    Get-AzureRmRoleDefinition 'Owner' | ConvertTo-Json

    ```

## How to use

### Requirements

- PowerShell Core - https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7#powershell-core
- Azure Stack Powershell AZ - https://docs.microsoft.com/en-us/azure-stack/operator/powershell-install-az-module?view=azs-2002

### Example

CreateNewRole.ps1

## Additional Information

- [How to create custom roles](https://docs.microsoft.com/azure/role-based-access-control/custom-roles)
- [Azure Stack Admin API reference with documented operations](https://docs.microsoft.com/rest/api/azure-stack/)