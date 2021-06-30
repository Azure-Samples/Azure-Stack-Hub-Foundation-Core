#region === Variables === #####

#################
# USER ACCOUNTS #
# make sure you are using appropriate passwords
#################
# -> Local Admin / Domain Admin / SQL Admin
$adminUsername = "vmadmin"
$adminPassword = "adminPassword!" | ConvertTo-SecureString -Force -AsPlainText

# -> Local Admin of the Jumphost
$JumphostAdmin = "JumphostAdmin"
$JumphostPassword = "JumphostPassword" | ConvertTo-SecureString -Force -AsPlainText

# -> Service Account User for ClusterSQLServer
$sqlServerServiceAccountUserName = "AzureStackSQL"
$sqlServerServiceAccountPassword = "sqlServerServiceAccountPassword" | ConvertTo-SecureString -Force -AsPlainText

#####################
# DEPLOYMENT VALUES #
#####################
$DeploymentName = "HeavyLoad"
$ResourceGroupName = "RG-HEAVYLOAD"
$azureDeploy = Join-Path -Path (Get-Location).Path -ChildPath "azuredeploy.json"
# - Change these, if you move the files to another blobstore
$NestedTemplates_ArtifactsLocation = "https://nestedtemplates.azurestack.local"
$NestedTemplates_Folder = "nestedtemplates"
$NestedTemplates_SASToken = "YOUR_SAS_TOKEN" | ConvertTo-SecureString -AsPlainText -Force
# - AzS-Connection
$Location = "redmond"
$Environment_Name = "AzureStack-${Location}"
$ARM_Endpoint = "https://management.azurestack.local"
$Destination_Subscription = "SUBSCRIPTION_ID"
$Destination_Tenant = "TENANT_ID"

########################
# VIRTUAL MACHINE VNET #
########################
[string] $vnetName = "HeavyLoadVirtualNetwork"
[string] $subnetName = "VirtualMachineSubnet"
[string] $addressPrefix = "10.0.0.0/22"
[string] $subnetPrefix = "10.0.0.0/22"

#################
# JUMPHOST VNET #
#################
[string] $jumphostvnetName = "HeavyLoadJumphostVirtualNetwork"
[string] $jumphostSubnetName = "JumphostSubnet"
[string] $jumphostAddressPrefix = "10.1.0.0/24"
[string] $jumphostSubnetPrefix = "10.1.0.0/24"
[string] $jumphostNetworkSecurityGroupName = "JumphostNSG"

######################################
# ACTIVE DIRECTORY CONTROLLER VALUES #
######################################
[string] $adcVirtualMachineName = "HV-LOCAL-AD01"
[string] $adcDomainName = "HEAVY.LOCAL"
[string] $adcNetworkInterfaceName = "HV-LOCAL-AD01-NIC"
[string] $adcActiveDirectoryControllerStaticIP = "10.0.0.100"
[string] $adcVirtualMachineSize = "Standard_F2S_V2"
[string] $adcPublisher = "MicrosoftWindowsServer"
[string] $adcOffer = "WindowsServer"
[string] $adcSKU = "2019-Datacenter"
[string] $adcVirtualDiskStorageAccountType = "Premium_LRS"
[int] $adcVirtualDiskSize = 200

####################
# JUMP HOST VALUES #
####################
[string] $jpPublicIpName = "heavy-jumphost-pip1d"
[string] $jpPublicIpSku = "Basic"
[string] $jpPublicIPAllocationMethod = "Dynamic"
[string] $jpDnsLabelPrefix = "heavyjumphost"
[string] $jpNetworkInterfaceName = "heavy-jumphost-nic1d"
[string] $jpVirtualMachineSize = "Standard_F2s_v2"
[string] $jpVirtualMachineName = "heavy-Jumphost"


