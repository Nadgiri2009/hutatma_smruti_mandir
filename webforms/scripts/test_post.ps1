$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Content-Type","application/x-www-form-urlencoded")
$body = "VenueId=1&FromDate=2026-10-15&ToDate=2026-10-15&FullName=Test User"
try {
	$response = $wc.UploadString("http://localhost:5000/CreateBookingHandler.ashx", $body)
	Write-Output "RESPONSE:"
	Write-Output $response
} catch {
	Write-Output "ERROR:"
	Write-Output $_.Exception.Message
	if ($_.Exception.Response) {
		$sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
		Write-Output $sr.ReadToEnd()
	}
}
