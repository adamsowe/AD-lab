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
- Open Power Apps portal and create new blank canvas app
- add data source: add data -> search for SharePoint connecter and enter my site's URL


## 2. Screen 1: submit form
- rename sceren 1 to "SubmitScreen"
- insert edit form and set data source to Suggestions list
- remove status and decision comment fields as user's won't need to enter these here
- insert -> button -> text: "Submit"
- set OnSelect to `SubmitForm(Form1)`
- Set Form1's OnSuccess to:
`
ResetForm(Form1);
Notify("Thanks, your idea was submitted", NotificationType.Success);
Navigate(MyIdeasScreen, ScreenTransition.None)
`

## 3. Screen 2: My Ideas
- Insert Vertical Gallery and set Items to:
`
Sort(
    Filter(Suggestions, 'Created By'.Email = User().Email),
    Created,
    SortOrder.Descending
)
`
- Remove the description label and add two new labels
- 1st label Text value: ThisItem.Status.Value
- 2nd label text value: ThisItem.'Decision comment'
- Insert new Button -> text: New Idea
- Set OnSelect to `Navigate(SubmitScreen)`

## 4. Test and Publish
<img width="1292" height="816" alt="image" src="https://github.com/user-attachments/assets/4e3b92ff-867a-41ee-9335-7aaf45aa5afb" />

- submit form

<img width="1311" height="801" alt="image" src="https://github.com/user-attachments/assets/f1091130-f086-4871-83f7-5c7b10dfda1c" />

- my ideas after a few test uploads

- <img width="1257" height="751" alt="image" src="https://github.com/user-attachments/assets/426c2b87-08d0-491b-9a14-172ea8ca6ce8" />

- new test rows got added to SharePoint list after submitting the form


# Part C: Power Automate

## 1. notifying IT
- 


# What went wrong and how i fixed it
- The Edit Form was showing as empty in the app preview, to fix it i set the default mode to "new" instead of "edit"

- Category was showing empty items as selections, I removed the dropdown and added it again then it worked

- Form wouldn't submit cause "Status" is required so I added a new field for status and i set the default value to `{value: "New"}` and hid the field

- 
