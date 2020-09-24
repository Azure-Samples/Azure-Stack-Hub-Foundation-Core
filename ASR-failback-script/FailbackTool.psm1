#requires -Version 5.1
#requires -RunAsAdministrator
#requires -Modules @{ ModuleName="Az.Accounts"; ModuleVersion="2.0.1" }
#requires -Modules @{ ModuleName="Az.Compute"; ModuleVersion="0.10.0" }
#requires -Modules @{ ModuleName="Az.Network"; ModuleVersion="0.10.0" }
#requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="0.10.0" }
#requires -Modules @{ ModuleName="Az.Storage"; ModuleVersion="0.10.0" }

### -----------------------------------------
### Strings
### -----------------------------------------
Data Strings
{
# culture="en-US"
ConvertFrom-StringData @'
    # message
    MsgCreateVhdFolder = Creating directory {0}
    MsgVmName = VM Name: {0}
    MsgVmResourceGroup = VM Resource Group: {0}
    MsgOsDiskName = OS Disk Name: {0}
    MsgDataDiskNames = Data Disk Names: {0}
    MsgCreateNewContainer = Create new storage container {0}
    MsgShouldContinueStopVMConfirm = This cmdlet will stop the specified virtual machine. Do you want to continue?
    MsgShouldContinueStopVMOperation = Virtual machine stopping operation
    MsgCopyVHDTryTime = Try to copy VHD of disk {0} for the {1} time
    MsgUseAzCopy = Using AzCopy...
    MsgAzCopyDownloadVHD = Downloading {0} VHD from Azure Storage to local folder {1}
    MsgAzCopyUploadVHD = Uploading {0} VHD from local folder {1} to Azure Stack container {2}
    MsgUseAzStorageBlobCopy = Using AzureStorageBlobCopy...
    MsgAzStorageBlobCopyActivity = Exporting VHD of the managed disk {0} to Azure Stack container {1}
    MsgCreateTemplateDestFolder = Creating directory {0}
    MsgWriteIntoFile = Writing into {0}
    MsgShouldContinueOverwriteConfirm = This cmdlet will overwrite file {0}. Do you want to continue?
    MsgShouldContinueOverwriteOperation = File overwriting operation
    MsgSourceDiskVhdUris = Note that after successful failback deployment, you can safely delete the VHD files: {0}
    MsgDisksAttachedToTheVMToBeDeleted = The names of old disks attached to the specified target VM {0} are listed below, you can check and delete them manually if you think everything is OK after a successful failback:
    MsgShouldContinueDeleteVMConfirm = This cmdlet will delete VM {0} so that VM can be redeployed with failed-back disks. Do you want to continue?
    MsgShouldContinueDeleteVMOperation = Deleting VM Operation
    MsgDeleteVMOperationName = Delete VM

    # progress
    ProgressGetDiskInfo = Getting disk information of source VM
    ProgressGetTargetStorageContext = Getting target storage context
    ProgressStopVM = Stopping source VM {0}
    ProgressCopyVHD = Exporting VHD of the managed disk {0} to Azure Stack container {1}

    # warning
    WarningFailToDeleteLocalVhdFile = Fail to delete the downloaded VHD file {0}, please try to delete it manually. Exception: {1}
    WarningFailToCopyVHD = Fail to copy VHD of disk {0} for the {1} time, will retry after {2} seconds... Exception: {3}

    # error
    ErrorAzCopyPathInvalid = Provided AzCopy path {0} is invalid or is not a file
    ErrorStopVmFail = Stop source VM {0} failed: {1}
    ErrorStopVmCancel = Stop source VM {0} canceled
    ErrorWrongSourceDiskVhdUri = Provided source disk vhd uri at position {0} does not match disk {1}
    ErrorWrongSourceDiskVhdUrisCount = The number of disks attached to source VM is {0}, but {1} source disk vhd uri(s) provided
    ErrorInvalidStorageAccountType = Invalid Storage Account Type data retrieved for VM {0}
    ErrorOverwriteFileCancel = Overwrite file {0} canceled
    ErrorDeleteVMCancel = Delete VM {0} canceled. The ARM template and parameter file have been generated to {1} and {2}, you can manually delete the target VM and deploy the template
    ErrorFailToCopyVHD = Fail to copy VHD of disk {0} due to exception: "{1}"
    ErrorAzCopyParameterNotProvided = To use AzCopy, both AzCopyPath and VhdLocalFolder need to be provided.
'@
}

# Import localized strings
Import-LocalizedData Strings -FileName FailbackTool.Strings.psd1 -ErrorAction SilentlyContinue

### -----------------------------------------
### Constants
### -----------------------------------------
$SasExpiryDuration = "36000"
$SleepTime = "30"

$AzCopyServiceAPIVersion = "2017-11-09"

$SchemaVersion = "2018-05-01"
$VmArmAPIVersion = "2017-12-01"
$StorageAccountArmAPIVersion = "2017-10-01"
$NetworkArmAPIVersion = "2018-11-01"
$DiskArmAPIVersion = "2017-03-30"

$BootDiagnosticsTemplating = [ordered]@{
    diagnosticsProfile = [ordered]@{
        bootDiagnostics = [ordered]@{
            enabled = "[parameters('bootDiagnosticsEnabled')]"
            storageUri = "[parameters('bootDiagnosticsStorageUri')]"
        }
    }
}

$StorageAccountTemplating = [ordered]@{
    name = "[parameters('storageAccountName')]"
    type = "Microsoft.Storage/storageAccounts"
    apiVersion = $StorageAccountArmAPIVersion
    location = "[parameters('location')]"
    properties = [ordered]@{
        supportsHttpsTrafficOnly = "[parameters('storageAccountSupportsHttpsTrafficOnly')]"
    }
    sku = [ordered]@{
        name = "[parameters('storageAccountSkuName')]"
    }
    kind = "[parameters('storageAccountKind')]"
}

