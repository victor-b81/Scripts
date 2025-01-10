REM # Script for checking the status of MTS balance by means of API
@ECHO off 

REM # The following software is required for the process of checking MTS balance status via API:
REM # cmail - https://www.inveigle.net/cmail/download
REM # jq - https://jqlang.github.io/jq/
REM # curl - Preinstalled in Windows 10/11. You can also download https://curl.se/windows/.
REM # iconv.exe part of the GnuWin32 package - https://gnuwin32.sourceforge.net/packages/libiconv.htm
REM # Attention!!! For correct display of characters in mail messages, the encoding of the script file must be OEM 866.

REM # = Define input data
REM # Specify the location of the JQ program for JSON processing
	SET JQ_PATH="C:\AddSoft\jq\jq-windows-amd64.exe"
	
REM # Specify the location of the iconv program for encoding conversion
	SET ICONV_PATH="C:\AddSoft\GnuWin32\bin\iconv.exe"

REM # Mail configuration block
	REM # Specify the location of the mail program file
		SET CMAIL_PATH="C:\AddSoft\CMail\cmail.exe"
	REM # specify the sender's name, password, and e-mail address
		SET MAIL_SENDER=mail@mail.com
		SET USER_SENDER_NAME=mail@mail.com
		SET USER_PASS=_App_Password_
	REM # specify the sender's smtp mail address (technical mailbox)
		SET MAIL_SMTP_ADDRESS=smtp.mail.com
	REM # specify the subject of the e-mail
		SET MAIL_SUBJECT=Not enough funds on MTS personal accounts - 
	REM # specify smtp mail address of the sender
		REM # SSL/TLS (STARTTLS): 	-starttls
		REM # SSL/TLS (SMTPS):		-secureport
		SET MAIL_SMTP_AUTHENTICATION=-starttls
	REM # specify the mail of the recipient of the balance shortage notification.
		SET MAIL_RECEPIENT=_mailbox_Recipient_
		
REM # Check if there is a directory for the report files
	IF NOT EXIST D:\logs\Chek_MTS\ mkdir D:\logs\Chek_MTS\

REM # Specify the default folder for operation
	SET WORK_DIR="D:\logs\Chek_MTS"
	
REM # ATTENTION !!! Create an array of personal accounts (manually!!!)
	SET accountArray[0]=211111111111
	SET accountArray[1]=222222222222
	SET accountArray[2]=233333333333
	SET accountArray[3]=244444444444
	SET accountArray[4]=255555555555

REM # Declare the length counter of the array 
	SET length=0

REM # Create a file for the report
	ECHO Status of MTS personal accounts on %date% > %WORK_DIR%\raport.txt

REM # Receive token data as JSON to connect to MTS API and save it to the file tmp_output_token.json.
	curl --location --request POST "https://api.mts.ru/token" -u "_user_:_password_" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "grant_type=client_credentials" -o %WORK_DIR%\tmp_output_token.json

REM # Extract token from MTS API response JSON to the file tmp_access_token.tmp
	%JQ_PATH% -r .access_token %WORK_DIR%\tmp_output_token.json > %WORK_DIR%\access_token.tmp

REM # Assign the MTS API token to the Token variable
	SET /p Token="" < %WORK_DIR%\access_token.tmp

REM # = Determine the length of the personal account array
REM # Begin Cycle of determining the length of the array
:NextStep
	IF defined accountArray[%length%] (
	SET /A length+=1
	GOTO NextStep
)
REM # Set the length of the array to be one less than the length of the array
	SET /A length=%length%-1
REM # End Array length loop

REM # = Check the status of personal accounts
REM # Enable extended command processing
SETLOCAL enableelayedexpansion
REM # Start of the cycle of processing the array of personal accounts
	FOR /L %%i IN (0,1,%length%) DO (
		SET dataArray=!accountArray[%%i]!
REM # Get MTS personal account data as JSON and output the data to the file tmp_check_balance.json
		curl -H "Accept: application/json" -X --location --request GET "https://api.mts.ru/b2b/v1/Bills/CheckBalanceByAccount?fields=MOAF&accountNo=!dataArray!" --header "Authorization: Bearer %Token%" -o %WORK_DIR%\tmp_check_balance.json
REM # Get MTS personal account data and output the data to the file account_balance.tmp
		%JQ_PATH% -r .[].customerAccountBalance.[].remainedAmount.amount %WORK_DIR%\tmp_check_balance.json > %WORK_DIR%\account_balance.tmp
REM # Assign the value of the personal account balance to the variable tmpBalance
		SET /P tmpBalance=< %WORK_DIR%\account_balance.tmp
REM # Round the personal account balance value to integers
		SET /A tmpBalance=!tmpBalance! 2>NUL
REM # Check if the balance crosses the threshold value. If the balance is less than 300 rubles, the system will send notifications to the mail.
		IF /I !tmpBalance! LEQ 300 (ECHO Personal account !dataArray! = !tmpBalance! rub. - The amount is less than 300 rub. >> %WORK_DIR%\raport.txt
		SET MAIL_SUBJECT=!MAIL_SUBJECT!!dataArray! 
		) ELSE (ECHO Personal account !!dataArray! = !tmpBalance! rub. >> %WORK_DIR%\raport.txt)
REM # End of the cycle of processing the array of personal accounts
	)

REM # Convert the report file to UTF-8 format
	%ICONV_PATH% -c -f 866 -t utf-8 %WORK_DIR%\raport.txt > %WORK_DIR%\raport_to_mail.txt

REM # Check if there are any accounts with insufficient balance and send a notification e-mail.
	FINDSTR /C: "amount is less" %WORK_DIR%\raport.txt && %CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:!MAIL_SUBJECT!" -body-file:!WORK_DIR!\raport_to_mail.txt
	
ENDLOCAL
REM # Turn off advanced command processing
EXIT
