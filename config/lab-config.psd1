@{
    # ── Enterprise Windows Lab — Central Configuration ───────────────
    # Edit this file only. Every script reads its values from here so the
    # whole environment stays consistent and reproducible.

    Domain = @{
        Name          = 'corp.lab'          # FQDN of the new forest
        NetbiosName   = 'CORP'
        FunctionLevel = 'WinThreshold'       # 2016+ forest/domain level
    }

    Network = @{
        DcStaticIP    = '10.10.10.10'
        PrefixLength  = 24
        Gateway       = '10.10.10.1'
        DnsForwarder  = '8.8.8.8'
    }

    Dhcp = @{
        ScopeName  = 'CORP-LAN'
        ScopeId    = '10.10.10.0'
        SubnetMask = '255.255.255.0'
        RangeStart = '10.10.10.100'
        RangeEnd   = '10.10.10.200'
        LeaseDays  = 8
    }

    # Organizational Units created under the domain root
    OrganizationalUnits = @('Infrastructure', 'Applications', 'Servers', 'Workstations')

    # Departments that get a security group + file share
    DepartmentGroups = @('Infrastructure', 'Applications')

    # Team members: Name = the OU / department they belong to
    Users = @(
        # ── Infrastructure team ──
        @{ First = 'Saeed';      Last = 'Almalki';    OU = 'Infrastructure'; Title = 'IT Infrastructure Manager' }
        @{ First = 'Abdulmalik'; Last = 'Alowaimer';  OU = 'Infrastructure'; Title = 'Infrastructure Engineer' }
        @{ First = 'Mohammed';   Last = 'Alkhayat';   OU = 'Infrastructure'; Title = 'Infrastructure Engineer' }
        @{ First = 'Nawaf';      Last = 'Alshahrani'; OU = 'Infrastructure'; Title = 'Infrastructure Engineer' }
        @{ First = 'Naif';       Last = 'Alshehri';   OU = 'Infrastructure'; Title = 'Infrastructure Engineer' }
        # ── Applications team ──
        @{ First = 'Mohammed';   Last = 'Aldossari';  OU = 'Applications';   Title = 'Applications Engineer' }
        @{ First = 'Deemah';     Last = 'Alqahtani';  OU = 'Applications';   Title = 'Applications Engineer' }
    )

    # File-server shares:  Name = ACL group that gets Modify
    Shares = @(
        @{ Name = 'Infra-Share'; Path = 'D:\Shares\Infrastructure'; Group = 'Infrastructure' }
        @{ Name = 'Apps-Share';  Path = 'D:\Shares\Applications';    Group = 'Applications' }
    )

    # Default password for demo accounts (lab only — change/rotate in prod)
    DefaultUserPassword = 'P@ssw0rd-Lab-2026!'
}
