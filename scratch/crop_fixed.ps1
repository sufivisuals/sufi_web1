Add-Type -AssemblyName System.Drawing

$inputPath = "d:\antigravity_file\assets\client_insights_1.png"
$outputPath = "d:\antigravity_file\assets\client_insights_1_cropped.png"

$bmp = New-Object System.Drawing.Bitmap($inputPath)

# Crop parameters based on our analysis:
# Left padding ~20px, Top padding ~30px, Width ~190px, Height ~360px.
# Let's adjust slightly for safety: 21, 31, 188, 355
$left = 21
$top = 31
$width = 188
$height = 356

$rect = New-Object System.Drawing.Rectangle($left, $top, $width, $height)
$cropped = $bmp.Clone($rect, $bmp.PixelFormat)
$cropped.Save($outputPath)
$cropped.Dispose()
$bmp.Dispose()

Write-Output "Fixed crop complete: $width x $height saved to $outputPath"
