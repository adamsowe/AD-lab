# Part 2: Microsoft 365 / Entra ID Lab

Cloud identity and user management in a Microsoft 365 Business Premium trial tenant.
This is the cloud counterpart to the on-prem Active Directory lab in Part 1.

[Part 1: Windows Server 2022 / Active Directory](/README.md)

## Environment
- Microsoft 365 Business Premium (trial tenant)
- Tenant name: adamlab444.onmicrosoft.com
- Portals used: Microsoft 365 admin center, Entra admin center

## 1. Tenant setup

I signed up for a Microsoft 365 Business Premium trial using adam.sowemimo@gmail.com. This created a tenant with the domain `adamlab444.onmicrosoft.com` and made my account the Global Administrator.

Before changing anything I looked around the environment:
- **Microsoft 365 admin center** (admin.microsoft.com): users, licences and billing. The trial includes 25 Business Premium licences.
- **Entra admin center** (entra.microsoft.com): groups, sign-in logs and security settings.

Both portals manage the same tenant. A user created in one shows up in the other, so I used each for the tasks it exposes best (users and licences in the 365 admin center, groups, MFA and logs in Entra).

<img width="1153" height="682" alt="Screenshot 2026-10-13 195911" src="https://github.com/user-attachments/assets/cb46dee1-af7a-450a-98fe-3ff1400769f5" />
- License Overview

<img width="1557" height="726" alt="Screenshot 2026-10-13 200034" src="https://github.com/user-attachments/assets/084894cc-f38d-4bcf-96fd-89d236214549" />
- Users

## 2. Admin accounts and least privilege
- Goal: do daily work with an account that can manage users but cannot change everything, and keep the full-power account for emergencies.

- Users → Active users -> Add a user
- I'm calling this user "IT Admin", username will be "itadmin"
- Select "Require this user to change their password"
- I'm not giving the user any licenses just yet, so "Create user without product license"
- Under Optional Settings select "Admin Center Access" -> Helpdesk Administrator and User Administrator
- Create Account
- Rename global admin account to "Emergency Admin"
- Switch to IT Admin

<img width="710" height="1317" alt="image" src="https://github.com/user-attachments/assets/583d7a4d-8019-4744-a42a-6152ae00eb89" />