#region ArrayDocumentation
##################################################
# Array Creation Documentation - Virtual Machine #
##################################################
$demoArrayForVirtualMachines = @{
    # - Number of Virtual Machines that shall be deployed.
    VirtualMachineCount      = [int] 0

    # - Number of Virtual Machines that can be deployed side2side.
    # - The value has to be lesser or equal to VirtualMachineCount.
    # - Do not raise this value over 40, else there will be issues.
    ParallelDeployments      = [int] 0

    # - Name Prefix of the Virtual Machines. Will be appended by copyIndex()
    # - Scheme would be: demoVM-1 (<Prefix>-<copyIndex()>)
    VirtualMachineNamePrefix = [string] "String"

    # - Start Index
    # - Integer that adds to the copyIndex()-Function
    # -> Example: VirtualMachineNamePrefix = default && StartIndex = 3
    # ---> VirtualMachineName => default-3 instead of default-0
    StartIndex               = [int] 0

    # - Image Publisher
    # - Allowed Values (given through the Azure Stack Hub) are:
    # -> For Linux: Canonical
    # -> For SQL-Server: MicrosoftSQLServer
    # -> For Windows Server: MicrosoftWindowsServer
    Publisher                = [string] "string"

    # - Image Offer
    # - Allowed Values (given through the Azure Stack Hub) are:
    # -> For Linux: UbuntuServer
    # -> For SQL-Server: 
    # ---> SQL2017-WS2016
    # ---> SQL2016SP1-WS2016
    # ---> SQL2016SP2-WS2016
    # ---> SQL2019-WS2019
    # -> For Windows Server: WindowsServer
    Offer                    = [string] "string"

    # - Image Sku
    # - Allowed Values (given through the Azure Stack Hub) are:
    # -> For Linux: 
    # ---> 16.04-LTS
    # ---> 18.04-LTS
    # ---> 20.04-LTS
    # -> For SQL-Server: !!! THESE ONLY WORK THE AN SQL SERVER SKU !!! 
    # ---> Standard
    # ---> Enterprise
    # -> For Windows Server: 
    # ---> 2012-datacenter
    # ---> 2016-r2-datacenter
    # ---> 2016-datacenter
    # ---> 2019-datacenter
    SKU                      = [string] "string"

    # - Flag if Virtual machines do have to be deployed with managed or unmanaged disks
    # - Allowed Values:
    # -> "true"     -> Virtual Machines are deployed with managed disks
    # -> "false"    -> Virtual Machines are deployed with unmanaged disks
    ManagedDisk              = [string] "string"

    # - Size of the Data Disks to deploy
    # - Has to be higher than 0 
    DiskSize                 = [int] 1

    # - Amount of DataDisks to deploy
    # - Allowed Values are:
    # -> DiskAmount greater than 0 => Virtual Machines are deployed with n-Amount of Disks
    # -> DiskAmount equals 0 => Virtual Machines are deployed without Data Disks 
    # ---> !!!SQL SERVER NEED DATADISKS, DEPLOYMENT WON'T START IF YOU COMBINATE THIS WITH SQLSERVER!!! 
    DiskAmount               = [int] 0

    # - Extensions that shall be deployed to the VM
    # - Allowed Values:
    # -> "null": Deploys no extension.
    # -> Sql2014: Deploys an SQL2014 on a generic virtual machine. Only works with Image Publisher "MicrosoftWindowsServer"
    # -> Sql2016SP1: Deploys an SQL2016SP1-Server. Only with Image Publisher "MicrosoftSQLServer" AND Image Offer SQL2016SP1-WS2016.
    # -> Sql2016SP2: Deploys an Sql2016SP2-Server. Only with Image Publisher "MicrosoftSQLServer" AND Image Offer Sql2016SP2-WS2016.
    # -> Sql2017: Deploys an Sql2017-Server. Only with Image Publisher "MicrosoftSQLServer" AND Image Offer Sql2017-WS2016.
    # -> Sql2019: Deploys an Sql2019-Server. Only with Image Publisher "MicrosoftSQLServer" AND Image Offer Sql2019-WS2019.
    Extension                = [string] "string"

    # -> Virtual Machine Size (Takes everything, if its available to use)
    VirtualMachineSize       = [string] "string"

    # -> Storage Account Type
    # - Allowed Values are:
    # -> "Standard_LRS"
    # -> "Premium_LRS"
    StorageAccountType       = [string] "string"
}

