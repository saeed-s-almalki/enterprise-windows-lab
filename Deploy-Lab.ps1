<#
.SYNOPSIS
    One-command orchestrator for the Enterprise Windows Lab.

    Because promoting a Domain Controller forces a reboot, deployment runs in
    two stages. The script tracks which stage to run using a marker file, so
    you simply run it, let the server reboot, then run it once more.

.EXAMPLE
    PS> .\Deploy-Lab.ps1        # Stage 1 (DC promo) -> reboot -> run again for Stage 2
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
$marker = "$PSScriptRoot\.stage1-done"
$s      = "$PSScriptRoot\scripts"

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run this script in an ELEVATED PowerShell session."
    }
}
Assert-Admin

if (-not (Test-Path $marker)) {
    Write-Host "`n===== STAGE 1: Domain Controller =====" -ForegroundColor Yellow
    New-Item -Path $marker -ItemType File -Force | Out-Null
    & "$s\01-Install-DomainController.ps1" -ConfigPath $ConfigPath
    # 01 reboots the server. After reboot, re-run Deploy-Lab.ps1 for Stage 2.
}
else {
    Write-Host "`n===== STAGE 2: Services & Objects =====" -ForegroundColor Yellow
    & "$s\02-Configure-DHCP.ps1"      -ConfigPath $ConfigPath
    & "$s\03-Create-OUs-Users.ps1"    -ConfigPath $ConfigPath
    & "$s\04-Configure-GPOs.ps1"      -ConfigPath $ConfigPath
    & "$s\05-Deploy-FileServer.ps1"   -ConfigPath $ConfigPath
    Remove-Item $marker -Force
    Write-Host "`n✅ Deployment complete. Run scripts\Test-Lab.ps1 to validate." -ForegroundColor Green
}