$VirtualNetworkTemplating = [ordered]@{
    type = "Microsoft.Network/virtualNetworks"
    name = "[parameters('virtualNetworkName')]"
    apiVersion = $NetworkArmAPIVersion
    location = "[parameters('location')]"
    properties = [ordered]@{
        addressSpace = [ordered]@{
            addressPrefixes = "[parameters('virtualNetworkAddressPrefixes')]"
        }
        subnets = @(
            [ordered]@{
                name = "[parameters('subnetName')]"
                properties = [ordered]@{
                    addressPrefix = "[parameters('subnetAddressPrefix')]"
                }
            }
        )
    }
}

$PublicIpAddressTemplating = [ordered]@{
    type = "Microsoft.Network/publicIPAddresses"
    apiVersion = $NetworkArmAPIVersion
    name = "[parameters('publicIpAddressName')]"
    location = "[parameters('location')]"
    sku = [ordered]@{
        name = "[parameters('publicIpAddressSkuName')]"
    }
    properties = [ordered]@{
        publicIPAllocationMethod = "[parameters('publicIPAllocationMethod')]"
        idleTimeoutInMinutes = "[parameters('idleTimeoutInMinutes')]"
        publicIpAddressVersion = "[parameters('publicIpAddressVersion')]"
    }
}

$OsDiskStorageProfile = [ordered]@{
    osType = "[parameters('osType')]"
    caching = "[parameters('osDiskCaching')]"
    createOption = "[parameters('diskCreateOption')]"
    managedDisk = [ordered]@{
        id = "[resourceId('Microsoft.Compute/disks', parameters('osDiskName'))]"
    }
}

$OsDiskTemplating = [ordered]@{
    type = "Microsoft.Compute/disks"
    apiVersion = $DiskArmAPIVersion
    name = "[parameters('osDiskName')]"
    location = "[parameters('location')]"
    properties = [ordered]@{
        creationData = [ordered]@{
            createOption = "Import"
            sourceUri = "[parameters('osDiskSourceUri')]"
        }
        osType = "[parameters('osType')]"
    }
}

$DataDiskStorageProfile = [ordered]@{
    copy = @(
        [ordered]@{
            name = "dataDisks"
            count = "[length(parameters('dataDiskNames'))]"
            input = [ordered]@{
                lun = "[parameters('dataDiskLuns')[copyIndex('datadisks')]]"
                name = "[parameters('dataDiskNames')[copyIndex('datadisks')]]"
                createOption = "[parameters('diskCreateOption')]"
                managedDisk = [ordered]@{
                    id = "[resourceId('Microsoft.Compute/disks/', parameters('dataDiskNames')[copyIndex('datadisks')])]"
                }
            }
        }
    )
}

$DataDiskTemplating = [ordered]@{
    type = "Microsoft.Compute/disks"
    apiVersion = $DiskArmAPIVersion
    name = "[parameters('dataDiskNames')[copyIndex('datadisks')]]"
    location = "[parameters('location')]"
    sku = [ordered]@{
        name = "[parameters('storageAccountSkuName')]"
    }
    properties = [ordered]@{
        creationData = [ordered]@{
            createOption = "Import"
            sourceUri = "[parameters('dataDiskSourceUri')[copyIndex('datadisks')]]"
        }
        diskSizeGB = "[parameters('dataDiskSizeGB')[copyIndex('datadisks')]]"
    }
    copy = [ordered]@{
        name = "datadisks"
        count = "[length(parameters('dataDiskNames'))]"
    }
}

