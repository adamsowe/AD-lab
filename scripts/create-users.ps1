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
