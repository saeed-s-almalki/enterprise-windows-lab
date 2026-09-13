# Screenshots — Deployment Evidence

Real deployment of the lab on a Hyper-V VM (`EWL-DC01`, Windows Server 2022 Standard, Desktop Experience).

## Setup

| # | File | Description | Status |
|---|------|-------------|--------|
| 00 | `00-vm-os-selection.jpg` | Windows Server 2022 (Desktop Experience) edition selection | ✅ Done |
| 01 | `01-installing.jpg` | OS installation in progress | ✅ Done |

## Post-deployment (the "golden" shots) — pending

| # | Planned file | What it proves |
|---|--------------|----------------|
| 02 | `02-deploy-running.png` | `Deploy-Lab.ps1` running with colored output |
| 03 | `03-test-lab-pass.png` | `Test-Lab.ps1` — all checks green (health checklist) |
| 04 | `04-ad-users-ous.png` | Active Directory Users & Computers — OU tree + users |
| 05 | `05-dhcp-scope.png` | DHCP console — active scope + leases |
| 06 | `06-gpo-management.png` | Group Policy Management — GPOs linked |
| 07 | `07-file-shares.png` | File shares — Infra-Share / Apps-Share + least-privilege ACLs |

> Capture these after `Deploy-Lab.ps1` completes on the VM, drop them here with the names above, and they auto-slot into the README/LinkedIn post.
