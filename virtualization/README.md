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
- reboot
- run "ip a" to get network details

<img width="1036" height="435" alt="image" src="https://github.com/user-attachments/assets/951776bd-46a9-4ab4-83e7-51d610ba3561" />

- VM 1 (alma-ctl) Network details

- repeat same steps for second VM called "alma-web"

<img width="947" height="407" alt="image" src="https://github.com/user-attachments/assets/26edbddc-1a8e-475e-960a-52e480f78642" />

- VM 2 (alma-web) Network details


## 4. Checkpoints, break and restore
- stop alma-web, right-click and select checkpoint, then rename it to "clean install"
- stopping NetworkManager with "sudo systemctl stop NetworkManager"

<img width="1277" height="440" alt="image" src="https://github.com/user-attachments/assets/c66a4d55-e6e1-42ec-8665-2192b410550e" />

- NetworkManager status: inactive

- in Hyper-V select the checkpoint and select apply

<img width="1276" height="452" alt="image" src="https://github.com/user-attachments/assets/e5af691d-9a1c-47ae-bde6-a1e746e9f4cb" />

- NetworkManager is active again, post checkpoint apply

## 5. Export and import as a backup
- shutdown alma-web, right-click and select "export", i'll save it in "D:\alma-export"
- delete the VM in Hyper-V
- select "import vm" in Hyper-V, then navigate to the "Virtual Machines" subfolder of the export folder
- select Reregister VM
- check if VM works as expected

<img width="856" height="350" alt="image" src="https://github.com/user-attachments/assets/7e9c80ad-87f5-4255-afda-99cd3d25c7d2" />

- alma-web export folder

## 6. SSH key setup
- on alma-ctl generate key using "ssh-keygen -t ed25519
- I'm using the default settings and not using a passphrase since it's a home lab
- using ed25519 instead of rsa since it's the current standard and AlmaLinux supports it

<img width="832" height="580" alt="image" src="https://github.com/user-attachments/assets/5dcc39c4-83bf-499e-a3d0-d54bdd1b2c1e" />

- ssh keygen overview

- now i'm going to send the public key to both VMs using:
```bash
ssh-copy-id admin@172.19.151.168
ssh-copy-id admin@172.19.144.142
```
- i'm copying it to alma-ctl as well since it will be the control node and ansible controls it over ssh as well

<img width="1042" height="392" alt="image" src="https://github.com/user-attachments/assets/a5427c69-b0b4-4706-9555-829a1243ceac" />

- successfull ssh connection to alma-web from alma-ctl

## 7. Ansible install
- running the following commands to install ansible and check it installed correctly
```bash
sudo dnf install -y ansible-core
ansible-galaxy collection install ansible.posix
ansible --version
```
- The ansible.posix collection is needed for the firewalld and SELinux modules I'll be using

<img width="1182" height="352" alt="image" src="https://github.com/user-attachments/assets/1542baf6-5811-4b84-9397-6cbfbed349c5" />

- install worked, version 2.16.16

## 8. Inventory and connection test
[Inventory.ini](inventory.ini)
- inventory means list of machines ansible manages
- create folder ansible-lab and create a inventory.ini in it
```bash
mkdir ~/ansible-lab && cd ~/ansible-lab
touch inventory.ini
```
- install nano
```bash
sudo dnf install nano
```
- edit inventory.ini
```bash
nano inventory.ini
```
- add the following to the ini file
```ini
[servers]
alma-ctl ansible_host=172.19.151.168
alma-web ansible_host=172.19.144.142

[all:vars]
ansible_user=admin
```
- check if the connection works

<img width="735" height="332" alt="image" src="https://github.com/user-attachments/assets/1621ba08-75e5-445d-927e-f0910aec60e9" />

- success

## 9. Writing and testing the Playbook
**Goal:** One file that patches both servers and applies the same security settings, so I don't have to do it by hand on each machine.
 
- I created `harden.yml` on `alma-ctl` with `nano` and saved a copy in this repo: [harden.yml](harden.yml). It runs on every host in the `[servers]` group of my inventory and uses `become: true` so the tasks run with `sudo`.
 
| Task | What it does | Why |
|---|---|---|
| Update all packages | `dnf` with `state: latest` | Installs security patches |
| Install basic tools | `firewalld`, `policycoreutils`, `chrony` | Makes sure the tools I need exist |
| Start and enable firewalld | `service` module | Firewall runs now and after every reboot |
| Allow SSH through the firewall | `ansible.posix.firewalld` | Keeps remote access working |
| Keep SELinux enforcing | `ansible.posix.selinux` | Blocks unauthorized actions |
| Disable SSH password login | `lineinfile` on `sshd_config` | Only key login is possible |
| Disable SSH root login | `lineinfile` on `sshd_config` | No direct root access |
| Enable time sync | `chronyd` | Correct time for logs |
 
- A handler restarts `sshd` once, and only if the SSH settings were changed.

- I checked the validity of the syntax using the following command
```bash
ansible-playbook -i inventory.ini harden.yml --syntax-check
```





## What went wrong and how I fixed it
- renamed both VMs since Hyper-V default named them to localhost
``` bash
sudo hostnamectl set-hostname alma-ctl
sudo hostnamectl set-hostname alma-web
```

