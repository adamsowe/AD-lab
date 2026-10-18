# Part 3: Virtualization Lab

Hyper-V lab with two AlmaLinux servers, managed and hardened with Ansible.

[Part 1: Windows Server 2022 / Active Directory](/README.md)

[Part 2: Entra Microsoft 365 / Entra ID Lab](/entra/README.md)

## 1. Enabling Hyper-V
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
- restart
<img width="918" height="546" alt="image" src="https://github.com/user-attachments/assets/3fddd0d4-8642-452f-bb0c-a609f6a4cecc" />

- Hyper-V Manager

## 2. Virtual Switch
- in Hyper-V Manager select Computer name -> Virtual Switch Manager
- Check Default Switch (I'm going to use this for both vms, bare in mind IPs can change after system reboot)
<img width="714" height="676" alt="image" src="https://github.com/user-attachments/assets/0ac08de8-d3d3-4f3c-b86c-d39bb6e5ff47" />

## 3. Setting up the VMs
- Hyper-V Manager -> New -> Set name to "alma-ctl"
- ram 2GB
- Network Connection: Default Switch
- VHD: 20GB
- Select AlmaLinux iso as installation media 
- In order to boot -> settings -> security -> set Template to Microsoft UEFI Certificate Authority
- boot vm
- select where to install the os
- disable root account
- create user account and make it an admin account
