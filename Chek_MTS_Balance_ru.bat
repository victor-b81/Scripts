REM # ��ਯ� �஢�ન ���ﭨ� ������ ��� �� �।�⢠� API
@ECHO off 

REM # ��� ����� �஢�ન ���ﭨ� ������ ��� �� �।�⢠� API �ॡ���� ᫥���饥 ��:
REM # cmail - https://www.inveigle.net/cmail/download
REM # jq - https://jqlang.github.io/jq/
REM # curl - �।��⠭������ � Windows 10/11. ����� ����� ᪠��� https://curl.se/windows/
REM # iconv.exe ���� �������� GnuWin32 - https://gnuwin32.sourceforge.net/packages/libiconv.htm
REM # ��������!!! ��� ���४⭮�� �⮡ࠦ���� ᨬ����� � ���⮢�� ᮮ�饭���, ����஢�� 䠩��-�ਯ� ������ ���� OEM 866

REM # = ��।��塞 ������ �����
REM # ����뢠�� �ᯮ������� �ணࠬ�� JQ ��� ��ࠡ�⪨ JSON
	SET JQ_PATH="C:\AddSoft\jq\jq-windows-amd64.exe"
	
REM # ����뢠�� �ᯮ������� �ணࠬ�� iconv ��� ��� �������஢���� ����஢��
	SET ICONV_PATH="C:\AddSoft\GnuWin32\bin\iconv.exe"

REM # ���� ����ன�� �����
	REM # 㪠�뢠�� �ᯮ������� 䠩�� ���⮢�� �ணࠬ��
		SET CMAIL_PATH="C:\AddSoft\CMail\cmail.exe"
	REM # 㪠�뢠�� ���, ��஫� � ����� ��ࠢ�⥫�
		SET MAIL_SENDER=mail@mail.com
		SET USER_SENDER_NAME=mail@mail.com
		SET USER_PASS=_App_Password_
	REM # 㪠�뢠�� smtp ���� ����� ��ࠢ�⥫� (�孨�᪨� ���⮢� �騪)
		SET MAIL_SMTP_ADDRESS=smtp.mail.com
	REM # 㪠�뢠�� ⥬� ���쬠
		SET MAIL_SUBJECT=�� �����筮 �।�� �� ��楢�� ���� ��� - 
	REM # 㪠�뢠�� smtp ���� ����� ��ࠢ�⥫�
		REM # SSL/TLS (STARTTLS): 	-starttls
		REM # SSL/TLS (SMTPS):		-secureport
		SET MAIL_SMTP_AUTHENTICATION=-starttls
	REM # 㪠�뢠�� ����� �����⥫� 㢥�������� � ������⪥ �� ������
		SET MAIL_RECEPIENT=_mailbox_Recipient_
		
REM # �஢��塞 ����稥 ��४�ਨ ��� 䠩��� ����
	IF NOT EXIST D:\logs\Chek_MTS\ mkdir D:\logs\Chek_MTS\

REM # ����뢠�� ����� ��� ࠡ��� �� 㬮�砭��
	SET WORK_DIR="D:\logs\Chek_MTS"
	
REM # �������� !!! ������� ���ᨢ ��楢�� ��⮢ (� �����!!!)
	SET accountArray[0]=288302665444
	SET accountArray[1]=223317397021
	SET accountArray[2]=288302665446
	SET accountArray[3]=288301520043
	SET accountArray[4]=288302665445

REM # ���塞 ���稪 ������ ���ᨢ� 
	SET length=0

REM # ������� 䠩� ��� ����
	ECHO ����ﭨ� ��楢�� ��⮢ ��� �� %date% > %WORK_DIR%\raport.txt

REM # ����砥� ����� ⮪��� � ���� JSON, ��� ������祭�� � ��� API � ��࠭塞 � 䠩� tmp_output_token.json
	curl --location --request POST "https://api.mts.ru/token" -u "_user_:_password_" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "grant_type=client_credentials" -o %WORK_DIR%\tmp_output_token.json

