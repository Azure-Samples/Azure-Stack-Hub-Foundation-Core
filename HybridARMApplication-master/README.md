# HybridARMApplication
The intention for this application is to serve as a single client application that can talk to Mcrosoft Azure as well as the Microsoft Azure Stack Clouds.

# Instructions
1. Create your Service Principal and copy paste the Id and Secret in the App.Config
2. Replace values for your Subscription, Resorce Group, VM,VNet and IP address in the Program.cs (If you dont want any of these resources, feel free to leave them blank but remember to comment out the tests below)
3. Use a Network proxy such as Fiddler to capture these requests and observe responses. The code currently returns these responses as a string
