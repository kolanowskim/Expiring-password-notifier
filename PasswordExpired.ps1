Import-Module ActiveDirectory

#Retrieving a list of users with an enabled account and a non-expiring password. Plus properties
$users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} `
-properties Name, msDS-UserPasswordExpiryTimeComputed, EmailAddress, LastLogonDate

#Credentials of sending account
$username = Get-Content C:\Skrypty\PasswordExpired\Credentials\store\encryptedUsername.txt | ConvertTo-SecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($username)
$username = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$Password = Get-Content C:\Skrypty\PasswordExpired\Credentials\store\encryptedPassword.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username, $Password)


#Data for sending emails
$emailFrom = New-Object System.Net.Mail.MailAddress("some@email.com", "Password Expiration Notifier"); #"
$emailTo #Przypisanie wenątrz kodu
$testEmail = "some@email.com"
$subject = "Reset your VPN password"


#SMTP data
$smtpServer = "some.smtp.com"; 
$smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, 587);
$smtp.EnableSsl = $true;
$smtp.Credentials = $credential


#Validation data
$expireindays = 5 #Od 5 dni powiadomienie będzie codziennie do dnia 0
$date = Get-Date -format "dd/MM/yyyy HH:mm"
$testing = "Disabled" #Disabled -> wysyłka do mail usera, Enabled -> wysyłka na testEmail


#Logs
$logging = "Enabled" #Enabled -> Włączenie zapisywania logów
$logFileSent = "C:\Skrypty\PasswordExpired\Logs\mylogSent.csv" #Lokalizacja logów jeśli wiadomość została wysłana
$logFileNosent = "C:\Skrypty\PasswordExpired\Logs\mylogNosent.csv" #Lokalizacja logów jeśli wiadomość NIE została wysłana
$logFileWithoutEmail = "C:\Skrypty\PasswordExpired\Logs\mylogwithoutEmail.csv" #Lokalizacja logów jeśli konto nie ma maila

#Checking if logging is enabled
if (($logging) -eq "Enabled")
{
    #Test the path of logs
    $logFilePathSent = (Test-Path $logFileSent)
    if (($logFilePathSent) -ne "True")
    {
        #Create CSV file and headers
        New-Item $logFileSent -ItemType File
        Add-Content $logFileSent "Date, Name, Email, DaystoExpire, Sent"
    }


    #Test the path of logs
    $logFilePathNosent = (Test-Path $logFileNosent)
    if (($logFilePathNosent) -ne "True")
    {
        #Create CSV file and headers
        New-Item $logFileNosent -ItemType File
        Add-Content $logFileNosent "Date, Name, Email, DaystoExpire, Sent"
    }


    #Test the path of logs without emails
    $logFilePathWithoutEmail = (Test-Path $logFileWithoutEmail)
    if (($logFilePathWithoutEmail) -ne "True")
    {
        #Create CSV file and headers
        New-Item $logFileWithoutEmail -ItemType File
        Add-Content $logFileWithoutEmail "Date, Name, DaystoExpire"

    }
}


#Loop for each user
foreach($user in $users)
{   
    #User data
    $name = $user.Name
    $emailTo = $user.EmailAddress
    $lastlogon = $user.LastLogonDate
    $today = (get-date)
    $PasswordExpiryDate = $user | Select-Object @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} `
    | select -ExpandProperty ExpiryDate
    $daysToExpire = (New-TimeSpan -Start $today -End $PasswordExpiryDate).Days
    $expirationMessage = ""
    

    if($lastlogon -ne $null){
  

            #Set notification according to time to password expired
            if($daysToExpire -eq 14){
            $expirationMessage = "Your password will expire in 14 days."
            }
            if($daysToExpire -eq 7){
            $expirationMessage = "Your password will expire in 7 days."
            }
            elseif(($daysToExpire -gt 0) -and ($daysToExpire -le $expireindays))
            {
            $expirationMessage = "Your password will expire in" + " $daysToExpire" + " days."
            }elseif($daysToExpire -eq 0)
            {
            $expirationMessage = "Your password will expire today."
            }
     }


    #If the message isn't empty and user has an email, go to message sending 
    if(($expirationMessage -ne "") -and ($emailTo -ne $null)){

              #If testing is enabled - set email as testEmail 
                if ($testing -eq "Enabled")
                  {
                   $emailTo = $testEmail
                  }


            #Create message content
            $body = @"
            Hello $name,
            <br>
            <p>$expirationMessage<br>
            To reset your password please, follow the instructions below.</p><br/>
            <ol><br/>
              <li>If you are working from office, you don’t need any preparations- go to p.3</li><br/>
              <li>If you are working remotely from home, connect to your standard VPN as always:<br/>
              <ul><br/>
              <li>FortiCLient --> Open FortiClient Console and then connect to VPN config.</li><br/>
              <li>Check twice correct connection in FortiClient.</li><br/>
              </ul><br/>
              </li><br/>
             <li>Reset your computer password.<br/>
                <ul><br/>
                <br><br/>
                 <li>For MacOS: Apple menu -> system preferences -> users and groups -> change password.</li><br/>
                 <ul><li> KB Apple - https://support.apple.com/pl-pl/guide/mac-help/mchlp1550/mac</li></ul><br/>
                  <br><br/>
                 <li>For Windows: Select Start -> Settings -> Accounts -> Sign-in options -> Select Reset password.</li><br/>
                 <ul><li> KB Windows - https://support.microsoft.com/en-us/windows/change-or-reset-your-windows-password-8271d17c-9f9e-443f-835a-8318c8f68b9c</li></ul><br/>
                 </ul><br/>
                 </li><br/>
             <li>Restart your computer.</li><br/>
            </ol><br/>
            <p style='text-transform:uppercase;font-weight:bold;'>DO NOT REPLY TO THIS MESSAGE.<p>Emails sent to the sender's address are not read.<br><br/>
If you have a question or problem, register a request in the JIRA Service Desk</p></p><br/>
"@

            $message = New-Object System.Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body)
            $message.IsBodyHtml = $true


                #Try to send message
                try{ 

                        $smtp.Send($message)
        
                      #If logging is enabled, save sent log
                     if (($logging) -eq "Enabled")
                        {
                           $sent = "YES"
                           Add-Content $logFileSent "$date, $name, $emailTo, $daysToExpire, $sent"
                        }
                }
                catch{
                     #If logging is enabled, save no-sent log with error message
                     if (($logging) -eq "Enabled")
                        {
                           $sent = "NO"
                           Add-Content $logFileNosent "$date, $name, $emailTo, $daysToExpire, $_";
                           $_ | Out-File C:\Skrypty\PasswordExpired\Logs\errorlog.txt
                        }
                     }
            }
            elseif((($daysToExpire -le 0) -or ($daysToExpire -le $expireindays)) -and ($emailTo -eq $null))
            {
                #If logging is enabled, save log of user without email
                 if (($logging) -eq "Enabled")
                 {
                      Add-Content $logFileWithoutEmail "$date, $name, $daysToExpire"
                 }
            }

}