REM # ��������� ⮪�� �� JSON �⢥� ��� API � 䠩� tmp_access_token.tmp
	%JQ_PATH% -r .access_token %WORK_DIR%\tmp_output_token.json > %WORK_DIR%\access_token.tmp

REM # ��ᢠ����� ⮪�� ��� API ��६����� Token
	SET /p Token="" < %WORK_DIR%\access_token.tmp

REM # = ��।��塞 ����� ���ᨢ� ��楢�� ��⮢
REM # ��砫� ���� ��।������ ������ ���ᨢ�
:NextStep
	IF defined accountArray[%length%] (
	SET /A length+=1
	GOTO NextStep
)
REM # ��⠭�������� ����� ���ᨢ� ����� �� �������
	SET /A length=%length%-1
REM # ����� ���� ��।������ ������ ���ᨢ�

REM # = �஢��塞 ���ﭨ� ��楢�� ��⮢
REM # ����砥� ���७��� ��ࠡ��� ������
SETLOCAL enabledelayedexpansion
REM # ��砫� 横�� ��ࠡ�⪨ ���ᨢ� ��楢�� ��⮢
	FOR /L %%i IN (0,1,%length%) DO (
		SET dataArray=!accountArray[%%i]!
REM # ����砥� ����� ��楢��� ��� ��� � ���� JSON � �뢮��� ����� � 䠩� tmp_check_balance.json
		curl -H "Accept: application/json" -X --location --request GET "https://api.mts.ru/b2b/v1/Bills/CheckBalanceByAccount?fields=MOAF&accountNo=!dataArray!" --header "Authorization: Bearer %Token%" -o %WORK_DIR%\tmp_check_balance.json
REM # ����砥� ����� ��楢��� ��� ��� � �뢮��� ����� � 䠩� account_balance.tmp
		%JQ_PATH% -r .[].customerAccountBalance.[].remainedAmount.amount %WORK_DIR%\tmp_check_balance.json > %WORK_DIR%\account_balance.tmp
REM # ��ᢠ����� ���祭�� ������ ��楢��� ��� ��६����� tmpBalance
		SET /P tmpBalance=< %WORK_DIR%\account_balance.tmp
REM # ���㣫塞 ���祭�� ������ ��楢��� ��� �� 楫��
		SET /A tmpBalance=!tmpBalance! 2>NUL
REM # �஢��塞 ����祭�� ��ண����� ���祭�� ������. �᫨ ������ ����� 300 �㡫��, ��⥬� ��ࠢ�� 㢥�������� �� �����
		IF /I !tmpBalance! LEQ 300 (ECHO ��楢�� ��� !dataArray! = !tmpBalance! ��. - �㬬� ����� 300 ��. >> %WORK_DIR%\raport.txt
		SET MAIL_SUBJECT=!MAIL_SUBJECT!!dataArray!; 
		) ELSE (ECHO ��楢�� ��� !dataArray! = !tmpBalance! ��. >> %WORK_DIR%\raport.txt)
REM # ����� 横�� ��ࠡ�⪨ ���ᨢ� ��楢�� ��⮢
	)

REM # ��������㥬 䠩� ���� � �ଠ� UTF-8
	%ICONV_PATH% -c -f 866 -t utf-8 %WORK_DIR%\raport.txt > %WORK_DIR%\raport_to_mail.txt

REM # �஢��塞 ����稥 ��楢�� ��⮢ � �������筮� �㬬�� ������ � ��ࠢ�塞 ���쬮 㢥��������
	FINDSTR /C:"�㬬� �����" %WORK_DIR%\raport.txt && %CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:!MAIL_SUBJECT!" -body-file:!WORK_DIR!\raport_to_mail.txt
	
ENDLOCAL
REM # �몫�砥� ���७��� ��ࠡ��� ������
EXIT