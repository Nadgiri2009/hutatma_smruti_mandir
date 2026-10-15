$req = [System.Net.WebRequest]::Create("http://localhost:5000/CreateBookingHandler.ashx")
$req.Method = "POST"
$req.ContentType = "application/x-www-form-urlencoded"
$bytes = [System.Text.Encoding]::UTF8.GetBytes("VenueId=1&FromDate=2026-10-15&ToDate=2026-10-15&FullName=Test User")
$req.ContentLength = $bytes.Length
$req.GetRequestStream().Write($bytes,0,$bytes.Length)
try {
	$resp = $req.GetResponse()
	$sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
	Write-Output $sr.ReadToEnd()
} catch [System.Net.WebException] {
	$resp = $_.Exception.Response
	if ($resp -ne $null) {
		$sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
		Write-Output "SERVER-RESPONSE:"
		Write-Output $sr.ReadToEnd()
	} else {
		Write-Output "EXCEPTION: $($_.Exception.Message)"
	}
}
