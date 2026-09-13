<#
.SYNOPSIS
    Installs the File Server role and creates department shares with matching
    NTFS + SMB permissions (department group = Modify, others = no access).
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
$cfg = Import-PowerShellDataFile -Path $ConfigPath

Write-Host "==> Installing File Server role..." -ForegroundColor Cyan
Install-WindowsFeature FS-FileServer -IncludeManagementTools | Out-Null

$domain = $cfg.Domain.NetbiosName

foreach ($s in $cfg.Shares) {
    Write-Host "==> Provisioning share $($s.Name)..." -ForegroundColor Cyan
    if (-not (Test-Path $s.Path)) { New-Item -Path $s.Path -ItemType Directory -Force | Out-Null }

    # ── NTFS: disable inheritance, grant Admins + department group ──
    $acl = Get-Acl $s.Path
    $acl.SetAccessRuleProtection($true, $false)   # remove inherited perms
    $rules = @(
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            'BUILTIN\Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow')
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$domain\$($s.Group)",'Modify','ContainerInherit,ObjectInherit','None','Allow')
    )
    $rules | ForEach-Object { $acl.AddAccessRule($_) }
    Set-Acl -Path $s.Path -AclObject $acl

    # ── SMB share: department group = Change ──
    if (-not (Get-SmbShare -Name $s.Name -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $s.Name -Path $s.Path `
            -FullAccess "$domain\Domain Admins" `
            -ChangeAccess "$domain\$($s.Group)" | Out-Null
        Write-Host "  + Share \\$($env:COMPUTERNAME)\$($s.Name) ready ($($s.Group)=Modify)" -ForegroundColor Green
    }
}

Write-Host "File server provisioning complete." -ForegroundColor Cyan
