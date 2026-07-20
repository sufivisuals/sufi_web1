Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap("d:\antigravity_file\assets\client_insights_1.png")

Write-Output "Image size: $($bmp.Width) x $($bmp.Height)"

# Print a matrix of pixel brightness values (0 to 9)
for ($y = 0; $y -lt $bmp.Height; $y += 15) {
    $line = ""
    for ($x = 0; $x -lt $bmp.Width; $x += 10) {
        $p = $bmp.GetPixel($x, $y)
        $brightness = [int](($p.R + $p.G + $p.B) / 76.5) # 0 to 10
        $line += $brightness.ToString()
    }
    Write-Output $line
}
$bmp.Dispose()
