# Automate delegated user subscription creation

In the Delegated Provider scenario, there might be a need to automate the creation of a user-subscription. This following script provides guidance on creating this automation scrip.

When following [Delegating offers in Azure Stack Hub - Azure Stack Hub](https://docs.microsoft.com/azure-stack/operator/azure-stack-delegated-provider) process, it involves two main steps:

- Create the delegated provider itself, create the quotas/plans/offers that are then delegated to this delegated provider user (this is done on the admin-portal)
- The delegated provider user would then go on the user-portal, create an offer based on that delegated offer, and then is able to create user-subscriptions for the “end-user”

> the Delegated Provider scenario is a complex topic to grasp *at first*. Please check the [Delegating offers in Azure Stack Hub - Azure Stack Hub](https://docs.microsoft.com/azure-stack/operator/azure-stack-delegated-provider) documentation for more information on how to create Delegated Offers in Azure Stack Hub.

Based on the APIs that are called through the portal, we’ve put together the following script (which essentially is just an API call).

## Prereqs

- ARM user management endpoint
- Credentials of the Delegated Provider User
- TenantID – the TenantID of the AAD used to authenticate (easier when doing the login – in case multiple subscriptions exist, check the context using “get-azurermcontext”)
- SubscriptionID - of the delegated subscription (used by the Delegated Provider User) - in the example it's the "84b4ce01-1234-1234-1234-8f4c301e" that needs to be replaced in the script below
- Offer Name - created by the Delegated Provider User, based on the offers that were delegated to this user - in the example it's "offerd"
