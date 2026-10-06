# AD Lab: Windows Server + Active Directory

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
  - 

## What went wrong and how I fixed it
- Windows Server Evuluation ISO doesn't seem to be compatible with easy install, so I used custom setup and installed it later manually using the virtual DVD drive


