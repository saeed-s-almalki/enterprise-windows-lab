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
    OrganizationalUnits = @('IT-Infrastructure', 'Applications', 'Servers', 'Workstations')

    # Departments that get a security group + file share
    DepartmentGroups = @('IT-Infrastructure', 'Applications')

    # Team members: Name = the OU / department they belong to
    Users = @(
        # ── IT-Infrastructure team ──
        @{ First = 'Saeed';    Last = 'Almalki'; OU = 'IT-Infrastructure'; Title = 'IT Infrastructure Manager' }
        @{ First = 'Mohammed'; Last = '';        OU = 'IT-Infrastructure'; Title = 'Infrastructure Engineer' }
        @{ First = 'Sami';     Last = '';        OU = 'IT-Infrastructure'; Title = 'Infrastructure Engineer' }
        @{ First = 'Noor';     Last = '';        OU = 'IT-Infrastructure'; Title = 'Infrastructure Engineer' }
        @{ First = 'Muhannad'; Last = '';        OU = 'IT-Infrastructure'; Title = 'Infrastructure Engineer' }
        # ── Applications team ──
        @{ First = 'Suha';     Last = '';        OU = 'Applications';      Title = 'Applications Engineer' }
        @{ First = 'Abdullah'; Last = '';        OU = 'Applications';      Title = 'Applications Engineer' }
    )

    # File-server shares:  Name = ACL group that gets Modify
    Shares = @(
        @{ Name = 'Infra-Share'; Path = 'C:\Shares\Infrastructure'; Group = 'IT-Infrastructure' }
        @{ Name = 'Apps-Share';  Path = 'C:\Shares\Applications';    Group = 'Applications' }
    )

    # Default password for demo accounts (lab only — change/rotate in prod)
    DefaultUserPassword = 'P@ssw0rd-Lab-2026!'
}
