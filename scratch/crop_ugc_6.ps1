Add-Type -AssemblyName System.Drawing

$baseDir = "C:\Users\Sufiyan\.gemini\antigravity-ide\brain\fb88c3d8-f48d-41b3-97a7-e6cb26c6dda2\"
$outDir = "d:\antigravity_file\assets\"

# Crop Card 6 from media__1784530519874.png
$imgPath = Join-Path $baseDir "media__1784530519874.png"
$bmp = New-Object System.Drawing.Bitmap($imgPath)

# Let's crop it cleanly. Since it is 252 x 400, let's check borders.
# Let's crop 5px from each side to remove any minor borders: Left=5, Top=5, Width=242, Height=390.
$left = 6
$top = 6
$w = $bmp.Width - 12
$h = $bmp.Height - 12

$rect = New-Object System.Drawing.Rectangle($left, $top, $w, $h)
$cropped = $bmp.Clone($rect, $bmp.PixelFormat)
$cropped.Save((Join-Path $outDir "thumb_ugc_6.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropped.Dispose()
$bmp.Dispose()

Write-Output "Video 6 screenshot cropped and saved as thumb_ugc_6.jpg"
