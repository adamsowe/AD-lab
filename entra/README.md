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
- "IT Admin" roles


## 3. Create users in bulk from a CSV
- Users -> Active Users -> Add multiple users -> Select "I'd like to upload a csv with user information"
- Download a blank CSV file with the required headers and modify the data accordingly
- Upload your csv and create the users, select no license since I'll be adding that via groups
- Download the file with user information it generated so I don't have to remember temp passwords
<img width="1207" height="887" alt="image" src="https://github.com/user-attachments/assets/d355d8ff-719e-4546-8808-00986c036df0" />
- Successfully created the new users

## 4. Security groups 
- Entra Admin Center -> Groups -> All Groups -> New Group
- Group Type should be "Security"
- Group Name "IT"
- Add member -> search for "Lukas Huber"
- Create Group
- Repeat the same process for Sales and HR 
<img width="1627" height="872" alt="image" src="https://github.com/user-attachments/assets/6b1debd6-e89a-48bf-b953-6aee1ae7a6de" />
- newly created groups

- dynamic group
- New group -> Set name to "Sales-Dynamic"
- Set "Membership type" to "Dynamic User"
- Select "add dynamic query"
- Edit the Rule Syntax to 'user.department -eq "Sales"'
- Save and create the group
<img width="1380" height="402" alt="image" src="https://github.com/user-attachments/assets/e5067d32-4d5f-4ba9-bdea-c1300aada9d4" />
- dynamic grouop
<img width="1317" height="952" alt="image" src="https://github.com/user-attachments/assets/7355d651-f7f6-4e45-a1cb-5f859461e3dd" />
- members of dynamic group

## 5. Group-based licensing
- admin.microsoft.com -> Billing -> Licenses -> open "Microsoft 365 Business Premium"
- Assign licenses -> Add Sales, IT and HR and click assign
<img width="1577" height="1022" alt="image" src="https://github.com/user-attachments/assets/29e3cc4c-c73c-4565-8755-a040967d635a" />

- newly assigned groups
<img width="1508" height="518" alt="image" src="https://github.com/user-attachments/assets/a8bc29d1-b078-4b8f-b53b-059274e5438e" />
<img width="910" height="480" alt="image" src="https://github.com/user-attachments/assets/1c85427b-79b6-451b-844d-22c6677ff09a" />

- licenses successfully got assigned to specific users of the groups

## 6. MFA with security defaults and a test sign-in
- Entra Admin Center -> Switch to global admin since IT Admin can't see the required settings
- Show all -> Identity -> opens new tab -> sign in -> Overview -> properties -> manage security defaults -> make sure it's set to "enabled"
- In Incognito tab log in with test user, in this case anna.berger
- check if user gets promped to setup mfa and reset password
<img width="612" height="630" alt="image" src="https://github.com/user-attachments/assets/fd883350-d2c8-4366-9ea2-610ac9b27d1b" />

- password reset prompt
<img width="615" height="645" alt="image" src="https://github.com/user-attachments/assets/3fe799c9-fca6-48dd-b0c2-1de507cd9af4" />

- working mfa prompt

## 7. Checking sign-in logs
- Entra Admin Center -> Monitoring & health -> sign-in logs
- Find intended log and check basic info
<img width="1032" height="1326" alt="Screenshot 2026-10-14 195203" src="https://github.com/user-attachments/assets/7c9adda8-7fab-4279-ab30-d5dbf1340345" />

- successful log with mfa enabled

## 8. Disabling Security Defaults
- Entra Admin Center -> Entra ID -> Overview -> Properties -> manage security defaults -> disable
<img width="431" height="396" alt="image" src="https://github.com/user-attachments/assets/6896ac9a-a413-4ef9-8a52-11154c181d04" />

## 9. report-only MFA policy for Sales
- Entra ID -> Conditional Access -> Create New Policy
- Name -> "Require MFA - Sales (report-only)"
- Users -> include -> Select users and groups -> search for "Sales"
- exclude -> Select Users and groups -> my two admin accounts
- Target resources -> All resources (formerly "All cloud apps")
- Grant -> Grant access -> require multifactor auth
- Enable policy -> "report only" -> Create
<img width="729" height="568" alt="image" src="https://github.com/user-attachments/assets/fe599270-61f8-4eb5-9834-729259ff5f6f" />

- The new policy post creation

## 10. testing conditional access
- I'm goingn to test the policy with Anna account
- Entra Admin Center -> Monitoring & health -> Sign-in logs -> newest log-in entry with anna -> report only
<img width="748" height="898" alt="image" src="https://github.com/user-attachments/assets/7f9c4166-1480-4268-ad1d-e4f6db4f3bb6" />

- screenshot of the report only tab on the latest entry
- Conditional Access -> Policies -> select my policy -> View or Edit -> Set enable policy to "on"
<img width="439" height="530" alt="image" src="https://github.com/user-attachments/assets/97912872-cac2-4f94-89ac-796146bacf66" />
- <img width="841" height="336" alt="image" src="https://github.com/user-attachments/assets/9ed79f0d-2e7d-4f4f-ae57-1fa7874fa365" />

- Anna now gets prompted for MFA

## 11. Blocking legacy authentication
- Entra ID -> Conditional Access -> Create New Policy
- name -> "Block legacy authentication"
- Target resources -> all resources
- Conditions -> Client apps -> set configure to yes
- only select "exchange ActiveSync clients" and "other clients"
- Grant -> Block access
- Enable policy -> "report only" -> create
<img width="834" height="308" alt="image" src="https://github.com/user-attachments/assets/313066fc-9590-4d8b-a179-fe4650e60dce" />

## 12. Shared Mailbox
- admin.exchange.microsoft.com -> Recipients -> Mailboxes -> add a shared mailbox
- Name: "Sales Shared" -> select domain and set email
- Open the mailbox -> Delegation -> Add "Anna" to "Send as" and "Read and manage"
<img width="584" height="418" alt="image" src="https://github.com/user-attachments/assets/a6f5f732-efcd-4126-88ac-c3d7ccd92332" />
<img width="579" height="410" alt="image" src="https://github.com/user-attachments/assets/0ab19b70-0b14-49ef-a9a3-6df48817f01c" />

- delegation pages

## 13. Distribution list
- Exchange Admin Center -> Recipients -> Groups -> Add a group -> Type: Distribution
- Set Name to "All staff" -> set myself as owner and add all the user accounts i generated from csv as members
- Set email to allstaff@mydomain and set the group to closed
<img width="577" height="725" alt="image" src="https://github.com/user-attachments/assets/e1d64abd-51ea-4b54-92fc-67dff67f938d" />

- Distribution list members page

## 14. SharePoint with group permissions
- SharePoint admin center -> Sites -> Active Sites -> Create -> Team Site (Standard Template)
- Name: "Sales" -> Setting myself as owner
- Open Site -> Membership -> Site members -> add Sales security group
<img width="867" height="798" alt="image" src="https://github.com/user-attachments/assets/fbaab280-e3e7-4a66-abf4-4c774c03d756" />

- trying to access with non sales account
<img width="1252" height="1073" alt="image" src="https://github.com/user-attachments/assets/a5bdcd0e-5203-4067-8458-766bd104e1fc" />

- access works with sales member account













