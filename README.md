# Expiring password notifier
This script sending emails to Active Directory users whose password going to expire in several days.

1. Script and all stuff must be embedded into C:\Skrypty\PasswordExpired or you can change paths inside script

2. Firstly you need to set up mail-sending credentials. You can to this by:
	- Go into "credentials" directory and run setCredentials.ps1
	- This script will prompt you for email account credentials and then will save them encrypted inside "store" directory

3. Logs are saving inside "Logs" directory. Script saves 3 types of logs.
	Whom message was sent, Whom message wasn't sent and accounts without emails


4. Script PasswordExpired.ps1 is responsible for sending notifications.

5. You can embed this script into Task Scheduler inside Windows Server at your company domain in order to run script everyday at specific hour.
