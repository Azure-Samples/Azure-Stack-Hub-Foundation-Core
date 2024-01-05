# Hybrid ARM Application

The intention for this application is to serve as a single client application that can talk to Mcrosoft Azure as well as the Microsoft Azure Stack Clouds. To learn more about the scenario see the Azure Architecture Center article [Configure hybrid cloud identity for Azure and Azure Stack Hub apps](https://learn.microsoft.com/azure/architecture/hybrid/deployments/solution-deployment-guide-identity).

## Instructions

1. Create your service principal and copy paste the ID and Secret in the **App.config** file.
1. Replace values for your Azure subscription, resorce group, virtual machine, virtual network, and IP address in the **Program.cs** file. If you dont want any of these resources, feel free to leave them blank but remember to comment out the tests below.
1. Use a network proxy such as Fiddler to capture these requests and observe responses. The code returns responses as a string.
