[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted;
Install-Module -Name 7Zip4PowerShell -Force;
Install-Module -Name dbatools -Force;

$SkriptPath = "C:\Skripte"
$LdfPath = "F:\LOG"
$MdfPath = "F:\DATA"
$DownloadPath = "C:\Temp"
$FileName = "StackOverflow2010.7z"
$DbName = "StackOverflow2010"
$NewDbName = "Initial-StackOverflow2010" 

mkdir $SkriptPath
mkdir $DownloadPath

Start-BitsTransfer https://downloads.brentozar.com/StackOverflow2010.7z -Destination "$DownloadPath\$FileName"
Expand-7Zip "$DownloadPath\$FileName" -TargetPath $DownloadPath
Get-Childitem -Path $DownloadPath -Filter "*.ldf" | Move-Item -Destination $LdfPath
Get-Childitem -Path $DownloadPath -Filter "*.mdf" | Move-Item -Destination $MdfPath
$fileStructure = New-Object System.Collections.Specialized.StringCollection
$fileStructure.Add($(Get-Childitem -Path $LdfPath -Filter "$DBName*" | Select -ExpandProperty FullName))
$filestructure.Add($(Get-Childitem -Path $MdfPath -Filter "$DBName*" | Select -ExpandProperty FullName))
Mount-DbaDatabase -SqlInstance $env:COMPUTERNAME -Database $DbName -FileStructure $fileStructure
Rename-DbaDatabase -SqlInstance $env:COMPUTERNAME -Database $DbName -DatabaseName $NewDbName -Move -FileName "<DBN>"

$Skript = 'Import-Module dbatools
$BackupFolder = "F:\Backup"
$HaBackupFolder = "F:\HaBackup"
$ForEverLoop = $true
mkdir $BackupFolder
mkdir $HaBackupFolder
$Database = Get-DbaDatabase -SqlInstance $env:COMPUTERNAME -Database "Initial-StackoverFlow2010"
$Backup = $Database | Backup-DbaDatabase -Path $BackupFolder -CompressBackup
1..5 | ForEach-Object {
if ($null -eq $(Get-DbaDatabase -SqlInstance $env:COMPUTERNAME -Database "Initial-StackoverFlow2010-$_")){
Rename-DbaDatabase -SqlInstance $env:COMPUTERNAME -Database "Initial-StackoverFlow2010" -DatabaseName "Initial-StackoverFlow2010-$_" -Move -FileName "<DBN>"
Restore-DbaDatabase -SqlInstance $env:COMPUTERNAME -Path $Backup.BackupPath
Set-DbaDbRecoveryModel -SqlInstance $env:COMPUTERNAME -RecoveryModel Full -AllDatabases
}
}
$DB = (Get-DbaDatabase -SqlInstance $env:COMPUTERNAME | ? Name -Match "Initial-StackoverFlow2010-").Name
Backup-DbaDatabase -SqlInstance $env:COMPUTERNAME -Path $HaBackupFolder -Database $DB
while ($ForEverLoop -eq $true) {
Restore-DbaDatabase -SqlInstance $env:COMPUTERNAME -Path $HaBackupFolder -WithReplace
Get-Childitem -Path $HaBackupFolder | Remove-Item -Force
Backup-DbaDatabase -SqlInstance $env:COMPUTERNAME -Path $HaBackupFolder -Database $DB
}'

$Skript2 = 'param (
    [parameter(mandatory)] $TableName
)

$endless = $true

if ($null -eq (Get-DbaDatabase -SqlInstance $env:COMPUTERNAME -ExcludeSystem)) {
    New-DbaDatabase -SqlInstance $env:COMPUTERNAME -Name "LoadTest"
}

    $Query1="CREATE TABLE $TableName
    (
     id UNIQUEIDENTIFIER default newid(),
     parent_id UNIQUEIDENTIFIER default newid(),
     name VARCHAR(50) default cast(newid() as varchar(50))
    );"

    $Query2="Declare @Id int
    Set @Id = 1
     While @Id <= 1000000
     Begin
     INSERT INTO $TableName DEFAULT VALUES
     Set @Id = @Id + 1
     End"
    $Query3="CREATE CLUSTERED INDEX [ClusteredSplitThrash] ON [dbo].[$TableName]
    (
     [id] ASC,
     [parent_id] ASC
    );"
    $Query4="Declare @Id int
    Set @Id = 1
    While @Id <= 100
    Begin
    UPDATE $TableName
    SET parent_id = newid(), id = newid();
    Set @Id = @Id + 1
    End"
    $DB = $(Get-DbaDatabase -SqlInstance $env:COMPUTERNAME -ExcludeSystem | Sort-Object -Descending -Property CreateDate | Select -Last 1 | Select -ExpandProperty Name)
    Import-Module dbatools
    Invoke-DbaQuery -SqlInstance $env:COMPUTERNAME -Database $DB -QueryTimeout 2147483647 -Query $Query1
    Invoke-DbaQuery -SqlInstance $env:COMPUTERNAME -Database $DB -QueryTimeout 2147483647 -Query $Query2
    Invoke-DbaQuery -SqlInstance $env:COMPUTERNAME -Database $DB -QueryTimeout 2147483647 -Query $Query3

while ($endless -eq $true)
{
    Invoke-DbaQuery -SqlInstance $env:COMPUTERNAME -Database $DB -QueryTimeout 2147483647 -Query $Query4
    mkdir C:\NulBackup
    Backup-DbaDatabase -Path C:\NulBackup -SqlInstance $env:COMPUTERNAME -Database $DB -CompressBackup
    GCI C:\NulBackup | Remove-Item -Force
}'

$Skript | Out-File "$SkriptPath\EndlessLoop.ps1"
$Skript2 | Out-File "$SkriptPath\SQLLoop.ps1"
schtasks /create /tn "EndlessLoop" /sc onstart /delay 0000:30 /rl highest /ru system /tr "powershell.exe -file $SkriptPath\EndlessLoop.ps1"
schtasks /run /tn "EndlessLoop"

1..20 | ForEach-Object {
    schtasks /create /tn "SQLLoop$_" /sc onstart /delay 0000:30 /rl highest /ru system /tr "powershell.exe -file $SkriptPath\SQLLoop.ps1 -TableName Load$_"
    schtasks /run /tn "SQLLoop$_"
}
