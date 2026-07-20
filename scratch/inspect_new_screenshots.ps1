Add-Type -AssemblyName System.Drawing

$files = @(
    "media__1784526349221.png",
    "media__1784526353283.png",
    "media__1784526500918.png",
    "media__1784526507873.png",
    "media__1784526522431.png",
    "media__1784530077537.png",
    "media__1784530519874.png",
    "media__1784531476363.png"
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
