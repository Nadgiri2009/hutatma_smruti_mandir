$cs = "Server=localhost\SQLEXPRESS02;Database=HutatmaBookingDB;User Id=sa;Password=Shreyas_@1999;TrustServerCertificate=True"
$sql = "SELECT COLUMN_NAME, IS_NULLABLE, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Applicants' ORDER BY ORDINAL_POSITION"
$conn = New-Object System.Data.SqlClient.SqlConnection($cs)
$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$conn.Open()
$reader = $cmd.ExecuteReader()
while($reader.Read()){
	Write-Output ($reader['COLUMN_NAME'] + ' | ' + $reader['IS_NULLABLE'] + ' | ' + $reader['DATA_TYPE'])
}
$conn.Close()
