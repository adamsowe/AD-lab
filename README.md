Small company network in virtual machines (VMware Workstation).

## What's in it
- DC01: Windows Server (AD DS, DNS, DHCP)
- PC01: Windows 11 client joined to the domain
- Users and groups created via PowerShell from a CSV
- Group Policies and a permission-restricted share
- Backup with a tested restore

## Network
(diagram goes here)

## Requirements
- Host: Windows PC, VMware Workstation Pro, ~150 GB free disk
- Windows Server 2022 evaluation ISO (Microsoft Evaluation Center)
- Windows 11 Enterprise evaluation ISO

## Setup steps
  ### 1. Server VM setup
  - Create new host only network in Virtual Network Editor
  - Disable local DHCP (Use Windows DHCP later)
  - Setup Server VM, select Standard Installation with Desktop Environment (Don't use easy install)
  - Install VMWare Tools using Installation Media
    
  ### 2. Static IP and DNS
  - Setup new fixed IP address
  ```powershell
  New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.50.10 -PrefixLength 24
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 192.168.50.10
  ```
  - A domain controller needs a static address, and clients find the domain through DNS, so the server points DNS at itself.
  - rename server and restart (to prevent random install name to get baked into AD)

  ### 3. Install roles and create domain
  ```powershell
  Install-WindowsFeature AD-Domain-Services, DNS, DHCP -IncludeManagementTools
  
  ```
  - first command installs three server roles, which are just Windows features that aren't active by default
  - AD-Domain-Services is Active Directory itself, the database of users, groups and computers
  - DNS lets machines find each other by name, and Active Directory depends on it to work
  - DHCP hands out IP addresses to clients automatically
  - IncludeManagementTools adds the graphical tools, such as Active Directory Users and Computers
  ```powershell
  Install-ADDSForest -DomainName "lab.internal" -DomainNetbiosName "LAB" -InstallDns
  ```
  - The second command creates the domain
  - Install-ADDSForest builds a new Active Directory forest, which is the top-level container for a domain
  - DomainName "lab.internal" is the domain's name. Users will log in as user@lab.internal
  - DomainNetbiosName "LAB" is the short legacy name, used in LAB\username logins
  - InstallDns sets up DNS for the domain on this same server
    <img width="1066" height="1291" alt="Windows Server 2022-2026-10-06-19-10-26" src="https://github.com/user-attachments/assets/d522c4d0-169b-46fc-ba6c-131a9dc69820" />

  ### 4. Configure DHCP
  ```powershell
  Add-DhcpServerv4Scope -Name "Lab" -StartRange 192.168.50.100 -EndRange 192.168.50.200 -SubnetMask 255.255.255.0
  ```
  - Scope: this command sets the pool of addresses the server may hand out. Here it's .100 to .200 on my 192.168.50.x network. That leaves .1 to .99 free for fixed devices like servers.
  ```powershell
  Set-DhcpServerv4OptionValue -DnsServer 192.168.50.10 -DnsDomain "lab.internal"
  ```
  - Besides an address, a client needs to be told which DNS server to use and which domain it belongs to. This command sets both: DNS is my DC (192.168.50.10), and the domain suffix is lab.internal. The Windows 11 client has to find the DC through DNS to join the domain. If it gets the wrong DNS, the join fails.
  ```powershell
  Add-DhcpServerInDC -DnsName "DC01.lab.internal" -IPAddress 192.168.50.10
  ```
  - In an Active Directory network, a DHCP server won't hand out addresses until a domain administrator has authorized it in AD. This protects the network from someone plugging in a rogue DHCP server.

  - Check if everything is setup as expected
  <img width="1066" height="1291" alt="image" src="https://github.com/user-attachments/assets/0fa92430-3b6e-4ec7-b359-4a01af594f0a" />
  

  <img width="608" height="574" alt="Windows Server 2022-2026-10-06-19-25-07" src="https://github.com/user-attachments/assets/5e324215-1266-44a2-a4fc-0307fe452b18" />
  
  - DHCP console: Server Manager -> Tools -> DHCP:

  ### 5. Take Snapshot




    

## What went wrong and how I fixed it
- Error: "Windows cannot find the Microsoft Software License Terms. Make sure the installation sources are valid and restart the installation."
    - Windows Server Evaluation ISO doesn't seem to be compatible with easy install, so I used custom setup and installed it later manually using the virtual DVD drive


