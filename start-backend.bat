@echo off
cd /d C:\Users\Vanes\Desktop\ZenPay\backend
echo Building backend...
call mvn clean package -DskipTests
echo Starting backend...
start "ZenPay Backend" java -jar target\zenpay-backend-1.0.0.jar
echo Backend started on port 8080
pause
