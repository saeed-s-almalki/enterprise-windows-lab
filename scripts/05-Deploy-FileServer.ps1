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

foreach ($s in $cfg.Shares) {
    Write-Host "==> Provisioning share $($s.Name)..." -ForegroundColor Cyan
    if (-not (Test-Path $s.Path)) { New-Item -Path $s.Path -ItemType Directory -Force | Out-Null }

    # Resolve the department group to its SID — using the SID directly avoids
    # "identity could not be translated" errors on a freshly-created group.
    $grp = Get-ADGroup -Filter "Name -eq '$($s.Group)'"
    $sid = [System.Security.Principal.SecurityIdentifier]$grp.SID

    # ── NTFS: disable inheritance, grant Admins + department group ──
    $acl = Get-Acl $s.Path
    $acl.SetAccessRuleProtection($true, $false)   # remove inherited perms
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        'BUILTIN\Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow')))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        $sid,'Modify','ContainerInherit,ObjectInherit','None','Allow')))
    Set-Acl -Path $s.Path -AclObject $acl

    # ── SMB share: department group = Change ──
    if (-not (Get-SmbShare -Name $s.Name -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $s.Name -Path $s.Path `
            -FullAccess 'BUILTIN\Administrators' `
            -ChangeAccess $sid | Out-Null
        Write-Host "  + Share \\$($env:COMPUTERNAME)\$($s.Name) ready ($($s.Group)=Modify)" -ForegroundColor Green
    }
}

Write-Host "File server provisioning complete." -ForegroundColor Cyan
