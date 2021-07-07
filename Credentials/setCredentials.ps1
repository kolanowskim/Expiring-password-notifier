$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content C:\Skrypty\PasswordExpired\Credentials\store\encryptedPassword.txt
$credential.Username | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Set-Content C:\Skrypty\PasswordExpired\Credentials\store\encryptedUsername.txt