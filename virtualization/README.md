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
- 
