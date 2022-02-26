# Expiring password notifier
Script for Windows server to sending email notifications to users about their Active Directory password that going to be expired in several days.

## General Information
- We couldn't use default Windows solution on computers with macOS system. So i decided to make powershell script.
- Script sends emails, so you need to have some mailbox and SMTP server.
- Script has been written in Powershell

## Setup
1. Script and all stuff must be embedded into C:\Skrypty\PasswordExpired or you can change paths inside script

2. Firstly you need to set up mail-sending credentials. You can to this by:
	- Go into "credentials" directory and run setCredentials.ps1
	- This script will prompt you for email account credentials and then will save them encrypted inside "store" directory

3. Logs are saving inside "Logs" directory. Script saves 3 types of logs.
	Whom message was sent, Whom message wasn't sent and accounts without emails


4. Script PasswordExpired.ps1 is responsible for sending notifications.
5. You can embed this script into Task Scheduler inside Windows Server at your company domain in order to run script everyday at specific hour.

## Usage
### Inside PasswordExpired.ps1 you must provide SMTP data:
![image](https://user-images.githubusercontent.com/83921557/155861631-9ca0f266-1bc7-400e-948a-9245b654c828.png)

### Here you must provide email from which notifications will be sending
![image](https://user-images.githubusercontent.com/83921557/155861678-4b1709ce-727c-467d-9702-72cb6b623ac3.png)
- Also you can set Test Email at 18 line. Where all notifications will be sending.

### Testing mode
- If you want to test script and send all notifications to Test Email. You must set $testing to Enabled.
- Disabled - sending to users. Enabled - sending to $testEmail
![image](https://user-images.githubusercontent.com/83921557/155861739-3cd0dc2b-2a80-480c-b7bb-c44a633a0f1b.png)

### Logs
- $logging - Enabled: saving all logs. Below you can set all paths.
![image](https://user-images.githubusercontent.com/83921557/155861770-24bcea19-c8a0-4875-9276-f01871073dc3.png)

