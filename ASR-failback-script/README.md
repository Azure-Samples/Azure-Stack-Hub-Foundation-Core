In a connected environment, you can use Azure Site Recovery to protect virtual machines (VMs) running on Azure Stack Hub. [This article](https://docs.microsoft.com/en-us/azure/site-recovery/azure-stack-site-recovery) describes how to set up the environment, and how Site Recovery helps contribute to the overall business continuity and disaster recovery strategy for these workloads.

In the event of an outage, the Azure Stack Hub operator goes through the failover procedure; once Azure Stack Hub is up and running again, they go through a failback process. The failover process is described in the ASR article above, but the failback process involves several manual steps:

* Stop the VM running in Azure.
* Download the VHDs.
* Upload the VHDs to Azure Stack Hub.
* Recreate the VMs.
* Finally, start that VM running on Azure Stack Hub.

As this process can be error prone and time consuming, we've built the scripts in this repo to help accelerate and automate this process.

check https://docs.microsoft.com/azure-stack/operator/site-recovery-failback to learn more about the overall process 
