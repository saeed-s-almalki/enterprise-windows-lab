<#
.SYNOPSIS
    Installs the DHCP role, authorizes it in AD, and creates a scope with
    router + DNS options. Run after the DC reboot.
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
$cfg = Import-PowerShellDataFile -Path $ConfigPath

Write-Host "==> Installing DHCP role..." -ForegroundColor Cyan
Install-WindowsFeature DHCP -IncludeManagementTools | Out-Null

Write-Host "==> Authorizing DHCP server in Active Directory..." -ForegroundColor Cyan
Add-DhcpServerInDC -DnsName "$($env:COMPUTERNAME).$($cfg.Domain.Name)" `
    -IPAddress $cfg.Network.DcStaticIP -ErrorAction SilentlyContinue
# Clear the "needs configuration" notification flag
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12' `
    -Name ConfigurationState -Value 2 -ErrorAction SilentlyContinue

Write-Host "==> Creating scope '$($cfg.Dhcp.ScopeName)'..." -ForegroundColor Cyan
Add-DhcpServerv4Scope `
    -Name $cfg.Dhcp.ScopeName `
    -StartRange $cfg.Dhcp.RangeStart `
    -EndRange $cfg.Dhcp.RangeEnd `
    -SubnetMask $cfg.Dhcp.SubnetMask `
    -LeaseDuration ([TimeSpan]::FromDays($cfg.Dhcp.LeaseDays)) `
    -State Active

Write-Host "==> Setting scope options (router + DNS)..." -ForegroundColor Cyan
Set-DhcpServerv4OptionValue -ScopeId $cfg.Dhcp.ScopeId `
    -Router $cfg.Network.Gateway `
    -DnsServer $cfg.Network.DcStaticIP `
    -DnsDomain $cfg.Domain.Name

Write-Host "==> Adding upstream DNS forwarder ($($cfg.Network.DnsForwarder))..." -ForegroundColor Cyan
Add-DnsServerForwarder -IPAddress $cfg.Network.DnsForwarder -ErrorAction SilentlyContinue

Restart-Service dhcpserver
Write-Host "DHCP ready. Leases will hand out $($cfg.Dhcp.RangeStart)-$($cfg.Dhcp.RangeEnd)." -ForegroundColor Green
