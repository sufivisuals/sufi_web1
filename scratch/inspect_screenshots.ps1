Add-Type -AssemblyName System.Drawing

$files = @(
    "media__1784401320088.png",
    "media__1784401355340.png",
    "media__1784401527253.png",
    "media__1784401527258.png",
    "media__1784404459027.png",
    "media__1784404459083.png",
    "media__1784404459110.png"
)

$baseDir = "C:\Users\Sufiyan\.gemini\antigravity-ide\brain\fb88c3d8-f48d-41b3-97a7-e6cb26c6dda2\"

foreach ($f in $files) {
    $path = Join-Path $baseDir $f
    if (Test-Path $path) {
        $img = [System.Drawing.Image]::FromFile($path)
        Write-Output "$f : $($img.Width) x $($img.Height)"
        $img.Dispose()
    }
}