##########################################
# Array Creation Documentation - Cluster #
##########################################
$demoClusterArray = @{
    # - Number of Clusters that shall be deployed.
    AmountOfClusters                   = 1

    # - Limiter, how many clusters shall be deployed at once. Needs to be smaller than "AmountOfClusters".
    ParallelDeployments                = 1

    # - Naming Scheme index, default is 0. 
    # - This option gives the opportunity to start the cluster deployment at an higher index. 
    StartIndex                         = 0

    # Virtual Machine prefix. Will be filled into CL-<INDEX>-<PREFIX>-<VMINDEX>
    VirtualMachineNamePrefix           = "DS11"

    # - Virtual Machine Size for SQL Servers and File Share Witness
    VirtualMachineSize                 = "Standard_DS11_v2" 
    FileShareWitnessVmSize             = "Standard_DS2_v2" 

    # - Flag if Virtual machines do have to be deployed with managed or unmanaged disks
    # - Allowed Values:
    # -> "true"     -> Virtual Machines are deployed with managed disks
    # -> "false"    -> Virtual Machines are deployed with unmanaged disks
    ManagedDisk                        = "false"

    # -> Storage Account Type
    # - Allowed Values are:
    # -> "Standard_LRS"
    # -> "Premium_LRS"
    StorageAccountType                 = "Standard_LRS"
    FileShareWitnessStorageAccountType = "Standard_LRS"

    # - Amount of SQL Disks the 2 Systems get deployed with.
    # - !!! NEEDS TO BE GREATER/ EQUALS 2 !!!
    AmountOfSqlDisks                   = 2

    # SQL Disk Size.
    # - Has to be higher than 0 
    SqlDiskSize                        = 200

    # - Operating system relevant information. 
    # - Currently supported offers with Publisher MicrosoftSQLServer: 
    # -> SQL2016SP1-WS2016
    # -> SQL2016SP2-WS2016
    # -> SQL2017-WS2016
    Publisher                          = "MicrosoftSQLServer"
    Offer                              = "SQL2016SP2-WS2016"
    FileShareWitnessOsVersion          = "2016-Datacenter"
    SKU                                = "Enterprise"

    # - Default IP-Configuration will start at 10.0.3.000 for Load Balancers.
    # - If startIP is given, it will start giving IPs after the given number. Default value is null.
    IpRegionForLoadbalancers           = "10.0.3.XXX" # The xxx will be replaced by an actual integer
    StartIp                            = 0 
}

#endregion ArrayDocumentation

###################################
# CREATION OF THE DEPLOYMENT LIST #
###################################
$DeploymentList = New-Object System.Collections.ArrayList
$Standard_A1_v2 = @{
    VirtualMachineCount      = 100
    ParallelDeployments      = 40
    VirtualMachineNamePrefix = "HLA1V2"
    Publisher                = "MicrosoftWindowsServer"
    Offer                    = "windowsserver"
    SKU                      = "2019-Datacenter-smalldisk"
    ManagedDisk              = "true"
    DiskSize                 = 1
    DiskAmount               = 0
    VirtualMachineSize       = "Standard_A1_v2" 
    StorageAccountType       = "Standard_LRS"
    StartIndex               = 0
    Extension                = "FileServer"
}
$Standard_F4s = @{
    VirtualMachineCount      = 100
    ParallelDeployments      = 40
    VirtualMachineNamePrefix = "HLF4S"
    Publisher                = "Canonical"
    Offer                    = "UbuntuServer"
    SKU                      = "18.04-LTS"
    ManagedDisk              = "true"
    DiskSize                 = 1
    DiskAmount               = 0
    VirtualMachineSize       = "Standard_F4s" 
    StorageAccountType       = "Premium_LRS"
    StartIndex               = 0
    Extension                = "null"
}
$Standard_F2s_v2 = @{
    VirtualMachineCount      = 20
    ParallelDeployments      = 20
    VirtualMachineNamePrefix = "HLF2SV2"
    Publisher                = "MicrosoftSQLServer"
    Offer                    = "SQL2016SP1-WS2016"
    SKU                      = "Enterprise"
    ManagedDisk              = "true"
    DiskSize                 = 20
    DiskAmount               = 1
    VirtualMachineSize       = "Standard_F2s_v2" 
    StorageAccountType       = "Standard_LRS"
    StartIndex               = 0
    Extension                = "Sql2016SP1"
}
$Standard_D3_v2 = @{
    VirtualMachineCount      = 20
    ParallelDeployments      = 20
    VirtualMachineNamePrefix = "HLD3V2"
    Publisher                = "MicrosoftSQLServer"
    Offer                    = "SQL2019-WS2019"
    SKU                      = "Enterprise"
    ManagedDisk              = "true"
    DiskSize                 = 20
    DiskAmount               = 1
    VirtualMachineSize       = "Standard_D3_v2" 
    StorageAccountType       = "Standard_LRS"
    StartIndex               = 0
    Extension                = "Sql2019"
}

