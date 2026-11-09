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

# 1. 
