Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("d:\antigravity_file\assets\client_insights_1.png")
Write-Output "Dimensions: $($img.Width) x $($img.Height)"
$img.Dispose()