$Standard_DS14_v2 = @{
    VirtualMachineCount      = 5
    ParallelDeployments      = 5
    VirtualMachineNamePrefix = "HLDS14v2"
    Publisher                = "MicrosoftSQLServer"
    Offer                    = "SQL2019-WS2019"
    SKU                      = "Enterprise"
    ManagedDisk              = "true"
    DiskSize                 = 20
    DiskAmount               = 1
    VirtualMachineSize       = "Standard_DS14_v2" 
    StorageAccountType       = "Standard_LRS"
    StartIndex               = 0
    Extension                = "Sql2019"
}

$Standard_DS5_v2 = @{
    VirtualMachineCount      = 5
    ParallelDeployments      = 5
    VirtualMachineNamePrefix = "HLDS5v2"
    Publisher                = "MicrosoftSQLServer"
    Offer                    = "SQL2019-WS2019"
    SKU                      = "Enterprise"
    ManagedDisk              = "true"
    DiskSize                 = 20
    DiskAmount               = 1
    VirtualMachineSize       = "Standard_DS5_v2" 
    StorageAccountType       = "Standard_LRS"
    StartIndex               = 0
    Extension                = "Sql2019"
}

$Standard_DS14_v2_Cluster = @{
    AmountOfClusters                   = 3
    ParallelDeployments                = 3
    StartIndex                         = 0
    VirtualMachineNamePrefix           = "HLDS14"
    VirtualMachineSize                 = "Standard_DS14_v2" 
    FileShareWitnessVmSize             = "Standard_A1_v2" 
    ManagedDisk                        = "true"
    StorageAccountType                 = "Premium_LRS"
    FileShareWitnessStorageAccountType = "Standard_LRS"
    AmountOfSqlDisks                   = 1
    SqlDiskSize                        = 20
    Publisher                          = "MicrosoftSQLServer"
    Offer                              = "SQL2016SP2-WS2016"
    FileShareWitnessOsVersion          = "2016-Datacenter"
    SKU                                = "Enterprise"
    IpRegionForLoadbalancers           = "10.0.3.XXX"
    StartIp                            = 0 
}
$Standard_DS5_v2_Cluster = @{
    AmountOfClusters                   = 3
    ParallelDeployments                = 3
    StartIndex                         = 0
    VirtualMachineNamePrefix           = "HLDS5V2"
    VirtualMachineSize                 = "Standard_DS5_v2" 
    FileShareWitnessVmSize             = "Standard_A1_v2" 
    ManagedDisk                        = "true"
    StorageAccountType                 = "Standard_LRS"
    FileShareWitnessStorageAccountType = "Standard_LRS"
    AmountOfSqlDisks                   = 1
    SqlDiskSize                        = 20
    Publisher                          = "MicrosoftSQLServer"
    Offer                              = "SQL2017-WS2016"
    FileShareWitnessOsVersion          = "2016-Datacenter"
    SKU                                = "Enterprise"
    IpRegionForLoadbalancers           = "10.0.3.XXX"
    StartIp                            = 3
}
#############################################
### Add the arrays to the deployment list ###
#############################################
$DeploymentList.Add($Standard_A1_v2)
$DeploymentList.Add($Standard_F4s)
$DeploymentList.Add($Standard_F2s_v2)
$DeploymentList.Add($Standard_D3_v2)
$DeploymentList.Add($Standard_DS14_v2)
$DeploymentList.Add($Standard_DS5_v2)
#$DeploymentList.Add($Standard_DS14_v2_Cluster)
#$DeploymentList.Add($Standard_DS5_v2_Cluster)

