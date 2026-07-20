Add-Type -AssemblyName System.Drawing

$files = @("media__1784404459083.png", "media__1784404459110.png")
$baseDir = "C:\Users\Sufiyan\.gemini\antigravity-ide\brain\fb88c3d8-f48d-41b3-97a7-e6cb26c6dda2\"

foreach ($f in $files) {
    $path = Join-Path $baseDir $f
    $bmp = New-Object System.Drawing.Bitmap($path)
    Write-Output "--- Matrix for $f ($($bmp.Width)x$($bmp.Height)) ---"
    
    for ($y = 0; $y -lt $bmp.Height; $y += 60) {
        $line = ""
        for ($x = 0; $x -lt $bmp.Width; $x += 35) {
            $p = $bmp.GetPixel($x, $y)
            $b = [int](($p.R + $p.G + $p.B) / 76.5) # 0 to 10
            $line += $b.ToString()
        }
        Write-Output $line
    }
    $bmp.Dispose()
}
