<#
.SYNOPSIS
    Promotes this Windows Server into the first Domain Controller of a new
    forest, including DNS. Sets a static IP first (AD requires it).
.NOTES
    Run elevated on a fresh Windows Server 2019/2022. Reboots automatically.
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
$cfg = Import-PowerShellDataFile -Path $ConfigPath

Write-Host "==> [1/6] Configuring static IP $($cfg.Network.DcStaticIP)..." -ForegroundColor Cyan
$if = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1
# Remove any existing IPv4 to avoid duplicates, then assign static
Get-NetIPAddress -InterfaceIndex $if.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceIndex $if.ifIndex -Confirm:$false -ErrorAction SilentlyContinue

New-NetIPAddress -InterfaceIndex $if.ifIndex `
    -IPAddress $cfg.Network.DcStaticIP `
    -PrefixLength $cfg.Network.PrefixLength `
    -DefaultGateway $cfg.Network.Gateway | Out-Null

# Point DNS at self (loopback) — required before promotion
Set-DnsClientServerAddress -InterfaceIndex $if.ifIndex -ServerAddresses '127.0.0.1'

Write-Host "==> [2/6] Installing AD DS + DNS roles..." -ForegroundColor Cyan
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools | Out-Null

Write-Host "==> [3/6] Promoting to Domain Controller ($($cfg.Domain.Name))..." -ForegroundColor Cyan
$safeModePwd = Read-Host "Enter a DSRM (Safe Mode) password" -AsSecureString

Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainName $cfg.Domain.Name `
    -DomainNetbiosName $cfg.Domain.NetbiosName `
    -ForestMode $cfg.Domain.FunctionLevel `
    -DomainMode $cfg.Domain.FunctionLevel `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $safeModePwd `
    -Force:$true `
    -NoRebootOnCompletion:$false

# Server reboots automatically. Continue with 02-Configure-DHCP.ps1 after reboot.
