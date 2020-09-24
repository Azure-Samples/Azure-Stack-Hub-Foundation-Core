ConvertFrom-StringData @'
    ###PSLOC
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
