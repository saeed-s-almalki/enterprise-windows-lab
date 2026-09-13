<#
.SYNOPSIS
    Post-deployment validation. Prints a green/red checklist so you can prove
    the environment is healthy (and screenshot it for documentation).
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$cfg   = Import-PowerShellDataFile -Path $ConfigPath
$pass  = 0; $fail = 0

function Test-Item($name, [scriptblock]$check) {
    try {
        if (& $check) { Write-Host "  [ PASS ] $name" -ForegroundColor Green; $script:pass++ }
        else          { Write-Host "  [ FAIL ] $name" -ForegroundColor Red;   $script:fail++ }
    } catch          { Write-Host "  [ FAIL ] $name — $($_.Exception.Message)" -ForegroundColor Red; $script:fail++ }
}

Write-Host "`n=== Enterprise Windows Lab — Health Check ===`n" -ForegroundColor Cyan

Test-Item "AD DS service running"        { (Get-Service NTDS).Status -eq 'Running' }
Test-Item "DNS service running"          { (Get-Service DNS).Status  -eq 'Running' }
Test-Item "DHCP service running"         { (Get-Service DHCPServer).Status -eq 'Running' }
Test-Item "Domain reachable"             { (Get-ADDomain).DNSRoot -eq $cfg.Domain.Name }
Test-Item "All OUs present"              { ($cfg.OrganizationalUnits | Where-Object { Get-ADOrganizationalUnit -Filter "Name -eq '$_'" }).Count -eq $cfg.OrganizationalUnits.Count }
Test-Item "Demo users created"           { (Get-ADUser -Filter * ).Count -ge $cfg.Users.Count }
Test-Item "DHCP scope active"            { (Get-DhcpServerv4Scope).State -contains 'Active' }
Test-Item "Password policy >= 12 chars"  { (Get-ADDefaultDomainPasswordPolicy).MinPasswordLength -ge 12 }
Test-Item "Workstation-Baseline GPO"     { Get-GPO -Name 'Workstation-Baseline' -ErrorAction Stop }
Test-Item "Department shares online"     { (Get-SmbShare | Where-Object Name -like '*-Share').Count -ge 1 }

$resultColor = if ($fail -eq 0) { 'Green' } else { 'Yellow' }
Write-Host "`n---------------------------------------------" -ForegroundColor DarkGray
Write-Host ("  RESULT: {0} passed / {1} failed" -f $pass, $fail) -ForegroundColor $resultColor
Write-Host "---------------------------------------------`n" -ForegroundColor DarkGray
