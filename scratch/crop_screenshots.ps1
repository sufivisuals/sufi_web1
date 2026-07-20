Add-Type -AssemblyName System.Drawing

$baseDir = "C:\Users\Sufiyan\.gemini\antigravity-ide\brain\fb88c3d8-f48d-41b3-97a7-e6cb26c6dda2\"
$outDir = "d:\antigravity_file\assets\"

# Let's crop Card 2 from media__1784404459083.png
$img2Path = Join-Path $baseDir "media__1784404459083.png"
$bmp2 = New-Object System.Drawing.Bitmap($img2Path)

# Let's scan from the center outwards to find the boundaries of the dark screen
# Center is x = Width/2 = 375, y = Height/2 = 512
# The screen has a dark background in the screenshot, so it has low values, while the page background is light.
# Let's write a simple crop box.
# Based on the matrix, the white space ends and phone frame starts around column 4 (x=140) to column 18 (x=630).
# Let's do a crop at Left=190, Top=100, Width=370, Height=820.
$left = 195
$top = 110
$w = 360
$h = 800

$rect2 = New-Object System.Drawing.Rectangle($left, $top, $w, $h)
$cropped2 = $bmp2.Clone($rect2, $bmp2.PixelFormat)
$cropped2.Save((Join-Path $outDir "thumb_mua_2.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropped2.Dispose()
$bmp2.Dispose()

# Now Card 4 from media__1784404459110.png
$img4Path = Join-Path $baseDir "media__1784404459110.png"
$bmp4 = New-Object System.Drawing.Bitmap($img4Path)

$rect4 = New-Object System.Drawing.Rectangle($left, $top, $w, $h)
$cropped4 = $bmp4.Clone($rect4, $bmp4.PixelFormat)
$cropped4.Save((Join-Path $outDir "thumb_mua_4.jpg"), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$cropped4.Dispose()
$bmp4.Dispose()

Write-Output "Screenshots cropped and saved as thumb_mua_2.jpg and thumb_mua_4.jpg"
