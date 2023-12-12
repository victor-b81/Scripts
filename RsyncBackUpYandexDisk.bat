REM # ��ਯ� ᨭ�஭���樨 �������� ������ � ������ ��᪮� � Windows

@ECHO OFF
REM # ��� ����� ᨭ�஭���樨 �ਬ������� �ணࠬ��:
REM # cmail - https://www.inveigle.net/cmail/download
REM # rclone - https://rclone.org/downloads/
REM # ��������!!! ��� ���४⭮�� �⮡ࠦ���� ᨬ����� � ���⮢�� ᮮ�饭���, ����஢�� 䠩��-�ਯ� ������ ���� OEM 866

REM # ���� ����ன�� �६��� ��� 䠩�� �����
	SET hr=%time:~0,2%
	IF "%hr:~0,1%" equ " " SET hr=0%hr:~1,1%
	SET DATETIMEF=%date:~-4,4%_%date:~-7,2%_%date:~-10,2%__%hr%_%time:~3,2%_%time:~6,2%

REM # ���� ����ன�� �����
	REM # 㪠�뢠�� �ᯮ������� 䠩�� ���⮢�� �ணࠬ��
		SET CMAIL_PATH="C:\Program Files\cmail\cmail.exe"
	REM # 㪠�뢠�� ���, ��஫� � ����� ��ࠢ�⥫�
		SET MAIL_SENDER=���஭��� ����@yandex.ru
		SET USER_SENDER_NAME=��� ��ࠢ�⥫�
		SET USER_PASS=��஫� ��� �ਫ������ ᮧ����� � ﭤ���
	REM # 㪠�뢠�� smtp ���� ����� ��ࠢ�⥫�
		SET MAIL_SMTP_ADDRESS=smtp.yandex.ru
	REM # 㪠�뢠�� ⨯ ����� SSL ����� ��ࠢ�⥫�
		REM # SSL/TLS (STARTTLS): 	-starttls
		REM # SSL/TLS (SMTPS):		-secureport
		SET MAIL_SMTP_AUTHENTICATION=-starttls
	REM # 㪠�뢠�� ����� �����⥫�
		SET MAIL_RECEPIENT=���� �����⥫�@yandex.ru
		
REM # ���� ����ன�� �ணࠬ�� १�ࢭ��� ����஢����
	REM # ����뢠�� �ᯮ������� 䠩�� rclone.conf (�� 㬮�砭��, ��室���� �� �⮬� ���, �� ��� ����� ��६�����)
		SET RCLONE_CFG_PATH="C:\Users\"���짮��⥫�"\AppData\Roaming\rclone\rclone.conf"
	REM # ����뢠�� �ᯮ������� �ணࠬ�� ᨭ�஭���樨 rclone.exe
		SET RCLONE_EXE_PATH="C:\Program Files\rclone\rclone.exe"
	REM # 㪠�뢠�� �ᯮ������� 䠩�� log � ��ᢠ����� ��� ����饥 �� ���� � �६���
		SET RCLONE_LOG_FILE="D:\LogFiles\rclone_log\%DATETIMEF%.log"
	REM # --stats-one-line (DEBUG INFO NOTICE ERROR) 㪠�뢠�� ��㡨�� ����஢����
		SET RCLONE_OPT_PRM=--log-file=%RCLONE_LOG_FILE% --log-level INFO --progress
	REM # --include *.{vbk} --exclude *.{vib,vbm,bco} �᪫�祭�� �� ����室�����
		SET RCLONE_OPT_SEC=
	REM # ��⠭�������� ᪮���� ��࠭�祭�� �� �६��� --bwlimit "06:00,1M 18:00,1M 20:00,off"
		SET RCLONE_OPT_BWL=--bwlimit "06:00,1M 18:00,1M 20:00,off"
	REM # ����ࠥ� ������� ᨭ�஭���樨, � ���� 楫�� ��ப�
		SET RCLONE_OPTIONS=--config=%RCLONE_CFG_PATH% %RCLONE_OPT_PRM% %RCLONE_OPT_SEC% %RCLONE_OPT_BWL%

SETLOCAL
REM # �믮��塞 ᨭ�஭�����
		%RCLONE_EXE_PATH% sync D:\BackUp ��⭠����@yandex.ru:/������������ᄨ᪥ %RCLONE_OPTIONS%

REM # �஢�ન �� ����稥 �訡��
		REM # �஢�ઠ �᫨ �訡�� ᨭ�஭���樨, � ��ࠢ�塞 email � ���ᠭ�� �訡�� � 䠩��� �����
		FINDSTR /I "ERROR" %RCLONE_LOG_FILE% && GOTO ERRORSEND

		REM # �஢�ઠ �᫨ ��祣� ᨭ�஭���஢���, � ��ࠢ�塞 email � 㢥��������� � ������⢨� ����� 䠩���
		FINDSTR /C:"There was nothing to transfer" %RCLONE_LOG_FILE% && GOTO NTTSEND

	REM # �믮��塞 ���뫪� ��ᥬ � ���ଠ樥� � ����� १�ࢭ��� ����஢����
:ALLOK
ECHO "DO ALL OK SEND"
		%CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:C���஭����� १�ࢭ�� �����, �믮����� �ᯥ譮!" "-body:����ࢭ� �����, ���㦥�� � �����ᄨ� ���������!" "-a:%RCLONE_LOG_FILE%"
		GOTO DOLOG

:ERRORSEND
		ECHO "DO ERROR SEND"
		%CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:�訡�� ᨭ�஭���樨 १�ࢭ�� �����!" "-body:����ࢭ� �����, ���뫨 ���㦥�� � �����ᄨ�!" "-a:%RCLONE_LOG_FILE%"
		GOTO DOLOG

:NTTSEND
ECHO "DO NTT SEND"
		%CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:��� ��쥪⮢ ��� ᨭ�஭���樨 १�ࢭ�� �����!" "-body:��� ��쥪⮢ ��� ᨭ�஭���樨 १�ࢭ�� �����!" "-a:%RCLONE_LOG_FILE%"

REM # �ନ�㥬 ����஢���� �����
:DOLOG
	REM # ����㥬 ����� � ��騩 䠩� �����
		type %RCLONE_LOG_FILE% >> "D:\LogFiles\rclone_log\sync-history.log"
	REM # ��७�� ���⪨ �� ᫥������ ��ப� � 䠩�� �����
		echo. >> "D:\LogFiles\rclone_log\sync-history.log"
		del %RCLONE_LOG_FILE% /f /q	
ENDLOCAL
exit

