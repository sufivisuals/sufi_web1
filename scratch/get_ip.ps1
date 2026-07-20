$addresses = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName())
foreach ($a in $addresses) {
    if ($a.AddressFamily -eq 'InterNetwork') {
        Write-Output $a.IPAddressToString
    }
}
