# Expiring password notifier
This script sending emails to Active Directory users which password going to expire in several days.

1. Script and all stuff must be embedded into C:\Skrypty\PasswordExpired or you can change paths inside script

2. You need to set up credentials for the script to send notifications. You can to this by:
	- Go into credentials directory and run setCredentials.ps1
	- This script will prompt you for credentials and it will save those encrypted inside store directory
	- Use account intended to sending notifications like those

3. Logs are saved inside Logs directory. Script is saving 3 types of logs.
	Whom message was sent, Whom message wasn't sent and accounts without emails


4. Script PasswordExpired.ps1 is responsible for sending notifications.

5. The best way for run this script is embed that into Task Scheduler inside Windows Server at your company domain.
