<#
.SYNOPSIS
    Creates and links baseline Group Policy Objects:
      1. Password & lockout baseline (domain root)
      2. Desktop standardization for Workstations OU
    Demonstrates GPO creation, registry-backed settings, and linking.
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
Import-Module GroupPolicy
$cfg  = Import-PowerShellDataFile -Path $ConfigPath
$base = (Get-ADDomain).DistinguishedName

# ── 1. Password / lockout baseline (Default Domain Policy) ───────────
Write-Host "==> Applying password & lockout baseline..." -ForegroundColor Cyan
Set-ADDefaultDomainPasswordPolicy -Identity $cfg.Domain.Name `
    -MinPasswordLength 12 `
    -PasswordHistoryCount 12 `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -ComplexityEnabled $true `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 15) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 15)

# ── 2. Workstation standardization GPO ───────────────────────────────
$gpoName = 'Workstation-Baseline'
if (-not (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue)) {
    New-GPO -Name $gpoName | Out-Null
    Write-Host "  + GPO created: $gpoName" -ForegroundColor Green
}

# Auto-lock screen after 10 min (900s) — a common corporate baseline
Set-GPRegistryValue -Name $gpoName `
    -Key 'HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop' `
    -ValueName 'ScreenSaveTimeOut' -Type String -Value '600'
Set-GPRegistryValue -Name $gpoName `
    -Key 'HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop' `
    -ValueName 'ScreenSaverIsSecure' -Type String -Value '1'

# Set a corporate desktop wallpaper policy path (placeholder UNC)
Set-GPRegistryValue -Name $gpoName `
    -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System' `
    -ValueName 'Wallpaper' -Type String `
    -Value "\\$($env:COMPUTERNAME)\NETLOGON\corp-wallpaper.jpg"

# Link to Workstations OU
$wsOU = "OU=Workstations,$base"
if (-not (Get-GPInheritance -Target $wsOU).GpoLinks.DisplayName -contains $gpoName) {
    New-GPLink -Name $gpoName -Target $wsOU -LinkEnabled Yes -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  + Linked $gpoName -> Workstations OU" -ForegroundColor Green
}

Write-Host "GPO baseline applied." -ForegroundColor Cyan
