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
  - Create new host only network in Virtual Network Editor (VMnet2)
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
    
  ### 5. Setup Client VM
  - setup network adapter to use VMnet 2 from earlier (to get ip from my DHCP server)
  - choose Domain join under sign-in options or manually renew ipconfig post install
    <img width="693" height="374" alt="Windows 11 x64-2026-10-07-15-08-36" src="https://github.com/user-attachments/assets/17113857-3841-4f18-a465-86cdb2a4ce1b" />
  - check IP address is in correct pool
  - join the domain via PowerShell cmd
  ```powershell
  Add-Computer -DomainName lab.internal -NewName PC01 -Credential LAB\Administrator -Restart
  ```
  - check if I can sign in to LAB\Administrator from client VM
  <img width="1247" height="1169" alt="Windows 11 x64-2026-10-07-15-33-36" src="https://github.com/user-attachments/assets/4493cd70-9f39-43ab-9094-60de8c6be500" />

  ### 6. Organizational Unit "Staff" Setup
  - Open Server Manager -> Tools -> AD Users and Computers
  - Right Click lab.internal -> New/OU -> "Staff"
  - Open "Staff" -> New/Group -> set to global security group
  - repeat process for IT, HR and Sales

  ### 7. Create Users in bulk
  - Create .csv file with: FirstName,LastName,Department,Group and fill in example user data
  - create and run PowerShell script to loop through the csv and create new test users
  ```powershell
  Import-Module ActiveDirectory
  $ou  = "OU=Staff,DC=lab,DC=internal"
  $pw  = ConvertTo-SecureString "ChangeMe!2026" -AsPlainText -Force
  Import-Csv .\users.csv | ForEach-Object {
      $sam = ($_.FirstName.Substring(0,1) + $_.LastName).ToLower()
      if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'")) {
          New-ADUser -Name "$($_.FirstName) $($_.LastName)" -GivenName $_.FirstName -Surname $_.LastName `
              -SamAccountName $sam -UserPrincipalName "$sam@lab.internal" -Path $ou `
              -Department $_.Department -AccountPassword $pw -ChangePasswordAtLogon $true -Enabled $true
          Add-ADGroupMember -Identity $_.Group -Members $sam
          Write-Output "Created $sam"
      } else { Write-Output "$sam already exists, skipped" }
  }
  ```
  <img width="377" height="352" alt="Windows Server 2022-2026-10-07-15-57-38" src="https://github.com/user-attachments/assets/10517697-5577-4ef4-b21e-6312fa4c5a47" />

  ### 8. Shared Folder for Sales employees
  - create the sales folder itself and share it so that only sales group can access it
  ```powershell
  New-Item -Path C:\Shares\Sales -ItemType Directory
  New-SmbShare -Name "Sales" -Path "C:\Shares\Sales" -ChangeAccess "LAB\Sales" -FullAccess "LAB\Domain Admins"
  ```
  - set NTFS folder permissions
  ```powerhsell
  icacls C:\Shares\Sales /inheritance:r
  icacls C:\Shares\Sales /grant "LAB\Sales:(OI)(CI)M" "LAB\Domain Admins:(OI)(CI)F" "BUILTIN\Administrators:(OI)(CI)F" "SYSTEM:(OI)(CI)F"
  ```
  - first cmd removes the inherited permissions, so people who aren't named can't get in through the default permissions. The second cmd grants Modify to Sales and Full control to the admins. (OI)(CI) makes the permissions apply to everything inside the folder, too.
  - final access is determined by stricter of the two(Share & NTFS permissions)
    
  <img width="1025" height="632" alt="Windows Server 2022-2026-10-07-16-13-41" src="https://github.com/user-attachments/assets/7c4652df-2a4d-469f-b78d-dc093ad93af3" />
  - check the permissions from DC01
  <img width="1247" height="1169" alt="image" src="https://github.com/user-attachments/assets/634b596a-8377-4b51-bd36-5d97f444bdeb" />
  - testing whether a sales user can see the shared folder \\DC01\Sales and create docs
  <img width="1247" height="1169" alt="image" src="https://github.com/user-attachments/assets/0a583982-41ea-4375-bdfc-64e88ac7ebbb" />
  - testing with it user, access denied as wanted

  ### 9. Adding Group Policies
  - Password policy (domain level - at least 12 characters)
  - DC01 -> Server Manager -> Tools -> Group Policy Management
  - Forest: lab.internal -> Domains -> lab.internal -> Default Domain Policy -> Right Click -> Edit
  - In Group Policy Management Editor window that opens -> Computer Configuration -> Policies -> Windows Settings -> Security Settings -> Account Policies -> Password Policies -> set Minimum pw length to 12
    
  - Mapping Sales share as a drive
  - in GPM right click Staff OU -> Create a GPO in this domain, and Link it here -> Name: Map Sales Drive
  - Right Click "Map Sales Drive" and edit
  - in GPME User Configuration -> Preferences -> Windows Settings -> Drive Maps -> Right Click/New Mapped Drive
  - Set Action to Create, location to \\DC01\Sales, check "reconnect" and select a drive letter, "S:" in this case
  - Common Tab -> check "item-level targeting"
  - Open Targeting -> New Item -> Security Group -> Select "LAB\Sales" with "User in group" checked
  <img width="959" height="1169" alt="image" src="https://github.com/user-attachments/assets/e54b022b-f66e-4053-af8d-b070dee1f727" />
  - S: not visible on IT group user
  <img width="959" height="1169" alt="image" src="https://github.com/user-attachments/assets/ddbfd4bd-5c75-4516-a951-fdde9f5f922d" />
  - S: is visible as a Sales group user

  - Restricting Control Panel access, except for IT users
  - DC01 -> Server Manager -> Tools -> Group Policy Management
  - Staff -> "Create a GPO in this domain and link it here" -> Name: "Restrict Control Panel"
  - Edit "Restrict Control Panel" -> User Configuration -> Policies -> Administrative Policies -> Control Panel -> Enable "Prohibit access to Control Panel and PC Settings"
  - In GPM Window open "Restrict Control Panel" -> Delegation tab -> Advanced -> Add "IT" and validate group -> check "deny" on apply group policy
  <img width="959" height="1169" alt="image" src="https://github.com/user-attachments/assets/25e3239b-267d-46b1-9e71-79a155ed9e54" />
  - View non IT users see when trying to open Control Panel


  ### 10. Set up Backup
  - Shut Down DC01 -> Edit virtual machines settings -> Add a new harddrive
  - Open dskmgmt.msc -> Initialize new disk as GPT -> right click unallocated space and create new volume -> select NTFS, letter "E" and label as "Backup"
  - Create dummy data (test.txt) on Sales Share using Sales user
  - Install Windows Server Backup on DC01 using PowerShell
  ```powershell
  Install-WindowsFeature Windows-Server-Backup
  ```
  - Server Manager -> Tools -> Windows Server Backup -> Local Backup -> Backup Once -> Select Different Options -> Custom -> Add the Folder you want to backup (Sales) -> Local drives -> Select E: and backup
  <img width="837" height="687" alt="Windows Server 2022-2026-10-08-11-05-45" src="https://github.com/user-attachments/assets/ee04db36-0502-4e14-9ad9-fc1e91ab0d7e" />
  - confirmation of backup completion

  ### 11. Testing the Backup
  - Delete test.txt from Sales folder
  <img width="967" height="786" alt="Windows Server 2022-2026-10-08-11-21-31" src="https://github.com/user-attachments/assets/e81f02b9-a7eb-4f76-aff2-45b4a3b77f00" />
  - in Windows Server Backup select "Restore" -> This Server -> Select the backup time you want to use (in this case it auto choose since there's just one) -> Files and Folders -> Select the file you want to restore -> original location 
  <img width="837" height="687" alt="Windows Server 2022-2026-10-08-11-05-45" src="https://github.com/user-attachments/assets/6128b8c8-dd30-4051-8957-fadeb0361a73" />
  - restore confirmation (restore took roughly 10 seconds)
  <img width="778" height="630" alt="Windows 11 x64-2026-10-08-11-19-20" src="https://github.com/user-attachments/assets/14a58b84-bc3e-469e-8a57-0df69f52932a" />
  
  - file has been restored
  <img width="560" height="177" alt="Windows Server 2022-2026-10-08-11-23-29" src="https://github.com/user-attachments/assets/96326282-3200-42fb-ac5b-b959d15b0946" />
  
  - making sure file permissions where also correctly restored (correct since HR and IT don't have access)






  




    

## What went wrong and how I fixed it
- Error: "Windows cannot find the Microsoft Software License Terms. Make sure the installation sources are valid and restart the installation."
    - Windows Server Evaluation ISO doesn't seem to be compatible with easy install, so I used custom setup and installed it later manually using the virtual DVD drive
 
- Created the client VM without the server running so i couldn't add it to the domain in the installer and had to do it once booted into fresh install
- Used commands
```cmd
ipconfig /release
ipconfig /renew
ipconfig /all
```

- Mapped Sales drive didn't show up at first
- unchecked the item-level targeting option and added it again using the browse button to pick "LAB\Sales" and confirm it using check names (SID visible now which wasn't before)


