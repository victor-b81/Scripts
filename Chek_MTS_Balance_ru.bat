REM # Скрипт проверки состояния баланса МТС по средствам API
@ECHO off 

REM # Для процесса проверки состояния баланса МТС по средствам API требуется следующее ПО:
REM # cmail - https://www.inveigle.net/cmail/download
REM # jq - https://jqlang.github.io/jq/
REM # curl - Предустановлено в Windows 10/11. Также можно скачать https://curl.se/windows/
REM # iconv.exe часть комплекта GnuWin32 - https://gnuwin32.sourceforge.net/packages/libiconv.htm
REM # Внимание!!! Для корректного отображения символов в почтовых сообщениях, кодировка файла-скрипта должна быть OEM 866

REM # = Определяем вводные данные
REM # Указываем расположение программы JQ для обработки JSON
	SET JQ_PATH="C:\AddSoft\jq\jq-windows-amd64.exe"
	
REM # Указываем расположение программы iconv для для конвертирования кодировки
	SET ICONV_PATH="C:\AddSoft\GnuWin32\bin\iconv.exe"

REM # Блок настройки почты
	REM # указываем расположение файла почтовой программы
		SET CMAIL_PATH="C:\AddSoft\CMail\cmail.exe"
	REM # указываем имя, пароль и почту отправителя
		SET MAIL_SENDER=mail@mail.com
		SET USER_SENDER_NAME=mail@mail.com
		SET USER_PASS=_App_Password_
	REM # указываем smtp адрес почты отправителя (технический почтовый ящик)
		SET MAIL_SMTP_ADDRESS=smtp.mail.com
	REM # указываем тему письма
		SET MAIL_SUBJECT=Не достаточно средств на лицевых счетах МТС - 
	REM # указываем smtp адрес почты отправителя
		REM # SSL/TLS (STARTTLS): 	-starttls
		REM # SSL/TLS (SMTPS):		-secureport
		SET MAIL_SMTP_AUTHENTICATION=-starttls
	REM # указываем почту получателя уведомления о недостатке на балансе
		SET MAIL_RECEPIENT=_mailbox_Recipient_
		
REM # Проверяем наличие директории для файлов отчета
	IF NOT EXIST D:\logs\Chek_MTS\ mkdir D:\logs\Chek_MTS\

REM # Указываем папку для работы по умолчанию
	SET WORK_DIR="D:\logs\Chek_MTS"
	
REM # ВНИМАНИЕ !!! Создаем массив лицевых счетов (в ручную!!!)
	SET accountArray[0]=288302665444
	SET accountArray[1]=223317397021
	SET accountArray[2]=288302665446
	SET accountArray[3]=288301520043
	SET accountArray[4]=288302665445

REM # Объявляем счетчик длинны массива 
	SET length=0

REM # Создаем файл для отчета
	ECHO Состояние лицевых счетов МТС на %date% > %WORK_DIR%\raport.txt

REM # Получаем данные токена в виде JSON, для подключения к МТС API и сохраняем в файл tmp_output_token.json
	curl --location --request POST "https://api.mts.ru/token" -u "_user_:_password_" --header "Content-Type: application/x-www-form-urlencoded" --data-urlencode "grant_type=client_credentials" -o %WORK_DIR%\tmp_output_token.json

REM # Извлекаем токен из JSON ответа МТС API в файл tmp_access_token.tmp
	%JQ_PATH% -r .access_token %WORK_DIR%\tmp_output_token.json > %WORK_DIR%\access_token.tmp

REM # Присваиваем токен МТС API переменной Token
	SET /p Token="" < %WORK_DIR%\access_token.tmp

REM # = Определяем длину массива лицевых счетов
REM # Начало Цикл определения длинны массива
:NextStep
	IF defined accountArray[%length%] (
	SET /A length+=1
	GOTO NextStep
)
REM # Устанавливаем длину массива меньше на единицу
	SET /A length=%length%-1
REM # Конец Цикл определения длинны массива

REM # = Проверяем состояние лицевых счетов
REM # Включаем расширенную обработку команд
SETLOCAL enabledelayedexpansion
REM # Начало цикла обработки массива лицевых счетов
	FOR /L %%i IN (0,1,%length%) DO (
		SET dataArray=!accountArray[%%i]!
REM # Получаем данные лицевого счета МТС в виде JSON и выводим данные в файл tmp_check_balance.json
		curl -H "Accept: application/json" -X --location --request GET "https://api.mts.ru/b2b/v1/Bills/CheckBalanceByAccount?fields=MOAF&accountNo=!dataArray!" --header "Authorization: Bearer %Token%" -o %WORK_DIR%\tmp_check_balance.json
REM # Получаем данные лицевого счета МТС и выводим данные в файл account_balance.tmp
		%JQ_PATH% -r .[].customerAccountBalance.[].remainedAmount.amount %WORK_DIR%\tmp_check_balance.json > %WORK_DIR%\account_balance.tmp
REM # Присваиваем значение баланса лицевого счета переменной tmpBalance
		SET /P tmpBalance=< %WORK_DIR%\account_balance.tmp
REM # Округляем значение баланса лицевого счета до целых
		SET /A tmpBalance=!tmpBalance! 2>NUL
REM # Проверяем пересечение порогового значения баланса. Если баланс меньше 300 рублей, система отправит уведомления на почту
		IF /I !tmpBalance! LEQ 300 (ECHO Лицевой счет !dataArray! = !tmpBalance! руб. - Сумма меньше 300 руб. >> %WORK_DIR%\raport.txt
		SET MAIL_SUBJECT=!MAIL_SUBJECT!!dataArray!; 
		) ELSE (ECHO Лицевой счет !dataArray! = !tmpBalance! руб. >> %WORK_DIR%\raport.txt)
REM # Конец цикла обработки массива лицевых счетов
	)

REM # Конвертируем файл отчета в формат UTF-8
	%ICONV_PATH% -c -f 866 -t utf-8 %WORK_DIR%\raport.txt > %WORK_DIR%\raport_to_mail.txt

REM # Проверяем наличие лицевых счетов с недостаточной суммой баланса и отправляем письмо уведомление
	FINDSTR /C:"Сумма меньше" %WORK_DIR%\raport.txt && %CMAIL_PATH% -host:%USER_SENDER_NAME%:%USER_PASS%@%MAIL_SMTP_ADDRESS% %MAIL_SMTP_AUTHENTICATION% -to:%MAIL_RECEPIENT% -from:%MAIL_SENDER% "-subject:!MAIL_SUBJECT!" -body-file:!WORK_DIR!\raport_to_mail.txt
	
ENDLOCAL
REM # Выключаем расширенную обработку команд
EXIT
