<#
.SYNOPSIS
    Builds the OU structure, a security group per department, and demo users
    placed in the correct OU + group. Idempotent (safe to re-run).
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\config\lab-config.psd1"
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
$cfg  = Import-PowerShellDataFile -Path $ConfigPath
$base = (Get-ADDomain).DistinguishedName

foreach ($ou in $cfg.OrganizationalUnits) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $base -ProtectedFromAccidentalDeletion $true
        Write-Host "  + OU created: $ou" -ForegroundColor Green
    }
    # One security group per department (skip infra OUs)
    if ($ou -in @('IT','HR','Finance')) {
        if (-not (Get-ADGroup -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $ou -GroupScope Global -GroupCategory Security `
                -Path "OU=$ou,$base"
        }
    }
}

$securePwd = ConvertTo-SecureString $cfg.DefaultUserPassword -AsPlainText -Force

foreach ($u in $cfg.Users) {
    $sam = ('{0}.{1}' -f $u.First, $u.Last).ToLower()
    $upn = "$sam@$($cfg.Domain.Name)"
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name "$($u.First) $($u.Last)" `
            -GivenName $u.First -Surname $u.Last `
            -SamAccountName $sam -UserPrincipalName $upn `
            -Title $u.Title -Department $u.OU `
            -Path "OU=$($u.OU),$base" `
            -AccountPassword $securePwd `
            -ChangePasswordAtLogon $true -Enabled $true
        Add-ADGroupMember -Identity $u.OU -Members $sam
        Write-Host "  + User created: $sam ($($u.Title)) -> $($u.OU)" -ForegroundColor Green
    }
}

Write-Host "OU + user provisioning complete." -ForegroundColor Cyan
