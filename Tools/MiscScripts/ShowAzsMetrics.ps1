$FQDN = Read-Host "Enter External FQDN"
$RegionName = Read-Host "Enter Azure Stack Region Name"
Add-AzureRmEnvironment -Name Admin -ARMEndpoint https://adminmanagement.$regionname.$FQDN |out-null
Add-AzureRmAccount -Environment Admin|Out-Null

#Total Number of Nodes
#Rest API
## https://docs.microsoft.com/en-us/rest/api/azurestack/scaleunits/get
$scaleunit=get-azsscaleunit
$nodes=$scaleunit.nodes.count

#Total Cores

$PCore = $scaleunit.TotalCapacity.Cores

#Total Memory
$PMemory = $scaleunit.TotalCapacity.MemoryGB

#Get Infra Role Instance Core & Memory Reservation
#Rest API
## https://docs.microsoft.com/en-us/rest/api/azurestack/infraroleinstances/get
$RoleInstances=Get-AzsInfrastructureRoleInstance
$RoleInstanceCores=Foreach ($Instance in $RoleInstances){$Instance.Size.Cores}
$RCore=($RoleInstanceCores |Measure-Object -sum ).sum
$RoleInstanceMemory=Foreach ($Instance in $RoleInstances){$Instance.Size.MemoryGb}
$RMemory=($RoleInstanceMemory |Measure-Object -sum ).sum


#Rest API
## https://docs.microsoft.com/en-us/rest/api/azurestack/regionhealths/get
#Get current memory allocation
$RegionHealth=Get-AzsRegionHealth
$Rmetric=$RegionHealth.UsageMetrics|Where-Object {$_.Name -eq "Physical memory"}
$RCapacity=$Rmetric.MetricsValue|Where-Object {$_.name -eq "Available"}
$RUsed=$Rmetric.MetricsValue|Where-Object {$_.name -eq "Used"}

#Get current Storage allocation
$RStoragemetric=$RegionHealth.UsageMetrics|Where-Object {$_.Name -eq "Physical storage"}
$RStorageCapacity=$RStoragemetric.MetricsValue|Where-Object {$_.name -eq "Available"}

#Get Storage Total
#Rest API
## https://docs.microsoft.com/en-us/rest/api/azurestack/storagesystems/get
$TDisk=Get-AzsStorageSystem

# Print NUmber of Reserved Memory
write-host "Number of Node:" ($nodes) -ForegroundColor Yellow

Write-host "_________________________________________________________________________________"

# Calculate Total Number of virtual cores (Ratio 1:8 - logical to virtual)
write-host "Number of total virtual cores:" ($PCore  * 8) -ForegroundColor Yellow

# Print NUmber of Reserved Virtual Cores
write-host "Number of reserved virtual cores:" ($RCore) -ForegroundColor Yellow

# Calculate Total Number of available virtual cores for users Day 0 (Ratio 1:8 - logical to virtual)
write-host "Number of available virtual cores - Day 0:" ($PCore * 8 - $Rcore) -ForegroundColor Green

Write-host "_________________________________________________________________________________"

# Calculate Scale Unit Total Memory
write-host "Scale Unit Total Memory in GB:" ($PMemory) -ForegroundColor Yellow

# Print NUmber of Reserved Memory
write-host "Reserved Memory in GB:" ($RMemory) -ForegroundColor Yellow

# Calculate available Memory Day 0
write-host "Total Available User Memory in GB - Day 0:" ($PMemory - $RMemory) -ForegroundColor Green

# Used Memory from HRP
write-host "Current Total Used Memory in GB:" ($RUsed.Value) -ForegroundColor Green

# Availavle User Memory from HRP
write-host "Current Total Available User Memory in GB:" ($RCapacity.Value) -ForegroundColor Red



Write-Host "__________________________________________________________________________________"

# Availavle Storage from HRP
write-host "Total Available Storage in GB - Day 0:" ($TDisk.TotalCapacityGB) -ForegroundColor Green

# Availavle Storage from HRP
write-host "Current Total Available Storage in TB:" ($RStorageCapacity.Value) -ForegroundColor Red





