$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8081/")
try {
    $listener.Start()
    Write-Output "Listening on http://localhost:8081/ ..."
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            $request = $context.Request
            $response = $context.Response
            
            $url = $request.Url.LocalPath
            
            # POST Handler for saving thumbnails
            if ($request.HttpMethod -eq "POST" -and $url -eq "/save-thumbnail") {
                $name = $request.QueryString["name"]
                if ($null -eq $name) { $name = "thumbnail.jpg" }
                
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $base64Data = $reader.ReadToEnd()
                
                $bytes = [System.Convert]::FromBase64String($base64Data)
                $savePath = Join-Path "$PSScriptRoot\assets" $name
                [System.IO.File]::WriteAllBytes($savePath, $bytes)
                
                $response.StatusCode = 200
                $msg = [System.Text.Encoding]::UTF8.GetBytes("Saved successfully")
                $response.ContentType = "text/plain"
                $response.ContentLength64 = $msg.Length
                $response.OutputStream.Write($msg, 0, $msg.Length)
                continue
            }
            
            if ($url -eq "/") { $url = "/index.html" }
            
            # URL decode to handle spaces in paths
            $decodedUrl = [System.Uri]::UnescapeDataString($url)
            if ($null -eq $decodedUrl) { $decodedUrl = $url }
            
            $filePath = Join-Path $PSScriptRoot $decodedUrl.TrimStart('/')
            
            if (Test-Path $filePath -PathType Leaf) {
                $fileInfo = New-Object System.IO.FileInfo($filePath)
                $totalBytes = $fileInfo.Length
                
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                if ($ext -eq ".html") { $contentType = "text/html; charset=utf-8" }
                elseif ($ext -eq ".css") { $contentType = "text/css" }
                elseif ($ext -eq ".js") { $contentType = "application/javascript" }
                elseif ($ext -eq ".jpg" -or $ext -eq ".jpeg") { $contentType = "image/jpeg" }
                elseif ($ext -eq ".png") { $contentType = "image/png" }
                elseif ($ext -eq ".mp4") { $contentType = "video/mp4" }
                elseif ($ext -eq ".mov") { $contentType = "video/quicktime" }
                elseif ($ext -eq ".svg") { $contentType = "image/svg+xml" }
                else { $contentType = "application/octet-stream" }
                
                $response.ContentType = $contentType
                $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
                $response.Headers.Add("Accept-Ranges", "bytes")
                
                $rangeHeader = $request.Headers["Range"]
                if ($null -ne $rangeHeader -and $rangeHeader.StartsWith("bytes=")) {
                    $range = $rangeHeader.Replace("bytes=", "").Split("-")
                    $start = [int64]$range[0]
                    $end = $totalBytes - 1
                    if ($range.Length -gt 1 -and !([string]::IsNullOrWhiteSpace($range[1]))) {
                        $end = [int64]$range[1]
                    }
                    if ($end -ge $totalBytes) { $end = $totalBytes - 1 }
                    $length = $end - $start + 1
                    
                    $response.StatusCode = 206
                    $response.Headers.Add("Content-Range", "bytes $start-$end/$totalBytes")
                    $response.ContentLength64 = $length
                    
                    $stream = [System.IO.File]::OpenRead($filePath)
                    try {
                        $null = $stream.Seek($start, [System.IO.SeekOrigin]::Begin)
                        $chunkSize = [Math]::Min($length, 65536)
                        $buffer = New-Object byte[] $chunkSize
                        $bytesRemaining = $length
                        while ($bytesRemaining -gt 0) {
                            $readSize = [Math]::Min($buffer.Length, $bytesRemaining)
                            $read = $stream.Read($buffer, 0, $readSize)
                            if ($read -le 0) { break }
                            $response.OutputStream.Write($buffer, 0, $read)
                            $bytesRemaining -= $read
                        }
                    } finally {
                        $stream.Close()
                    }
                } else {
                    $response.ContentLength64 = $totalBytes
                    $stream = [System.IO.File]::OpenRead($filePath)
                    try {
                        $buffer = New-Object byte[] 65536
                        while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                            $response.OutputStream.Write($buffer, 0, $read)
                        }
                    } finally {
                        $stream.Close()
                    }
                }
            } else {
                $response.StatusCode = 404
                $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $filePath")
                $response.ContentType = "text/plain"
                $response.ContentLength64 = $msg.Length
                $response.OutputStream.Write($msg, 0, $msg.Length)
            }
        } catch {
            Write-Warning "Connection handled: $_"
        } finally {
            if ($null -ne $context -and $null -ne $context.Response) {
                try { $context.Response.OutputStream.Close() } catch {}
            }
        }
    }
} catch {
    Write-Error $_
} finally {
    $listener.Stop()
}
