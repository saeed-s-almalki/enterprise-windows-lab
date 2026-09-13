<#
.SYNOPSIS
    Points a member server / workstation DNS at the DC and joins it to the
    domain. Run this ON THE CLIENT machine (not the DC).
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
$cfg = Import-PowerShellDataFile -Path $ConfigPath

Write-Host "==> Pointing DNS at the Domain Controller ($($cfg.Network.DcStaticIP))..." -ForegroundColor Cyan
$if = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceIndex $if.ifIndex -ServerAddresses $cfg.Network.DcStaticIP

Write-Host "==> Joining domain $($cfg.Domain.Name)..." -ForegroundColor Cyan
$cred = Get-Credential -Message "Enter domain admin credentials (e.g. $($cfg.Domain.NetbiosName)\Administrator)"

Add-Computer -DomainName $cfg.Domain.Name -Credential $cred -Restart -Force
# Machine reboots and comes up as a domain member.
