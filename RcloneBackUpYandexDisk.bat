REM # Скрипт синхронизации локальных данных с Яндекс Диском в Windows

@ECHO OFF
REM # Для процесса синхронизации применяются программы:
REM # cmail - https://www.inveigle.net/cmail/download
REM # rclone - https://rclone.org/downloads/
REM # Внимание!!! Для корректного отображения символов в почтовых сообщениях, кодировка файла-скрипта должна быть OEM 866

REM # Блок настройки времени для файла логов
	SET hr=%time:~0,2%
	IF "%hr:~0,1%" equ " " SET hr=0%hr:~1,1%
	SET DATETIMEF=%date:~-4,4%_%date:~-7,2%_%date:~-10,2%__%hr%_%time:~3,2%_%time:~6,2%

REM # Блок настройки почты
	REM # указываем расположение файла почтовой программы
		SET CMAIL_PATH="C:\Program Files\cmail\cmail.exe"
	REM # указываем имя, пароль и почту отправителя
		SET MAIL_SENDER=электронная почта@yandex.ru
		SET USER_SENDER_NAME=имя отправителя
		SET USER_PASS=пароль для приложений созданный в яндекс
	REM # указываем smtp адрес почты отправителя
		SET MAIL_SMTP_ADDRESS=smtp.yandex.ru
	REM # указываем тип защиты SSL почты отправителя
		REM # SSL/TLS (STARTTLS): 	-starttls
		REM # SSL/TLS (SMTPS):		-secureport
		SET MAIL_SMTP_AUTHENTICATION=-starttls
	REM # указываем почту получателя
		SET MAIL_RECEPIENT=почта получателя@yandex.ru
		
REM # Блок настройки программы резервного копирования
	REM # Указываем расположение файла rclone.conf (по умолчанию, находится по этому пути, но его можно переместить)
		SET RCLONE_CFG_PATH="C:\Users\"Пользователь"\AppData\Roaming\rclone\rclone.conf"
	REM # Указываем расположение программы синхронизации rclone.exe
		SET RCLONE_EXE_PATH="C:\Program Files\rclone\rclone.exe"
	REM # указываем расположение файла log и присваиваем имя состоящее из даты и времени
		SET RCLONE_LOG_FILE="D:\LogFiles\rclone_log\%DATETIMEF%.log"
	REM # --stats-one-line (DEBUG INFO NOTICE ERROR) указываем глубину логирования
		SET RCLONE_OPT_PRM=--log-file=%RCLONE_LOG_FILE% --log-level INFO --progress
	REM # --include *.{vbk} --exclude *.{vib,vbm,bco} исключения при необходимости
		SET RCLONE_OPT_SEC=
	REM # Устанавливаем скоростные ограничения по времени --bwlimit "06:00,1M 18:00,1M 20:00,off"
		SET RCLONE_OPT_BWL=--bwlimit "06:00,1M 18:00,1M 20:00,off"
	REM # Собираем команду синхронизации, в одну целую строку
		SET RCLONE_OPTIONS=--config=%RCLONE_CFG_PATH% %RCLONE_OPT_PRM% %RCLONE_OPT_SEC% %RCLONE_OPT_BWL%

SETLOCAL
REM # выполняем синхронизацию
		%RCLONE_EXE_PATH% sync D:\BackUp УчетнаяЗапись@yandex.ru:/ПапкаНаЯндексДиске %RCLONE_OPTIONS%

REM # проверки на наличие ошибок
		REM # проверка если ошибка синхронизации, то отправляем email с описание ошибки и файлом логов
		FINDSTR /I "ERROR" %RCLONE_LOG_FILE% && GOTO ERRORSEND

		REM # проверка если нечего синхронизировать, то отправляем email с уведомлением о отсутствии новых файлов
		FINDSTR /C:"There was nothing to transfer" %RCLONE_LOG_FILE% && GOTO NTTSEND

	REM # выполняем рассылку писем с информацией о процессе резервного копирования
:ALLOK
ECHO "DO ALL OK SEND"
		%CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:Cинхронизация резервных копий, выполнена успешно!" "-body:Резервные копии, выгружены в ЯндексДиск полностью!" "-a:%RCLONE_LOG_FILE%"
		GOTO DOLOG

:ERRORSEND
		ECHO "DO ERROR SEND"
		%CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:Ошибка синхронизации резервных копий!" "-body:Резервные копии, небыли выгружены в ЯндексДиск!" "-a:%RCLONE_LOG_FILE%"
		GOTO DOLOG

:NTTSEND
ECHO "DO NTT SEND"
		%CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:Нет обьектов для синхронизации резервных копий!" "-body:Нет обьектов для синхронизации резервных копий!" "-a:%RCLONE_LOG_FILE%"

REM # формируем логирование процесса
:DOLOG
	REM # Фисируем историю в общий файл логов
		type %RCLONE_LOG_FILE% >> "D:\LogFiles\rclone_log\sync-history.log"
	REM # перенос коретки на следующую строку в файле логов
		echo. >> "D:\LogFiles\rclone_log\sync-history.log"
		del %RCLONE_LOG_FILE% /f /q	
ENDLOCAL
exit
