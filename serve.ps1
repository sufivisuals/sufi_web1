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
                $savePath = Join-Path "d:\antigravity_file\assets" $name
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
            
            $filePath = Join-Path "d:\antigravity_file" $decodedUrl.TrimStart('/')
            
            if (Test-Path $filePath -PathType Leaf) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                
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
                $response.Headers.Add("Cache-Control", "public, max-age=86400")
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
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
