﻿param (
    [string] $pull_server,
    [string] $guid
)

configuration ConfigureDSCPullServer {
        [string] $NodeId, 
        [string] $PullServer
    )  
    
    Node "localhost"
    {
        LocalConfigurationManager

Enable-PSRemoting -Confirm:$false 
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force:$true

tzutil.exe /s "Central Standard Time" 
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000

Get-Disk | Where { $_.PartitionStyle -eq "RAW" } | Initialize-Disk -PartitionStyle MBR 
Get-Disk | Where { $_.NumberOfPartitions -eq 0 } |   
    New-Partition -AssignDriveLetter -UseMaximumSize |
    Format-Volume -FileSystem NTFS -Force -Confirm:$false

$dsc_path = Join-Path -Path $ENV:SystemDrive -ChildPath "DSCResources"
New-Item -Path $dsc_path -ItemType Directory 
Set-Location -Path $dsc_path

ConfigureDSCPullServer -NodeId $guid -PullServer $pull_server
Add-Content -Encoding Ascii -Path ( Join-Path -Path $dsc_path -ChildPath $guid ) -Value $guid