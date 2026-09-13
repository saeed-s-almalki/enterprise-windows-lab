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
    OrganizationalUnits = @('IT', 'HR', 'Finance', 'Servers', 'Workstations')

    # Demo users: Name = the OU they belong to
    Users = @(
        @{ First = 'Sara';  Last = 'Admin';   OU = 'IT';      Title = 'Systems Engineer' }
        @{ First = 'Omar';  Last = 'Hassan';  OU = 'HR';      Title = 'HR Specialist' }
        @{ First = 'Layla'; Last = 'Nasser';  OU = 'Finance'; Title = 'Accountant' }
        @{ First = 'Faisal';Last = 'Otaibi';  OU = 'IT';      Title = 'Help Desk' }
    )

    # File-server shares:  Name = ACL group that gets Modify
    Shares = @(
        @{ Name = 'IT-Share';      Path = 'D:\Shares\IT';      Group = 'IT' }
        @{ Name = 'HR-Share';      Path = 'D:\Shares\HR';      Group = 'HR' }
        @{ Name = 'Finance-Share'; Path = 'D:\Shares\Finance'; Group = 'Finance' }
    )

    # Default password for demo accounts (lab only — change/rotate in prod)
    DefaultUserPassword = 'P@ssw0rd-Lab-2026!'
}
