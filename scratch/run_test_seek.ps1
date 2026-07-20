$proc = Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "--headless", "--disable-gpu", "http://localhost:8081/test_seek.html" -PassThru
Start-Sleep -Seconds 20
Stop-Process -Id $proc.Id -Force
Write-Output "Test seek finished."
