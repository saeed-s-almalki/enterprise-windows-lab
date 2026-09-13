# Deployment Guide

A step-by-step walkthrough for building the lab on Hyper-V.

## 1. Prepare the VM
- Create a Hyper-V VM: 2 vCPU, 4 GB RAM, 60 GB disk, an **Internal** or
  **Private** virtual switch.
- Install Windows Server 2019/2022 (Desktop Experience is easiest for a lab).
- Add a second data disk (e.g. `D:`) for the file shares, or edit
  `config/lab-config.psd1` to point shares at `C:`.

## 2. Get the code onto the server
```powershell
git clone https://github.com/saeed-s-almalki/enterprise-windows-lab.git
cd enterprise-windows-lab
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

## 3. Configure
Open `config/lab-config.psd1` and set the domain name, IP range, OUs, users and
shares you want. This is the only file you edit.

## 4. Deploy (two stages)
```powershell
.\Deploy-Lab.ps1     # Stage 1: DC promotion -> server reboots
# ...log back in...
.\Deploy-Lab.ps1     # Stage 2: DHCP, OUs, users, GPOs, shares
```

## 5. Validate
```powershell
.\scripts\Test-Lab.ps1
```
Screenshot the green checklist for your documentation / portfolio.

## 6. Add a client (optional)
On a second VM (Windows 10/11 or Server):
```powershell
.\scripts\06-Join-Domain.ps1
```

## Troubleshooting
| Symptom | Fix |
|---------|-----|
| `Install-ADDSForest` fails on DNS | Ensure the adapter DNS points to `127.0.0.1` (script 01 does this) |
| DHCP not handing out leases | Confirm it's authorized: `Get-DhcpServerInDC` |
| Client can't find domain | Client DNS must point at the DC's static IP |
| Re-running created nothing | Expected — scripts are idempotent |

## Teardown
Delete the VM checkpoint or the VMs. Nothing is installed on the host.
