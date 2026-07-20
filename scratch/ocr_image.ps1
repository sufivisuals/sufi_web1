# Run OCR on a image file using Windows Runtime API
$imagePath = "d:\antigravity_file\assets\final_cta_ref.png"

# Check if Windows OCR is available
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = [System.WindowsRuntimeSystemExtensions].GetMethods() | 
    Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Length -eq 1 } | 
    Select-Object -First 1

function Await($winRtAsyncAction) {
    $method = $asTaskGeneric.MakeGenericMethod($winRtAsyncAction.GetType().GetGenericArguments()[0])
    $task = $method.Invoke($null, @($winRtAsyncAction))
    $task.Wait()
    return $task.Result
}

# Load Windows OCR classes
[Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime] | Out-Null
[Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType=WindowsRuntime] | Out-Null
[Windows.Media.Ocr.OcrEngine, Windows.Media.Ocr, ContentType=WindowsRuntime] | Out-Null

$file = Await([Windows.Storage.StorageFile]::GetFileFromPathAsync($imagePath))
$stream = Await($file.OpenAsync([Windows.Storage.FileAccessMode]::Read))
$decoder = Await([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream))
$softwareBitmap = Await($decoder.GetSoftwareBitmapAsync())

$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
if ($null -eq $engine) {
    Write-Output "OCR Engine could not be created from user profile languages. Trying default..."
    $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage([Windows.Globalization.Language]::new("en-US"))
}

if ($null -ne $engine) {
    $ocrResult = Await($engine.RecognizeAsync($softwareBitmap))
    Write-Output "OCR Text found:"
    Write-Output $ocrResult.Text
} else {
    Write-Output "OCR engine not available."
}
