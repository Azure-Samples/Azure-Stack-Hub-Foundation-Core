This work is licensed under a [Creative Commons Attribution - ShareAlike 4.0 International Public License](https://creativecommons.org/licenses/by-sa/4.0/legalcode).

The PowerPoint slides, the videos, and the workshop guides in this repo are for informational purposes only. MICROSOFT MAKES NO WARRANTIES, EXPRESS OR IMPLIED.

# Overview

The Azure Stack Hub Foundation Core are a set of materials (PowerPoint presentations, workshops, and links to videos) aiming to provide Azure Stack Hub Operators the foundational materials required to ramp-up and understand the basics of operating Azure Stack Hub.

# Background

Since Azure Stack Hub launched, Microsoft together with Intel created a program to enable and accelerate our customers and partners around the world in their adoption of Azure Stack Hub. The main drivers of the program have been the Microsoft Enterprise Services teams (both Microsoft Consulting Services, as well as Microsoft Premier) and through the Consultants, Premier Field Engineers, and Architects, have delivered a large number of projects – ranging from smaller workshops, all the way to full blown production deliveries.

Along the way, the team talked to hundreds of organizations interested in Azure Stack, trained dozens of partners, and visited a number of deployments as part of the Azure Stack Early Adoption Initiative and Azure Stack Accelerator Programs. Many of the activities have been focused on producing material to help others understand, prepare for, deploy, and operate Azure Stack Hub. At the core of these materials is the Azure Stack Foundation offering, which is a set of 12 modules covering all topics from initial deployment, to identity, security, compute and PaaS services, as well as BCDR and disconnected topics.

 
# Getting Started

The [ASF slides](https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/tree/master/ASF-Training/ASF-slides) are the core modules providing information about all aspects of Azure Stack Hub - from the internal RPs, to the hybrid solutions that could be built

These slides are complemented by the [Azure Stack Hub Foundation - Core video series](https://aka.ms/azsasfvideos), where most of the chapters are explained and go indepth by the technical leads that helped create these slides. The videos can be used to learn and prepare for the Azure Stack Operator role itself, or even for guidance when delivering these workshops.

* [M01a What Is Azure Stack](https://youtu.be/xbzlKJcMoCU?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M02b Azure Stack Deployment Prerequisites](https://youtu.be/ZYYvfGJKoxk?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M02d Azure Stack Integration](https://youtu.be/3wzn1bdQ9mU?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M02e Installing Azure Stack Development Kit](https://youtu.be/4P8xEocW9ik?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M03a Azure Stack Identity](https://youtu.be/bDYfN-OGB4I?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M03b Azure Stack Security](https://youtu.be/e6ao7Jqz_EQ?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M04c Azure Resource Manager Templates](https://youtu.be/ncXXZaHx3kA?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M05a Azure Stack Offers and Plans](https://youtu.be/WUYNU9z7cyw?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M05b Azure Stack Marketplace](https://youtu.be/xo2B5ohl6rU?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M06a Azure Stack Hub Virtual Networking](https://youtu.be/cQuvO6Za2Ng?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M06b Azure Stack Storage](https://youtu.be/Z6bWEutd4ww?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M06c Azure Stack Compute](https://youtu.be/0OZuTbK7pts?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M07a Azure Stack PaaS Concepts](https://youtu.be/MJU9-8vv23M?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M07b Azure Stack SQL Server and MySQL Server RP](https://youtu.be/2yUPEa2Br-k?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M07c Azure Stack App Service RP](https://youtu.be/TnWT0hLwnDw?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M08b Azure Stack Control Plane Monitoring](https://youtu.be/j5c_pD1aq20?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M08c Azure Stack Infrastructure PNU](https://youtu.be/Fx6QBYcBX3M?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M09a Azure Stack Licensing](https://youtu.be/UMDB0qBtvXs?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M09b Azure Consistent Billing](https://youtu.be/GiGs36JTi48?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M09c Azure Stack Troubleshooting and Support](https://youtu.be/rJT9xjUm3U0?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M10a Azure Stack BCDR](https://youtu.be/x7szE5Nui7Y?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M11a Azure Stack Hybrid Applications Intro](https://youtu.be/to8D7Xl9SU8?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)
* [M12 Azure Stack Disconnected Scenarios](https://youtu.be/bZBKfx4qZIQ?list=PLF1fEGG5LcdHdTns6TN-uVhqs66ax6VkE)

# Hands'on

Once you go through the basics, reviewing the slides as well as the videos, the next step would be to gain some operational experience - hands-on knowledge. 
The [Operator Workshop](https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/tree/master/ASF-Training/ASF-workshop) aims at providing a starting point for gaining this hands-on experience, with two workshops:

1. the [User Guide](https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/blob/master/ASF-Training/ASF-workshop/azure-stack-hub-lab-guide-user.md) workshop - which goes through basics of what an user would experience on Azure Stack Hub. This includes things like:
* Create the vnet, subnet,and NSG
* Create the first VM
* Create the second VM
* Troubleshooting and password reset
* Monitor VM metric
* Using QuickStart Templates
* Self Service User Subscription
* Creating a VMSS

2. once familiar with the user side of things, next would be the [Azure Stack Operator Lab](https://github.com/Azure-Samples/Azure-Stack-Hub-Foundation-Core/blob/master/ASF-Training/ASF-workshop/azure-stack-hub-lab-guide-operator.md), which goes into details around the operational aspects of Azure Stack Hub, including:

* Diagnostics and runnign Test Azure Stack Hub
* Capacity Management
* Understanding Quotas / Plans / Offers
* Creating and managing Custom Images

# Next steps

Follow us on the [Azure Stack blog](https://techcommunity.microsoft.com/t5/azure-stack-blog/bg-p/AzureStackBlog) and open a new conversation on the [Azure Stack conversation space](https://techcommunity.microsoft.com/t5/azure-stack/bd-p/AzureStack).
