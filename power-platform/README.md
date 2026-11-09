# Part 4: Power Platform – Improvement Ideas App

An internal app where employees submit improvement ideas and IT reviews them, built in my Microsoft 365 lab tenant with standard connectors only.

- **SharePoint list** stores the ideas (description, category, status, decision comment)
- **Power Apps canvas app** lets users submit ideas and see their own submissions with the current status
- **Power Automate** notifies IT about each new idea, then sends it through an approval and updates the status and the submitter
- **Governance:** the app is shared with a security group, and all data stays inside the tenant

**Tools:** SharePoint, Power Apps, Power Automate, Approvals, Outlook, Microsoft 365 admin center

[Part 1: Windows Server 2022 / Active Directory](/README.md)

[Part 2: Entra Microsoft 365 / Entra ID Lab](/entra/README.md)

[Part 3: Virtualization / Ansible](/virtualization/README.md)

# Part A: SharePoint List

## 1. Creating the site
- Open SharePoint admin center -> active sites -> add sites
- Pick standard template name the site -> select owners and members
- I'm Calling it "Improvements Ideas", making myself the owner and adding Users: IT Admin and Anna


## 2. Creating the list
- open the site url and select new list
- select name: Suggestions
- add my own columns
- require that all columsn contain information and select "new" als default value on status
<img width="1250" height="375" alt="image" src="https://github.com/user-attachments/assets/7e1eb63f-9446-43a9-9aec-8b24d1edf466" />

- new columns in full effect

## 3. Adding a test item
- Select New and fill in some test data

<img width="1251" height="703" alt="image" src="https://github.com/user-attachments/assets/d7bbf11f-0be2-44e0-8b43-60190a81c832" />

# Part B: Power Apps Canvas App

## 1. Creating the app
- 

