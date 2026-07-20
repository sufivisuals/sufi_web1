$proc = Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "--headless", "--disable-gpu", "http://localhost:8081/extract_all.html" -PassThru
Start-Sleep -Seconds 30
Stop-Process -Id $proc.Id -Force
Write-Output "Chrome extraction script finished."
