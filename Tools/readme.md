# AzStackHub Tools

This repo is intended to capture some of the tools used by Azure Stack Hub Operators and to provide them as example that you can build from. 
Most of these scripts are small snippets which can, and should be, included in your own automation. As most of them are generalized scripts, you will need to configure them according to your own environment.

* ARMRequests-Postman

    > These are files used in the configuration of POSTMAN.

* Delegated sub creation

    > script to automate user-subscription creation, when using Delegated Providers


* MiscTools - multiple tools used for various operator activities
  
    > - CheckDriveModel.ps1 - check the Drive Models against the whitelisted/expected values
    > - CreateKeyVaultADFS.ps1 - create KeyVault in an ADFS env - full documentation found in the [Manage Key Vault in Azure Stack Hub using PowerShell](https://docs.microsoft.com/azure-stack/user/azure-stack-key-vault-manage-powershell) article
    > - ShowAzsMetrics.ps1 - show metrics used by the fabric roles (links to full documentation in the script for each role)
    > - ShowEndpoints.ps1 - show the endpoints used by AzStackHub
    > - Create-QuotaPlanOffer.ps1 - example of automating the creation of quotas/plans/offers
    > - Create-Secure Operator Custom Role - steps to create an customer Operator RBAC role without rights to take ownership of user subscriptions
    > - GetDiskHealthPerNode.ps1 - script to check health of disks via admin ARM endpoint
    > - APIqueryusingPS.ps1 - example of using PS to pull API queries for Alerts
    
