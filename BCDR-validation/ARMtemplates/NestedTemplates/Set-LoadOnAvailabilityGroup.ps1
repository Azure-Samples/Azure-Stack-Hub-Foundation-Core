[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted;
Install-Module -Name dbatools -Force;

$SkriptPath = "C:\Skripte"
$DownloadPath = "C:\Temp"

mkdir $SkriptPath
mkdir $DownloadPath

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

$Skript2 | Out-File "$SkriptPath\SQLLoop.ps1"

1..20 | ForEach-Object {
    schtasks /create /tn "SQLLoop$_" /sc onstart /delay 0000:30 /rl highest /ru system /tr "powershell.exe -file $SkriptPath\SQLLoop.ps1 -TableName Load$_"
    schtasks /run /tn "SQLLoop$_"
}