function Copy-DiskVhd
{
    [OutputType([String])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceDiskName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceDiskSas,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetContainerName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetContainerUri,

        [Parameter(Mandatory = $true, ParameterSetName="AzCopy")]
        [ValidateScript({$_ | Test-Path -IsValid})]
        [String]
        $AzCopyPath,

        [Parameter(Mandatory = $true, ParameterSetName="AzCopy")]
        [ValidateScript({$_ | Test-Path -IsValid})]
        [String]
        $VhdLocalFolder,

        [Parameter(Mandatory = $true, ParameterSetName="AzCopy")]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetSasTokenKey,

        [Parameter(Mandatory = $true, ParameterSetName="AzStorageBlobCopy")]
        [Parameter(Mandatory = $true, ParameterSetName="AzCopy")]
        [ValidateNotNullOrEmpty()]
        [Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext]
        $TargetStorageContext
    )

    $ErrorActionPreference = "Stop"

    $destinationVhdFileName = "$SourceDiskName.vhd"
    [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {$destinationVhdFileName = $destinationVhdFileName.replace($_,'_')}

    if ($PSCmdlet.ParameterSetName -eq "AzCopy")
    {
        Write-Verbose $Strings.MsgUseAzCopy -Verbose

        $localVhdFileName = Join-Path -Path $VhdLocalFolder -ChildPath $destinationVhdFileName
        Write-Verbose ($Strings.MsgAzCopyDownloadVHD -f $SourceDiskName, $VhdLocalFolder) -Verbose
        & $AzCopyPath copy $SourceDiskSas $localVhdFileName | Write-Verbose -Verbose

        $targetContainerSasUri = "$TargetContainerUri/$destinationVhdFileName`?$TargetSasTokenKey"
        Write-Verbose ($Strings.MsgAzCopyUploadVHD -f $SourceDiskName, $VhdLocalFolder, $TargetContainerName) -Verbose
        & $AzCopyPath copy $localVhdFileName $targetContainerSasUri | Write-Verbose -Verbose

        try
        {
            Remove-Item -Path $localVhdFileName -Force
        }
        catch
        {
            Write-Warning ($Strings.WarningFailToDeleteLocalVhdFile -f $localVhdFileName, $_) 
        }
    }

    if ($PSCmdlet.ParameterSetName -eq "AzStorageBlobCopy")
    {
        Write-Verbose $Strings.MsgUseAzStorageBlobCopy -Verbose
        $activityName = $Strings.MsgAzStorageBlobCopyActivity -f $SourceDiskName, $TargetContainerName
        $copyBlobResult = Start-AzStorageBlobCopy -AbsoluteUri $SourceDiskSas -DestContainer $TargetContainerName -DestContext $TargetStorageContext -DestBlob $destinationVhdFileName
        do
        {
            $copyBlobStatus = $copyBlobResult | Get-AzStorageBlobCopyState
            Write-Progress -Activity $activityName -Status $copyBlobStatus.Status -PercentComplete (($copyBlobStatus.BytesCopied / $copyBlobStatus.TotalBytes) * 100)
            Start-Sleep 10
        } while ($copyBlobStatus.Status -eq "Pending")
    }

    $null = Get-AzStorageBlob -Blob $destinationVhdFileName -Container $TargetContainerName -Context $TargetStorageContext

    return "$TargetContainerUri/$destinationVhdFileName"
}

<#
 .Synopsis
  Copy VHDs of disks attached to the specified VM to the target blob container.

 .Description
  - Stop the source VM if it's not deallocated
  - Copy the VHD of each disk attached to the source VM to the target blob container
  - If VhdLocalFolder is provided, AzCopy is used, and the VHDs will first be downloaded to VhdLocalFolder and then uploaded
  - If VhdLocalFolder is not provided, StorageBlobCopy is used
  - Return the uri of copied VHDs.

 .Example
  $VHDs = Copy-AzSiteRecoveryVmVHD -SourceVM $sourceVM -TargetStorageAccountName $targetStorageAccountName -TargetEnvironmentName "AzureStackUser" -TargetStorageAccountKey $targetStorageAccountKey
  $VHDs = Copy-AzSiteRecoveryVmVHD -SourceVM $sourceVM -TargetStorageAccountName $targetStorageAccountName -TargetEnvironmentName "AzureStackUser" -TargetStorageAccountSasToken $targetStorageAccountSasToken
  $VHDs = Copy-AzSiteRecoveryVmVHD -SourceVM $sourceVM -TargetStorageAccountName $targetStorageAccountName -TargetEndpoint $AzureStackEndpoint -TargetStorageAccountKey $targetStorageAccountKey
  $VHDs = Copy-AzSiteRecoveryVmVHD -SourceVM $sourceVM -TargetStorageAccountName $targetStorageAccountName -TargetEndpoint $AzureStackEndpoint -TargetStorageAccountSasToken $targetStorageAccountSasToken
  $VHDs = Copy-AzSiteRecoveryVmVHD -SourceVM $sourceVM -TargetStorageAccountName $targetStorageAccountName -TargetEnvironmentName "AzureStackUser" -TargetStorageAccountKey $targetStorageAccountKey -AzCopyPath $azCopyPath -VhdLocalFolder $vhdFolder -MaxRetry 6
  $VHDs = Copy-AzSiteRecoveryVmVHD -SourceVM $sourceVM -TargetStorageAccountName $targetStorageAccountName -TargetEnvironmentName "AzureStackUser" -TargetStorageAccountSasToken $targetStorageAccountSasToken -AzCopyPath $azCopyPath -VhdLocalFolder $vhdFolder -Force
#>
function Copy-AzSiteRecoveryVmVHD
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([String[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Azure.Commands.Compute.Models.PSVirtualMachine]
        $SourceVM,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetStorageAccountName,

        [Parameter(Mandatory = $true, ParameterSetName="Key_Endpoint")]
        [Parameter(Mandatory = $true, ParameterSetName="Key_Env")]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetStorageAccountKey,
        
        [Parameter(Mandatory = $true, ParameterSetName="Sas_Endpoint")]
        [Parameter(Mandatory = $true, ParameterSetName="Sas_Env")]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetStorageAccountSasToken,

        [Parameter(Mandatory = $true, ParameterSetName="Key_Endpoint")]
        [Parameter(Mandatory = $true, ParameterSetName="Sas_Endpoint")]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetStorageEndpoint,

        [Parameter(Mandatory = $true, ParameterSetName="Key_Env")]
        [Parameter(Mandatory = $true, ParameterSetName="Sas_Env")]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetEnvironmentName,

        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ | Test-Path -IsValid})]
        [String]
        $AzCopyPath,

        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ | Test-Path -IsValid})]
        [String]
        $VhdLocalFolder,

        [Parameter(Mandatory = $false)]
        [Int32]
        $MaxRetry = 3,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Force
    )

    $ErrorActionPreference = "Stop"

    if ($PSBoundParameters.ContainsKey('AzCopyPath') -and $PSBoundParameters.ContainsKey('VhdLocalFolder'))
    {
        if (!(Test-Path $AzCopyPath -PathType Leaf))
        {
            throw ($Strings.ErrorAzCopyPathInvalid -f $AzCopyPath)
        }

        if (!(Test-Path $VhdLocalFolder -PathType Container))
        {
            Write-Verbose ($Strings.MsgCreateVhdFolder -f $VhdLocalFolder) -Verbose
            $null = New-Item -Path $VhdLocalFolder -ItemType "directory"
        }

        $env:AZCOPY_DEFAULT_SERVICE_API_VERSION = $AzCopyServiceAPIVersion
        $useAzCopy = $true
    }
    elseif ($PSBoundParameters.ContainsKey('AzCopyPath') -or $PSBoundParameters.ContainsKey('VhdLocalFolder'))
    {
        throw ($Strings.ErrorAzCopyParameterNotProvided)
    }
    else
    {
        $useAzCopy = $false
    }

    Write-Verbose $Strings.ProgressGetDiskInfo -Verbose
    $sourceVMName = $SourceVM.Name
    Write-Verbose ($Strings.MsgVmName -f $sourceVMName) -Verbose
    $sourceVMResourceGroupName = $SourceVM.ResourceGroupName
    Write-Verbose ($Strings.MsgVmResourceGroup -f $sourceVMResourceGroupName) -Verbose
    $osDiskId = $SourceVM.StorageProfile.OSDisk.ManagedDisk.Id
    $osDiskName = $SourceVM.StorageProfile.OSDisk.Name
    Write-Verbose ($Strings.MsgOsDiskName -f $osDiskName) -Verbose
    $dataDiskIds = $SourceVM.StorageProfile.DataDisks.ManagedDisk.Id
    $dataDiskNames = $SourceVM.StorageProfile.DataDisks.Name
    Write-Verbose ($Strings.MsgDataDiskNames -f ($dataDiskNames -join ", ")) -Verbose

    if ($dataDiskNames.Count -gt 0)
    {
        $diskIds = @($osDiskId) + @($dataDiskIds)
        $diskNames = @($osDiskName) + @($dataDiskNames)
    }
    else
    {
        $diskIds = @($osDiskId)
        $diskNames = @($osDiskName)
    }

    $targetContainerName = ("asrfailback-$sourceVMName-vhds").ToLower()

    Write-Verbose ($Strings.ProgressGetTargetStorageContext) -Verbose

    if ($PSCmdlet.ParameterSetName -eq "Key_Endpoint")
    {
        $targetStorageContext = New-AzStorageContext -Endpoint $TargetStorageEndpoint -StorageAccountName $TargetStorageAccountName -StorageAccountKey $TargetStorageAccountKey
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Key_Env")
    {
        $targetStorageContext = New-AzStorageContext -Environment $TargetEnvironmentName -StorageAccountName $TargetStorageAccountName -StorageAccountKey $TargetStorageAccountKey
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Sas_Endpoint")
    {
        $targetStorageContext = New-AzStorageContext -Endpoint $TargetStorageEndpoint -StorageAccountName $TargetStorageAccountName -SasToken $TargetStorageAccountSasToken
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Sas_Env")
    {
        $targetStorageContext = New-AzStorageContext -Environment $TargetEnvironmentName -StorageAccountName $TargetStorageAccountName -SasToken $TargetStorageAccountSasToken
    }

    $targetContainer = Get-AzStorageContainer -Name $targetContainerName -Context $targetStorageContext -ErrorAction SilentlyContinue
    if ($null -eq $targetContainer)
    {
        Write-Verbose ($Strings.MsgCreateNewContainer -f $targetContainerName) -Verbose
        $targetContainer = New-AzStorageContainer -Name $targetContainerName -Context $targetStorageContext -Permission Off
    }

    if ($PSBoundParameters.ContainsKey('TargetStorageAccountKey'))
    {
        $targetContainerSasUri = New-AzStorageContainerSASToken -Context $targetStorageContext -ExpiryTime((Get-Date).ToUniversalTime()).AddSeconds($SasExpiryDuration) -FullUri -Name $targetContainerName -Permission rw
        $targetContainerUri, $targetSasTokenKey = $targetContainerSasUri -split "\?"
    }
    elseif ($PSBoundParameters.ContainsKey('TargetStorageAccountSasToken'))
    {
        $targetContainerUri = $targetContainer.CloudBlobContainer.Uri
        $targetSasTokenKey = $TargetStorageAccountSasToken
        if ($targetSasTokenKey.Contains('?'))
        {
            $targetSasTokenKey = $targetSasTokenKey.Substring($targetSasTokenKey.IndexOf('?') + 1, $targetSasTokenKey.Length - $targetSasTokenKey.IndexOf('?') - 1)
        }
    }

    $sourceVMDetail = Get-AzVM -ResourceGroupName $sourceVMResourceGroupName -Name $sourceVMName -Status
    $sourceVMStatus = $sourceVMDetail.Statuses[-1].Code
    if ($sourceVMStatus -ne "PowerState/deallocated")
    {
        Write-Verbose ($Strings.ProgressStopVM -f $sourceVMName) -Verbose
        if ($PSCmdlet.ShouldProcess("sourceVM $sourceVMName", "StopVM") -and
            ($Force.IsPresent -or $PSCmdlet.ShouldContinue($Strings.MsgShouldContinueStopVMConfirm, $Strings.MsgShouldContinueStopVMOperation)))
        {
            $stopResult = Stop-AzVM -ResourceGroupName $sourceVMResourceGroupName -Name $sourceVMName -Force -Confirm:$false
            if ($stopResult.Status -ne "Succeeded")
            {
                throw ($Strings.ErrorStopVmFail -f $sourceVMName, $stopResult.Error.Message)
            }
        }
        else
        {
            throw ($Strings.ErrorStopVmCancel -f $sourceVMName)
        }
    }

    $returnVhdUri = @()

    for ($diskNo = 0; $diskNo -lt $diskIds.Count; $diskNo++)
    {
        $diskResourceGroupName = (Get-AzResource -ResourceId $diskIds[$diskNo]).ResourceGroupName
        $diskName = $diskNames[$diskNo]
        Write-Verbose ($Strings.ProgressCopyVHD -f $diskName, $targetContainerName) -Verbose

        $sourceDiskSas = (Grant-AzDiskAccess -ResourceGroupName $diskResourceGroupName -DiskName $diskName -DurationInSecond $SasExpiryDuration -Access Read).AccessSAS

        $tryCount = 0
        while ($true)
        {
            $tryCount += 1
            Write-Verbose ($Strings.MsgCopyVHDTryTime -f $diskName, $tryCount) -Verbose

            try
            {
                if ($useAzCopy)
                {
                    $vhdUri = Copy-DiskVhd -SourceDiskName $diskName -SourceDiskSas $sourceDiskSas `
                                        -TargetContainerName $targetContainerName `
                                        -TargetContainerUri $targetContainerUri `
                                        -AzCopyPath $AzCopyPath `
                                        -VhdLocalFolder $VhdLocalFolder `
                                        -TargetSasTokenKey $targetSasTokenKey `
                                        -TargetStorageContext $targetStorageContext
                }
                else
                {
                    $vhdUri = Copy-DiskVhd -SourceDiskName $diskName -SourceDiskSas $sourceDiskSas `
                                        -TargetContainerName $targetContainerName `
                                        -TargetContainerUri $targetContainerUri `
                                        -TargetStorageContext $targetStorageContext
                }

                break
            }
            catch
            {
                if ($tryCount -le $MaxRetry)
                {
                    Write-Warning ($Strings.WarningFailToCopyVHD -f $diskName, $tryCount, $SleepTime, $_)
                    Start-Sleep -Seconds $SleepTime
                }
                else
                {
                    throw ($Strings.ErrorFailToCopyVHD -f $diskName, $_)
                }
            }
        }
        
        $null = Revoke-AzDiskAccess -ResourceGroupName $diskResourceGroupName -DiskName $diskName -ErrorAction SilentlyContinue
        
        $returnVhdUri += $vhdUri
    }

    return $returnVhdUri
}

# Formats JSON in a nicer format than the built-in ConvertTo-Json does
function Format-Json
{
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Json
    )

    $indent = 0
    ($Json -Split "`n" | ForEach-Object {
        if ($_ -match '[\}\]]\s*,?\s*$') {
            # This line ends with ] or }, decrement the indentation level
            $indent--
        }

        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        if ($_ -match '[\{\[]\s*$') {
            # This line ends with [ or {, increment the indentation level
            $indent++
        }

        $line
    }) -Join "`n"
}

function Compare-DiskUriName
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DiskUri,

        [Parameter(Mandatory = $true)]
        [Int32]
        $DiskNo,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $DiskName
    )

    $blobName = [System.IO.Path]::GetFileNameWithoutExtension($DiskUri)

    [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {$DiskName = $DiskName.replace($_,'_')}

    if ($blobName -ne $DiskName)
    {
        throw ($Strings.ErrorWrongSourceDiskVhdUri -f $DiskNo, $DiskName)
    }
}

<#
 .Synopsis
  Generate ARM template based on source VM, disk URIs and target environment.

 .Description
  - Get information of related resources, including disks, network, and storage account
  - Generate a parameter file to the given path
  - Generate a template file to the given path
  - Return the paths to the generated files.

 .Example
  Prepare-AzSiteRecoveryVMFailBack -SourceContextName $sourceContextName -SourceVM $sourceVM -SourceDiskVhdUris $uris -TargetResourceLocation $location -TargetContextName $targetContextName -ArmTemplateDestinationPath $path
  Prepare-AzSiteRecoveryVMFailBack -SourceContextName $sourceContextName -SourceVM $sourceVM -SourceDiskVhdUris $uris -TargetResourceLocation $location -TargetVM $targetVM -TargetContextName $targetContextName -ArmTemplateDestinationPath $path
#>
function Prepare-AzSiteRecoveryVMFailBack
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([String[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SourceContextName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Azure.Commands.Compute.Models.PSVirtualMachine]
        $SourceVM,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $SourceDiskVhdUris,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetResourceLocation,

        [Parameter(Mandatory = $true, ParameterSetName="ReplaceExisting")]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Azure.Commands.Compute.Models.PSVirtualMachine]
        $TargetVM,

        [Parameter(Mandatory = $true, ParameterSetName="ReplaceExisting")]
        [Parameter(Mandatory = $true, ParameterSetName="CreateNew")]
        [ValidateNotNullOrEmpty()]
        [String]
        $TargetContextName,

        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ | Test-Path -IsValid})]
        [String]
        $ArmTemplateDestinationPath,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Force
    )

    $ErrorActionPreference = "Stop"

    # Prepare for output files
    if (!(Test-Path $ArmTemplateDestinationPath -PathType Container))
    {
        Write-Verbose ($Strings.MsgCreateTemplateDestFolder -f $ArmTemplateDestinationPath) -Verbose
        $null = New-Item -Path $ArmTemplateDestinationPath -ItemType "directory"
    }

    $vmName = $SourceVM.Name

    $parameterFilePath = Join-Path -Path $ArmTemplateDestinationPath -ChildPath "$vmName-ParameterFile.json"
    $templateFilePath = Join-Path -Path $ArmTemplateDestinationPath -ChildPath "$vmName-TemplateFile.json"
    $outputFilePaths = @($parameterFilePath, $templateFilePath)

    foreach ($outputFilePath in $outputFilePaths)
    {
        if (!(Test-Path $outputFilePath -PathType Leaf) -or 
            ($PSCmdlet.ShouldProcess("$outputFilePath", "Overwrite") -and
            ($Force.IsPresent -or $PSCmdlet.ShouldContinue(($Strings.MsgShouldContinueOverwriteConfirm -f $outputFilePath), $Strings.MsgShouldContinueOverwriteOperation))))
        {
            $null = New-Item -Path $outputFilePath -ItemType "file" -Force -Confirm:$false
        }
        else
        {
            throw ($Strings.ErrorOverwriteFileCancel -f $outputFilePath)
        }
    }
    
    # Template variables
    $templateFile = [ordered]@{
        "`$schema" = "http://schema.management.azure.com/schemas/$schemaVersion/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        parameters = [ordered]@{
            location = @{
                type = "String"
            }
            vmName = @{
                type = "String"
            }
            vmSize = @{
                type = "String"
            }
            storageAccountSkuName = @{
                type = "String"
            }
            diskCreateOption = @{
                type = "String"
            }
            osDiskName = @{
                type = "String"
            }
            osType = @{
                type = "String"
            }
            osDiskCaching = @{
                type = "String"
            }
            osDiskSourceUri = @{
                type = "String"
            }
        }
        resources = @($OsDiskTemplating)
    }

    $vmTemplating = [ordered]@{
        type = "Microsoft.Compute/virtualMachines"
        name = "[parameters('vmName')]"
        apiVersion = $VmArmAPIVersion
        location = "[parameters('location')]"
        properties = [ordered]@{
            hardwareProfile = [ordered]@{
                vmSize = "[parameters('vmSize')]"
            }
            storageProfile = [ordered]@{
                osDisk = $OsDiskStorageProfile
            }
            networkProfile = [ordered]@{
                networkInterfaces = @()
            }
        }
        dependsOn = @(
            "[resourceId('Microsoft.Compute/disks/', parameters('osDiskName'))]"
        )
    }

    $networkInterfaceTemplating = [ordered]@{
        type = "Microsoft.Network/networkInterfaces"
        name = "[parameters('networkInterfaceName')]"
        apiVersion = $NetworkArmAPIVersion
        location = "[parameters('location')]"
        properties = [ordered]@{
            ipConfigurations = @(
                [ordered]@{
                    name = "[parameters('ipConfigurationName')]"
                    properties = [ordered]@{
                        subnet = [ordered]@{
                            id = "[concat(resourceId('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName')), '/subnets/', parameters('subnetName'))]"
                        }
                        privateIPAllocationMethod = "[parameters('privateIPAllocationMethod')]"
                        privateIPAddress = "[parameters('privateIPAddress')]"
                        privateIPAddressVersion = "[parameters('privateIPAddressVersion')]"
                    }
                }
            )
        }
        dependsOn = @("[resourceId('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName'))]")
    }

    # Get info from source VM
    $null = Get-AzContext -Name $SourceContextName | Set-AzContext
    
    # VM basic info and OS disk
    $vmSize = $SourceVM.HardwareProfile.VmSize

    $osDiskName = $SourceVM.StorageProfile.OsDisk.Name
    $osDiskSourceUri = $SourceDiskVhdUris[0]
    [String]$osType = $sourceVM.StorageProfile.OsDisk.OsType
    [String]$osDiskCaching = $sourceVM.StorageProfile.OsDisk.Caching

    $null = Compare-DiskUriName -DiskUri $osDiskSourceUri -DiskNo 0 -DiskName $osDiskName

    # Storage account type
    [String]$storageAccountSkuName = $SourceVM.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
    # When sourceVM is deallocated
    if ([String]::IsNullOrEmpty($storageAccountSkuName)) 
    {
        $storageAccountSkuName = (Get-AzResource -ResourceId $SourceVM.StorageProfile.OsDisk.ManagedDisk.Id).Sku.Name
    }

    if (!($storageAccountSkuName -like "*_*")) 
    {
        if ($storageAccountSkuName.Length -ge 8) 
        {
            $storageAccountSkuName = $storageAccountSkuName.Insert($storageAccountSkuName.Length - 3, "_")
        } 
        else 
        {
            throw ($Strings.ErrorInvalidStorageAccountType -f $SourceVM.Name)
        }
    }

    # Parameter file content variable
    $parametersFile = [ordered]@{
        "`$schema" = "https://schema.management.azure.com/schemas/$SchemaVersion/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = [ordered]@{
            location = @{
                value = $TargetResourceLocation
            }
            vmName = @{
                value = $vmName
            }
            vmSize = @{
                value = $vmSize
            }
            storageAccountSkuName = @{
                value = $storageAccountSkuName
            }
            diskCreateOption = @{
                value = "Attach"
            }
            osDiskName = @{
                value = $osDiskName
            }
            osType = @{
                value = $osType
            }
            osDiskCaching = @{
                value = $osDiskCaching
            }
            osDiskSourceUri = @{
                value = $osDiskSourceUri
            }
        }
    }

    # Data disks
    $dataDiskLuns = $SourceVM.StorageProfile.DataDisks.Lun

    if ($SourceDiskVhdUris.Count -ne ($dataDiskLuns.Count + 1))
    {
        throw ($Strings.ErrorWrongSourceDiskVhdUrisCount -f ($dataDiskLuns.Count + 1), $SourceDiskVhdUris.Count)
    }

    if ($dataDiskLuns.Count -gt 0)
    {
        $dataDiskNames = $SourceVM.StorageProfile.DataDisks.Name
        $dataDiskSourceUris = $SourceDiskVhdUris[1..($SourceDiskVhdUris.Count - 1)]
        $dataDiskSizeGB = $SourceVM.StorageProfile.DataDisks.DiskSizeGB

        $dependsOnDataDisk = @()
        for ($dataDiskNo = 0; $dataDiskNo -lt $dataDiskLuns.Count; $dataDiskNo++)
        {
            $dataDiskName = @($dataDiskNames)[$dataDiskNo]
            $null = Compare-DiskUriName -DiskUri $dataDiskSourceUris[$dataDiskNo] -DiskNo ($dataDiskNo + 1) -DiskName $dataDiskName

            $dependsOnDataDisk += "[resourceId('Microsoft.Compute/disks/', parameters('dataDiskNames')[$dataDiskNo])]"
        }

        # When sourceVM is deallocated, get disk size by getting disks first
        if (!($dataDiskSizeGB -match '[0-9]'))
        {
            $dataDiskIds = $SourceVM.StorageProfile.DataDisks.ManagedDisk.Id
            $dataDiskSizeGB = @()

            foreach ($dataDiskId in $dataDiskIds)
            {
                $dataDiskSizeGB += (Get-AzResource -ResourceId $dataDiskId).Properties.diskSizeGB
            }
        }

        $templateFile["parameters"] += [ordered]@{
            dataDiskLuns = @{
                type = "Array"
            }
            dataDiskNames = @{
                type = "Array"
            }
            dataDiskSourceUri = @{
                type = "Array"
            }
            dataDiskSizeGB = @{
                type = "Array"
            }
        }

        $parametersFile["parameters"] += [ordered]@{
            dataDiskLuns = @{
                value = @($dataDiskLuns)
            }
            dataDiskNames = @{
                value = @($dataDiskNames)
            }
            dataDiskSourceUri = @{
                value = @($dataDiskSourceUris)
            }
            dataDiskSizeGB = @{
                value = @($dataDiskSizeGB)
            }
        }

        $templateFile["resources"] += $DataDiskTemplating
        $vmTemplating["properties"]["storageProfile"] += $DataDiskStorageProfile
        $vmTemplating["dependsOn"] += $dependsOnDataDisk
    }
    
    # Network
    if ($PSCmdlet.ParameterSetName -eq "ReplaceExisting")
    {
        $nicObjects = $TargetVM.NetworkProfile.NetworkInterfaces
        foreach ($nicObject in $nicObjects)
        {
            $primary = $nicObject.primary
            if($null -eq $primary)
            {
                $primary = $false
            }

            $vmTemplating["properties"]["networkProfile"]["networkInterfaces"] += [ordered]@{
                id = $nicObject.Id
                properties = @{
                    primary = $primary
                }
            }
        }
    }
    else
    {
        $nicObjectId = ($SourceVM.NetworkProfile.NetworkInterfaces | Where-Object {$_.Primary -eq $true}).Id
        if($null -eq $nicObjectId)
        {
            $nicObjectId = $SourceVM.NetworkProfile.NetworkInterfaces[0].Id
        }

        $nicObject = Get-AzResource -ResourceId $nicObjectId
        $networkInterfaceName =  $nicObject.Name

        $ipConfig = $nicObject.Properties.ipConfigurations | Where-Object {$_.properties.primary -eq $true}
        if($null -eq $ipConfig)
        {
            $ipConfig = $nicObject.Properties.ipConfigurations[0]
        }

        $ipConfigurationName = $ipConfig.Name

        $privateIPAllocationMethod = $ipConfig.Properties.PrivateIPAllocationMethod
        $privateIPAddress = $ipConfig.Properties.PrivateIPAddress
        $privateIPAddressVersion = $ipConfig.Properties.PrivateIPAddressVersion

        if ($null -ne $ipConfig.Properties.PublicIPAddress)
        {
            $publicIpObject = Get-AzResource -ResourceId $ipConfig.Properties.PublicIPAddress.Id
            $publicIpAddressName = $publicIpObject.Name
            $publicIPAllocationMethod = $publicIpObject.Properties.PublicIPAllocationMethod
            $idleTimeoutInMinutes = $publicIpObject.Properties.IdleTimeoutInMinutes
            $publicIpAddressVersion = $publicIpObject.Properties.PublicIPAddressVersion

            $networkInterfaceTemplating["properties"]["ipConfigurations"][0]["properties"] += @{
                publicIpAddress = [ordered]@{
                    id = "[resourceId('Microsoft.Network/publicIPAddresses/', parameters('publicIpAddressName'))]"
                }
            }

            $networkInterfaceTemplating["dependsOn"] += "[resourceId('Microsoft.Network/publicIPAddresses/', parameters('publicIpAddressName'))]"

            $templateFile["parameters"] += [ordered]@{
                publicIpAddressName = @{
                    type = "String"
                }
                publicIpAddressSkuName = @{
                    type = "String"
                }
                publicIPAllocationMethod = @{
                    type = "String"
                }
                idleTimeoutInMinutes = @{
                    type = "Int"
                }
                publicIpAddressVersion = @{
                    type = "String"
                }
            }

            $parametersFile["parameters"] += [ordered]@{
                publicIpAddressName = @{
                    value = $publicIpAddressName
                }
                publicIpAddressSkuName = @{
                    value = "Basic"
                }
                publicIPAllocationMethod = @{
                    value = $publicIPAllocationMethod
                }
                idleTimeoutInMinutes = @{
                    value = $idleTimeoutInMinutes
                }
                publicIpAddressVersion = @{
                    value = $publicIpAddressVersion
                }
            }
            
            $templateFile["resources"] += $PublicIpAddressTemplating
        }

        $subnetId = $ipConfig.Properties.Subnet.Id
        $null = $subnetId -match '(.+/resourceGroups/)(?<virtualNetworkResourceGroupName>.+)(/providers/.+)(/VirtualNetworks/)(?<virtualNetworkName>.+)(/subnets/)(?<subnetName>.+)'
        $virtualNetworkName = $Matches.virtualNetworkName
        $virtualNetworkResourceGroupName = $Matches.virtualNetworkResourceGroupName
        $vnet = Get-AzVirtualNetwork -ResourceGroupName $virtualNetworkResourceGroupName -Name $virtualNetworkName
        $virtualNetworkAddressPrefixes = $vnet.AddressSpace.AddressPrefixes
        $subnetName = $Matches.subnetName
        $subnetConfig = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
        $subnetAddressPrefix = @($subnetConfig.AddressPrefix)[0]

        $templateFile["parameters"] += [ordered]@{
            networkInterfaceName = @{
                type = "String"
            }
            ipConfigurationName = @{
                type = "String"
            }
            privateIPAllocationMethod = @{
                type = "String"
            }
            privateIPAddress = @{
                type = "String"
            }
            privateIPAddressVersion = @{
                type = "String"
            }
            virtualNetworkName = @{
                type = "String"
            }
            virtualNetworkAddressPrefixes = @{
                type = "Array"
            }
            subnetName = @{
                type = "String"
            }
            subnetAddressPrefix = @{
                type = "String"
            }
        }

        $parametersFile["parameters"] += [ordered]@{
            networkInterfaceName = @{
                value = $networkInterfaceName
            }
            ipConfigurationName = @{
                value = $ipConfigurationName
            }
            privateIPAllocationMethod = @{
                value = $privateIPAllocationMethod
            }
            privateIPAddress = @{
                value = $privateIPAddress
            }
            privateIPAddressVersion = @{
                value = $privateIPAddressVersion
            }
            virtualNetworkName = @{
                value = $virtualNetworkName
            }
            virtualNetworkAddressPrefixes = @{
                value = @($virtualNetworkAddressPrefixes)
            }
            subnetName = @{
                value = $subnetName
            }
            subnetAddressPrefix = @{
                value = $subnetAddressPrefix
            }
        }

        $templateFile["resources"] += $VirtualNetworkTemplating
        $templateFile["resources"] += $networkInterfaceTemplating

        $vmTemplating["properties"]["networkProfile"]["networkInterfaces"] += @{
            id = "[resourceId('Microsoft.Network/networkInterfaces', parameters('networkInterfaceName'))]"
            properties = @{
                primary = $true
            }
        }
        
        $vmTemplating["dependsOn"] += "[resourceId('Microsoft.Network/networkInterfaces/', parameters('networkInterfaceName'))]"
    }

    # Boot diagnostics
    if ($PSCmdlet.ParameterSetName -eq "ReplaceExisting")
    {
        $bootDiagnosticsStorageUri = $TargetVM.DiagnosticsProfile.BootDiagnostics.storageUri
        $bootDiagnosticsEnabled = $TargetVM.DiagnosticsProfile.BootDiagnostics.Enabled
        if (![String]::IsNullOrEmpty($bootDiagnosticsStorageUri))
        {
            $templateFile["parameters"] += [ordered]@{
                bootDiagnosticsEnabled = @{
                    type = "Bool"
                }
                bootDiagnosticsStorageUri = @{
                    type = "String"
                }
            }

            $parametersFile["parameters"] += [ordered]@{
                bootDiagnosticsEnabled = @{
                    value = $bootDiagnosticsEnabled
                }
                bootDiagnosticsStorageUri = @{
                    value = $bootDiagnosticsStorageUri
                }
            }

            $vmTemplating["properties"] += $BootDiagnosticsTemplating
        }
    }
    else
    {
        $bootDiagnosticsStorageUri = $SourceVM.DiagnosticsProfile.BootDiagnostics.storageUri
        if (![String]::IsNullOrEmpty($bootDiagnosticsStorageUri))
        {
            $storageAccountName = $bootDiagnosticsStorageUri.Substring($bootDiagnosticsStorageUri.LastIndexOf("/") + 1, $bootDiagnosticsStorageUri.IndexOf(".") - $bootDiagnosticsStorageUri.LastIndexOf("/") - 1)
            $targetEndpoint = (Get-AzContext -Name $TargetContextName).Environment.StorageEndpointSuffix
            $bootDiagnosticsStorageUri = "https://$storageAccountName.blob.$targetEndpoint"
            $bootDiagnosticsEnabled = $SourceVM.DiagnosticsProfile.BootDiagnostics.Enabled

            $templateFile["parameters"] += [ordered]@{
                bootDiagnosticsEnabled = @{
                    type = "Bool"
                }
                bootDiagnosticsStorageUri = @{
                    type = "String"
                }
                storageAccountName = @{
                    type = "String"
                }
                storageAccountSupportsHttpsTrafficOnly = @{
                    type = "Bool"
                }
                storageAccountKind = @{
                    type = "String"
                }
            }

            $parametersFile["parameters"] += [ordered]@{
                bootDiagnosticsEnabled = @{
                    value = $bootDiagnosticsEnabled
                }
                bootDiagnosticsStorageUri = @{
                    value = $bootDiagnosticsStorageUri
                }
                storageAccountName = @{
                    value = $storageAccountName
                }
                storageAccountSupportsHttpsTrafficOnly = @{
                    value = $true
                }
                storageAccountKind = @{
                    value = "Storage"
                }
            }

            $templateFile["resources"] += $StorageAccountTemplating
            $vmTemplating["properties"] += $BootDiagnosticsTemplating
            $vmTemplating["dependsOn"] += "[resourceId('Microsoft.Storage/storageAccounts/', parameters('storageAccountName'))]"
        }
    }

    # Generate json files
    Write-Verbose ($Strings.MsgWriteIntoFile -f $parameterFilePath) -Verbose
    $parametersFile | ConvertTo-Json -Depth 5 | Format-Json | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Out-File $parameterFilePath

    $templateFile["resources"] += $vmTemplating
    Write-Verbose ($Strings.MsgWriteIntoFile -f $templateFilePath) -Verbose
    $templateFile | ConvertTo-Json -Depth 10 | Format-Json | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Out-File $templateFilePath

    # Display info of new disk vhds
    Write-Verbose ($Strings.MsgSourceDiskVhdUris -f ($SourceDiskVhdUris -join ", ")) -Verbose

    $null = Get-AzContext -Name $TargetContextName | Set-AzContext

    # If replace existing VM, ask to delete the target VM
    if ($PSCmdlet.ParameterSetName -eq "ReplaceExisting")
    {
        Write-Verbose ($Strings.MsgDisksAttachedToTheVMToBeDeleted -f $TargetVM.Name) -Verbose
        $osDiskName = $TargetVM.StorageProfile.OSDisk.Name
        Write-Verbose ($Strings.MsgOsDiskName -f $osDiskName) -Verbose
        $dataDiskNames = $TargetVM.StorageProfile.DataDisks.Name
        Write-Verbose ($Strings.MsgDataDiskNames -f ($dataDiskNames -join ", ")) -Verbose

        if ($PSCmdlet.ShouldProcess($TargetVM.Name, ($Strings.MsgDeleteVMOperationName)) -and
            ($Force.IsPresent -or $PSCmdlet.ShouldContinue(($Strings.MsgShouldContinueDeleteVMConfirm -f $TargetVM.Name), $Strings.MsgShouldContinueDeleteVMOperation)))
        {
            $null = Remove-AzVM -Name $TargetVM.Name -ResourceGroupName $TargetVM.ResourceGroupName -Force -Confirm:$false
        }
        else
        {
            throw ($Strings.ErrorDeleteVMCancel -f $TargetVM.Name, $templateFilePath, $parameterFilePath)
        }
    }

    return @($templateFilePath, $parameterFilePath)
}

Export-ModuleMember -Function Copy-AzSiteRecoveryVmVHD
Export-ModuleMember -Function Prepare-AzSiteRecoveryVMFailBack
