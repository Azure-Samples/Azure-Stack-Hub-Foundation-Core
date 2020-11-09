# Declare variables
$Region = "local"
$FQDN = "azurestack.external"

# Declare administrator resource management endpoint
$ArmEndpoint = "https://adminmanagement.$Region.$FQDN"

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRmEnvironment -Name "AzureStackAdmin" -ArmEndpoint $ArmEndpoint

# Sign in to your environment
Connect-AzureRmAccount -EnvironmentName "AzureStackAdmin$Region"

# Get all scale unit object
$ScaleUnit = Get-AzsScaleUnit
# Pass scale unit to storage subsystem
$StorageSubSystem = Get-AzsStorageSubSystem -ScaleUnit $ScaleUnit.Name

# Get all disks in a storage subsystem and display their health status
Get-AzsDrive -StorageSubSystem $StorageSubSystem.Name -ScaleUnit $ScaleUnit.Name | Sort-Object -Property StorageNode, MediaType, PhysicalLocation | Format-Table StorageNode, HealthStatus, PhysicalLocation, Model, MediaType, CapacityGB, OperationalStatus, Description, Action

<#
Sample output:
StorageNode       HealthStatus PhysicalLocation       Model            MediaType CapacityGB OperationalStatus Description Action
-----------       ------------ ----------------       -----            --------- ---------- ----------------- ----------- ------
local/AzP-Node01 Healthy      Slot 1                 xxxxxxxxxxxxx  HDD             7452 OK
#>
