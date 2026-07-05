Set-Location "C:\Users\Vanes\Desktop\ZenPay"
$logFile = "C:\Users\Vanes\Desktop\ZenPay\server.log"
$process = Start-Process -NoNewWindow -FilePath "C:\Users\Vanes\AppData\Roaming\npm\npx.cmd" -ArgumentList "ng serve --host 0.0.0.0" -RedirectStandardOutput $logFile -RedirectStandardError $logFile -PassThru
Write-Output "Server started with PID: $($process.Id)"
Write-Output "Log: $logFile"
