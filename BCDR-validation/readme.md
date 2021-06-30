# Business Continuity and Disaster Recovery (BCDR) solutions for Azure Stack Hub

This program focuses on validation of Business Continuity and Disaster Recovery (BCDR) solutions and migration solutions, on Azure Stack Hub. It is aimed to simplify the path to production-ready of your cloud infrastructure, when running workloads in your datacenter, on Azure Stack Hub.

Cloud operators and users of Azure Stack Hub deploying applications and datasets need the ability to quickly recover from data loss and catastrophic failures. With offerings from multiple partners, you can enable data protection and disaster recovery for your applications and data. The full list of BCDR partners can be found in the [Azure Stack Datacenter Integration Partner Ecosystem](https://aka.ms/azurestackbcdrpartners) white paper. This program focuses on a subset of those partners and is aimed at testing real-world, end-to-end, scenarios.

## Overview

The validation consists of three main scenarios:

 - Protecting VMs from Azure Stack Hub to the same and another Azure Stack Hub (stamp to stamp)
 - Moving workloads from one Azure Stack Hub to another Azure Stack Hub
 - Migrating VMs to Azure Stack Hub

Each of these scenarios will be completed with differently sized environments, aimed to simulate real-world scenarios.

We have an iterative approach and aim to improve each round of testing. You can find more information on the next rounds in this article. The first tests were done on two systems:

 - DELL EMC 8-Node All Flash Integrated System for Azure Stack Hub.
 - CISCO Systems 4-Node Hybrid Integrated System for Azure Stack Hub.

## Environment

And workloads followed these sizes:

### Basic Load

 - 1 x Standard_A1_v2 with 2 x 500GB data disks

 - 1 x Standard_F4s with 2x 500GB data disks -- unmanaged disks

 - 1 x Standard_F4s with 2x 500GB data disks with an extension

 - 1 x Standard_DS14_v2 with with 2x 500GB data disks

### Medium Load

 - 50 x Standard_A1_v2 (no data disks)

 - 50 x Standard_F2s_v2 with 1 x 500GB data disks

 - 15 x Standard_D3_v2 with 3 x 500GB data disks

 - 5 x Standard\_DS5_v2 with 3 x 500GB data disks

### Heavy Load

 - 100 x Standard_A1_v2 (no data disks)

 - 100 x Standard_F4s (no data disks)

 - 20 x Standard_F2s_v2 with 3 x 500GB data disks

 - 20 x Standard_D3_v2 with 3 x 500GB data disks

 - 5 x Standard_DS5_v2 with 4 x 500GB data disks

 - 5 x Standard_DS14_v2 with 20x 500GB data disks

## Scenarios

1. Backup and Restore on the same Stamp.
2. Backup on Stamp A and Restore to Stamp B.
3. Backup to an external SMB Share from Stamp A and Restore it from SMB to Stamp A.
4. Backup to an external SMB Share from Stamp A and Restore it from SMB to Stamp B.

## Automation

The tests have two parts:

 - Creating the environment and the workloads
 - The actual BCDR testing

For the environment creation, we've used a combination of PowerShell scripts, Azure Resource Manager templates, and QuickStart templates. If needed, the scripts can also create an Active Directory Domain Services, a Management VNet with a VNet Peering to the actual workloads and joins them into the Active Directory. It can also create SQL Clusters and with time we'll increase the types of workloads it can deploy.

You can take the scripts, adjust them to your workloads, and test the product you want on your environment.

The full list of scripts can be found here: [ARMtemplates](https://github.com/rtibi/Azure-Stack-Hub-Foundation-Core/tree/master/BCDR-validation/ARMtemplates)

## Results

### Round 1

### Cohesity

| Scenario                    | AzStackHub Version (each stamp) | Cohesity version                 |
|-----------------------------|---------------------------------|----------------------------------|
| AzStackHub to AzStackHub    | 1.2102.11.40                    | 6.6.0a_release-20210315_a47862d5 |
| Migrate between AzStackHubs | 1.2102.11.40                    | 6.6.0a_release-20210315_a47862d5 |
| Migrate to AzStackHub       | 1.2102.11.40                    | 6.6.0a_release-20210315_a47862d5 |

[Link to full results doc](cohesity_results_round1.md)

### Commvault

| Scenario                    | AzStackHub Version (each stamp) | Commvault version |
|-----------------------------|---------------------------------|-------------------|
| AzStackHub to AzStackHub    | 1.2102.11.40                    |                   |
| Migrate between AzStackHubs | 1.2102.11.40                    |                   |
| Migrate to AzStackHub       | 1.2102.11.40                    |                   |

[Link to full results doc](commvault_results_round1.md)

### Veeam

| Scenario                    | AzStackHub Version (each stamp) | Veeam version |
|-----------------------------|---------------------------------|---------------|
| AzStackHub to AzStackHub    | 1.2102.11.40                    | 11.0.0.873    |
| Migrate between AzStackHubs | 1.2102.11.40                    | 11.0.0.873    |
| Migrate to AzStackHub       | 1.2102.11.40                    | 11.0.0.873    |

[Link to full results doc](Veeam_results_round1.md)
