Add-Type -AssemblyName System.Drawing

$inputPath = "d:\antigravity_file\assets\client_insights_1.png"
$outputPath = "d:\antigravity_file\assets\client_insights_1_cropped.png"

$bmp = New-Object System.Drawing.Bitmap($inputPath)

$width = $bmp.Width
$height = $bmp.Height

# We will scan from the edges to find the boundary of the non-black screen content.
# Let's define a threshold for "non-black". Black is (0, 0, 0) or very close.
# Let's say any pixel with R + G + B > 30 is considered screen content.

$left = 0
$right = $width - 1
$top = 0
$bottom = $height - 1

# Find Left border
:leftLoop for ($x = 0; $x -lt $width; $x++) {
    for ($y = 0; $y -lt $height; $y++) {
        $pixel = $bmp.GetPixel($x, $y)
        if (($pixel.R + $pixel.G + $pixel.B) -gt 30) {
            $left = $x
            break :leftLoop
        }
    }
}

# Find Right border
:rightLoop for ($x = $width - 1; $x -ge 0; $x--) {
    for ($y = 0; $y -lt $height; $y++) {
        $pixel = $bmp.GetPixel($x, $y)
        if (($pixel.R + $pixel.G + $pixel.B) -gt 30) {
            $right = $x
            break :rightLoop
        }
    }
}

# Find Top border
:topLoop for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $pixel = $bmp.GetPixel($x, $y)
        if (($pixel.R + $pixel.G + $pixel.B) -gt 30) {
            $top = $y
            break :topLoop
        }
    }
}

# Find Bottom border
:bottomLoop for ($y = $height - 1; $y -ge 0; $y--) {
    for ($x = 0; $x -lt $width; $x++) {
        $pixel = $bmp.GetPixel($x, $y)
        if (($pixel.R + $pixel.G + $pixel.B) -gt 30) {
            $bottom = $y
            break :bottomLoop
        }
    }
}

Write-Output "Auto-detected screen bounds: Left=$left, Right=$right, Top=$top, Bottom=$bottom"

# Ensure bounds are valid and perform crop
$cropWidth = $right - $left + 1
$cropHeight = $bottom - $top + 1

if ($cropWidth -gt 0 -and $cropHeight -gt 0) {
    # Create cropped bitmap
    $rect = New-Object System.Drawing.Rectangle($left, $top, $cropWidth, $cropHeight)
    $cropped = $bmp.Clone($rect, $bmp.PixelFormat)
    $cropped.Save($outputPath)
    $cropped.Dispose()
    Write-Output "Cropped image saved successfully to $outputPath (Size: $cropWidth x $cropHeight)"
} else {
    Write-Output "Error: Invalid crop bounds detected."
}

$bmp.Dispose()
