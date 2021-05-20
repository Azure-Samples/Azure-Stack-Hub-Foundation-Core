Param (
    [Parameter(Mandatory = $true, ParameterSetName='ADFSSet')]
	[Parameter(Mandatory = $true, ParameterSetName='AADSet')]
	[Parameter(Mandatory = $true, ParameterSetName='DEFAULTSET')]
    [string]
    $AdminUsername,

    [string]
    $TimeServerIp = "13.86.101.172",

	[Parameter(Mandatory = $true, ParameterSetName='ADFSSet')]
	[Parameter(Mandatory = $true, ParameterSetName='AADSet')]
	[Parameter(Mandatory = $false, ParameterSetName='DEFAULTSET')]
    [string]
    $AdminPassword,

    [Parameter(Mandatory = $true, ParameterSetName='ADFSSet')]
	[Parameter(Mandatory = $true, ParameterSetName='AADSet')]
	[Parameter(Mandatory = $true, ParameterSetName='DEFAULTSET')]
	[ValidateSet(
      "NoDeployment",
      "ADFS",
      "AAD"
    )]
    [string]
    $DeploymentType = "NoDeployment",

	[Parameter(Mandatory = $true, ParameterSetName='AADSet')]
	[string]
	$AzureDirectoryTenantName,

	[Parameter(Mandatory = $true, ParameterSetName='AADSet')]
	[string]
	$AADPassword,

	[Parameter(Mandatory = $true, ParameterSetName='AADSet')]
	[string]
	$AADUserName
)

$ADFSscriptToExecute = @'
    net stop w32time | w32tm /unregister | w32tm /register | net start w32time | 
    w32tm /resync /rediscover | w32tm /config /manualpeerlist:$TimeServer /syncfromflags:MANUAL /reliable:yes /update | w32tm /query /status 

    $adminpass = ConvertTo-SecureString [AdminPassword] -AsPlainText -Force 
    cd C:\CloudDeployment\Setup
    .\InstallAzureStackPOC.ps1 -AdminPassword $adminpass -UseADFS -TimeServer [TimeServerIp] 
'@

$AADscriptToExecute = @'
    net stop w32time | w32tm /unregister | w32tm /register | net start w32time | 
    w32tm /resync /rediscover | w32tm /config /manualpeerlist:$TimeServer /syncfromflags:MANUAL /reliable:yes /update | w32tm /query /status 

	$secureAzureadPassword = ConvertTo-SecureString '[AADPassword]' -AsPlainText -Force
	$InfraAzureDirectoryTenantAdminCredential = New-Object System.Management.Automation.PSCredential ('[AADUserName]', $secureAzureadPassword)
    $adminpass = ConvertTo-SecureString [AdminPassword] -AsPlainText -Force 
    cd C:\CloudDeployment\Setup
    .\InstallAzureStackPOC.ps1 -AdminPassword $adminpass -InfraAzureDirectoryTenantName [AzureDirectoryTenantName] -InfraAzureDirectoryTenantAdminCredentia $InfraAzureDirectoryTenantAdminCredential -TimeServer [TimeServerIp] 
'@

$logMessage = ""
try
{
    if('NoDeployment' -ne $DeploymentType)
    {
		$scriptToExecute = ""
		
		if('ADFS' -eq $DeploymentType)
		{
			#ADFS deployment
			$scriptToExecute = $ADFSscriptToExecute
			$logMessage += "ADFS deployment" 
		}
		else
		{
			#AAD deployment
			$scriptToExecute = $AADscriptToExecute
			$scriptToExecute = $scriptToExecute.Replace('[AADPassword]', $AADPassword)
			$scriptToExecute = $scriptToExecute.Replace('[AzureDirectoryTenantName]', $AzureDirectoryTenantName)
			$scriptToExecute = $scriptToExecute.Replace('[AADUserName]', $AADUserName)
			$logMessage += "AAD deployment" 
		}
        $scriptToExecute = $scriptToExecute.Replace('[AdminPassword]', $AdminPassword)
        $scriptToExecute = $scriptToExecute.Replace('[TimeServerIp]', $TimeServerIp )
        
	    #Autologon
	    $AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
	    Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
	    Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$env:ComputerName\Administrator" -type String  
	    Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$AdminPassword" -type String
	    Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $scriptToExecute

        $registrationParams = @{
            TaskName = 'ASDKDeployment'
            TaskPath = '\'
            Action = $action
            Settings = New-ScheduledTaskSettingsSet -Priority 4
            Force = $true
            Trigger = New-JobTrigger -AtLogOn
            Runlevel = 'Highest'
        }
		# The order of the script matters
		Rename-LocalUser -Name $AdminUsername -NewName Administrator
        Register-ScheduledTask @registrationParams -User "$env:ComputerName\Administrator"
    }
	else 
	{
		Rename-LocalUser -Name $AdminUsername -NewName Administrator
	}

	Restart-Computer -Force
}
catch
{
    $ErrorRecord = $_
    $ErrorRecord | Format-List * -Force
    $ErrorRecord.InvocationInfo | Format-List * -Force
    $exception = $ErrorRecord.Exception
    $logMessage += $exception
}
finally
{
	new-item -path d:\log.txt -ItemType "file" -Value $logMessage -force
}

