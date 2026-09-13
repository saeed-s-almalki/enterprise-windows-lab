# Create-LabVM.ps1 — Creates the enterprise-windows-lab Domain Controller VM on Hyper-V
# Requires: Administrator (Hyper-V cmdlets need elevation)

$ErrorActionPreference = 'Stop'

# --- Settings ---
$VMName    = 'EWL-DC01'
$ISOPath   = 'D:\OS\SERVER_EVAL_x64FRE_en-us.iso'
$SwitchName = 'Lab-Internal'
$RAMStartup = 4GB
$RAMMin     = 2GB
$RAMMax     = 8GB
$CPUCount   = 2
$DiskSize   = 60GB

Write-Host "=== enterprise-windows-lab :: VM provisioning ===" -ForegroundColor Cyan

# 0) Verify Hyper-V is available
if (-not (Get-Command New-VM -ErrorAction SilentlyContinue)) {
    throw "Hyper-V cmdlets not available. Enable Hyper-V feature first."
}

# 1) Verify ISO exists
if (-not (Test-Path $ISOPath)) { throw "ISO not found: $ISOPath" }
Write-Host "[OK] ISO found: $ISOPath" -ForegroundColor Green

# 2) Guard: VM name not already used
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    throw "A VM named '$VMName' already exists. Aborting to avoid clobbering it."
}

# 3) Ensure the internal switch exists
$sw = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
if (-not $sw) {
    New-VMSwitch -Name $SwitchName -SwitchType Internal | Out-Null
    Write-Host "[OK] Created internal switch: $SwitchName" -ForegroundColor Green
} else {
    Write-Host "[OK] Switch already exists: $SwitchName" -ForegroundColor Green
}

# 4) Determine VHD path (default VM disk location)
$vmHost  = Get-VMHost
$vhdDir  = $vmHost.VirtualHardDiskPath
$vhdPath = Join-Path $vhdDir "$VMName.vhdx"
if (Test-Path $vhdPath) { throw "VHD already exists at $vhdPath. Aborting." }

# 5) Create the VM (Gen 2, dynamic VHD)
New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $RAMStartup `
    -NewVHDPath $vhdPath -NewVHDSizeBytes $DiskSize -SwitchName $SwitchName | Out-Null
Write-Host "[OK] VM created: $VMName" -ForegroundColor Green

# 6) CPU + dynamic memory
Set-VMProcessor -VMName $VMName -Count $CPUCount
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes $RAMMin -MaximumBytes $RAMMax -StartupBytes $RAMStartup

# 7) Attach install ISO
Add-VMDvdDrive -VMName $VMName -Path $ISOPath
$dvd = Get-VMDvdDrive -VMName $VMName

# 8) Boot from DVD first (Gen2 firmware)
Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd

# 9) Lab-friendly tweaks: disable automatic checkpoints (avoid noise during DC promo)
Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $false -CheckpointType Standard

# 10) Summary
Write-Host "`n=== DONE ===" -ForegroundColor Cyan
Get-VM -Name $VMName | Format-List Name, State, Generation, ProcessorCount, MemoryStartup, MemoryMinimum, MemoryMaximum
Get-VMDvdDrive -VMName $VMName | Format-List VMName, Path
Get-VMNetworkAdapter -VMName $VMName | Format-List Name, SwitchName
Write-Host "VHD: $vhdPath" -ForegroundColor Yellow
Write-Host "`nNext: Start-VM -Name $VMName  then connect via vmconnect to install Windows Server." -ForegroundColor Yellow