##############################
#endregion === Variables === #

#region === Script === ####
###########################

if (-not ((Get-AzureRmContext).Subscription.Id -EQ $Destination_Subscription)) {
    Add-AzureRmEnvironment -Name $Environment_Name -ARMEndpoint $ARM_Endpoint
    Add-AzureRmAccount -Environment $Environment_Name -Tenant $Destination_Tenant
    Set-AzureRmContext -Subscription $Destination_Subscription
}

###########################
# RESOURCE GROUP CREATION #
###########################
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force

####################
# DEPLOYMENT START #
####################
ForEach ($Deployment in $DeploymentList) {
    $DeploymentParameter = @{
        vnetName                         = $vnetName
        nestedTemplateFolder             = $NestedTemplates_Folder
        _artifactsLocation               = $NestedTemplates_ArtifactsLocation
        _artifactsLocationSasToken       = $NestedTemplates_SASToken
        adminUsername                    = $adminUsername
        adminPassword                    = $adminPassword
        jumphostvnetName                 = $jumphostvnetName
        subnetName                       = $subnetName
        addressPrefix                    = $addressPrefix
        subnetPrefix                     = $subnetPrefix
        jumphostSubnetName               = $jumphostSubnetName
        jumphostAddressPrefix            = $jumphostAddressPrefix
        jumphostSubnetPrefix             = $jumphostSubnetPrefix
        jumphostNetworkSecurityGroupName = $jumphostNetworkSecurityGroupName
        JumphostAdmin                    = $JumphostAdmin
        JumphostPassword                 = $JumphostPassword
        sqlServerServiceAccountUserName  = $sqlServerServiceAccountUserName
        sqlServerServiceAccountPassword  = $sqlServerServiceAccountPassword
        ActiveDirectoryParameters        = @{
            VirtualMachineName                = $adcVirtualMachineName
            DomainName                        = $adcDomainName
            NetworkInterfaceName              = $adcNetworkInterfaceName
            ActiveDirectoryControllerStaticIP = $adcActiveDirectoryControllerStaticIP
            VirtualMachineSize                = $adcVirtualMachineSize
            Publisher                         = $adcPublisher
            Offer                             = $adcOffer
            SKU                               = $adcSKU
            VirtualDiskStorageAccountType     = $adcVirtualDiskStorageAccountType
            VirtualDiskSize                   = $adcVirtualDiskSize
        }
        JumphostParameters               = @{
            publicIpName             = $jpPublicIpName
            publicIpSku              = $jpPublicIpSku
            publicIPAllocationMethod = $jpPublicIPAllocationMethod
            dnsLabelPrefix           = $jpDnsLabelPrefix
            networkInterfaceName     = $jpNetworkInterfaceName
            virtualMachineSize       = $jpVirtualMachineSize
            virtualMachineName       = $jpVirtualMachineName
        }
    }

    ##############################
    # TYPECHECK IF CLUSTER OR VM #
    ##############################
    if ($null -ne $Deployment.AmountOfClusters) {
        $DeploymentParameter.Add("clusterParameters", $Deployment)
    }
    else {
        $DeploymentParameter.Add("vmParameters", $Deployment)
    }  

    New-AzureRmResourceGroupDeployment -Name $DeploymentName `
        -ResourceGroupName $ResourceGroupName `
        -Force `
        -Mode 'Incremental' `
        -TemplateFile $azureDeploy @DeploymentParameter `
        -Confirm:$false `
        -Verbose
}
# --- Deployment Creation --- #

###########################
#endregion === Script === 