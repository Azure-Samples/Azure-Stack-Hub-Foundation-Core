The Azure Stack Development Kit (ASDK) is a single-node deployment of Azure Stack Hub that you can download and use for free. All ASDK components are installed in virtual machines (VMs) running on a single host. This article explains how to deploy the ASDK in an Azure VM.

> Important
> The ASDK offers a free environment intended for Dev, Test, and gaining Operational knowledge. A couple of important notes on this:
> - There is **no support** offered for the ASDK or for the templates below.
> - Once you deploy an ASDK in an Azure VM, **do not clone it, snapshot it, or use the VHD of the deployed VM to create other VMs** - doing this can result in blocking your Azure Subscriptions. 
> - The template can be used to deploy multiple ASDKs - each should be deployed in separate VMs. **Do not clone or snapshot** these VMs once deployed.

For overall information on the ASDK, please check  https://docs.microsoft.com/azure-stack/asdk/asdk-what-is - this article will focus on deploying this as a solution in an Azure VM.

# Prereqs

Before starting, there are a few things to consider:

- You will need an Azure Subscription where we will deploy a VM large enough (default value is "Standard_E48s_v3") to support the ASDK.
- make sure you have the AAD name you plan to use for the ASDK deployment and a user that is a Global Admin in that AAD
- Create a storage account in the region where you plan to deploy the ASDK. In this storage account you will need to copy the VHD (the cloudbuilder.vhd file) so that the ARM template can use it. Once you create the Storage Account copy the CloudBuilder VHD from https://azstcenus2.blob.core.windows.net/azsforazure/Cloudbuilder.vhd (this will be used as a source for the Azure VM created, so it will not be changed and only needs to be copied once per region)

> one option to copy is to create a container in this Storage Account created previously (in the same region where you plan to deploy the ASDK), a SAS key, open CloudShell and run:
> azcopy copy 'https://azstcenus2.blob.core.windows.net/azsforazure/Cloudbuilder.vhd' 'https://yourstoraccountname.address/containername?SASkey'



# ASDK deployment

Once the cloudbuilder.vhd file is copied in the desired region/storage account, you can use [this ARM template](https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/blob/master/Tools/ASDKscripts/ASDKAzureVMTemplate.json) to trigger the deployment.

The template already has defaultValues for many of the parameters (which can be adjusted as needed) and you'll need to add:
- Admin Password - this will be CloudAdmin password (azurestack\AzureStackAdmin)
- VHD Uri - this will be the path to your CloudBuilder.vhd image that you've copied above
- to automate the deployment of the ASDK, you will also need to add teh "Azure Directory Tenant Name", "AAD User Name", "AAD Password", and "deployment type" set to AAD.

If you use the automated deployment (meaning you've included the AAD information), the VM deployment will also trigger the ASDK setup. Once teh Azure VM deployment is complete, you can login the VM using azurestack\AzureStackAdmin and monitor the actual deployment of the ASDK - this will take several hours.

> There are multiple ways of starting this deployment. One option is to use a "Template Deployment" in the Azure Portal and copy paste the ARM template above. Alternatively you can use PS to start it and fill the parameters directly - something similar to this (if you are not using CloudShell, remember to set the right AzContext):
> ```` Powershell
> $paramList = @{
>     #AAD Deployment
>     # required parameters are AdminPassword, vhdUri, 
>     # and for AAD deployments AADusername, AADPassword, and DeploymentType - rest of the parameters have defaultValues 
>     TemplateUri = "https://raw.githubusercontent.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/master/Tools/ASDKscripts/ASDKAzureVMTemplate.json"
>     vhdUri = 'https://yourstoraccountname.address/containername/Cloudbuilder.vhd'
>     vmName = 'asdk-VM-name'
>     Location = "East US"
>     DeploymentType = 'AAD'
>    AzureDirectoryTenantName = 'youraddname.onmicrosoft.com'
>    AADUserName = 'anAdmin@youraadname.onmicrosoft.com'
>    AADPassword = 'aadAPassword'
> }
> $resourceGroupName = "nameOftheRG"
> New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName @paramList
> ````

# Links and next steps

- overall ASDK information and install process - https://docs.microsoft.com/azure-stack/asdk/asdk-install  
- AzStackHub Foundation Core (videos and ppts) - https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/tree/master/ASF-Training
- AzStackHub Operator Workshop - https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/tree/master/ASF-Training/ASF-workshop
- AzStackHub Operator tools and scripts - https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/tree/master/Tools

