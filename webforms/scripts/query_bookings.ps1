$cs = "Server=localhost\SQLEXPRESS02;Database=HutatmaBookingDB;User Id=sa;Password=Shreyas_@1999;TrustServerCertificate=True"
$sql = "SELECT TOP 5 Id, CreatedAt, BookingNumber FROM Bookings ORDER BY Id DESC"
$dt = New-Object System.Data.DataTable
$conn = New-Object System.Data.SqlClient.SqlConnection($cs)
$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$da.Fill($dt) | Out-Null
if ($dt.Rows.Count -eq 0) { Write-Output 'No rows found.' } else { $dt | Format-Table -AutoSize }
