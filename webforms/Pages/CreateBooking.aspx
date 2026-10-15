<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Create Booking (Pages)</title>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            lblMessage.Text = string.Empty;
            int venueId;
            if (!int.TryParse(txtVenueId.Text, out venueId))
            {
                lblMessage.Text = "Invalid VenueId.";
                return;
            }
            DateTime fromDate;
            DateTime toDate;
            if (!DateTime.TryParse(txtFromDate.Text, out fromDate) || !DateTime.TryParse(txtToDate.Text, out toDate))
            {
                lblMessage.Text = "Invalid dates.";
                return;
            }

            var fullName = txtFullName.Text ?? string.Empty;
            var connStr = System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : null;
            if (string.IsNullOrWhiteSpace(connStr))
            {
                lblMessage.Text = "No DB connection configured.";
                return;
            }

            try
            {
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                {
                    conn.Open();
                    using (var tran = conn.BeginTransaction())
                    {
                        var insertBooking = "INSERT INTO Bookings (VenueId, VenuePricingId, FromDate, ToDate, Session, TotalDays, BaseRent, Status, CreatedAt) " +
                                            "VALUES (@VenueId, 0, @FromDate, @ToDate, 'FullDay', DATEDIFF(day, @FromDate, @ToDate) + 1, 0, 'PendingPayment', GETUTCDATE()); SELECT SCOPE_IDENTITY();";
                        using (var cmd = new System.Data.SqlClient.SqlCommand(insertBooking, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@VenueId", venueId);
                            cmd.Parameters.AddWithValue("@FromDate", fromDate);
                            cmd.Parameters.AddWithValue("@ToDate", toDate);
                            var idObj = cmd.ExecuteScalar();
                            var bookingId = Convert.ToInt32(idObj);

                            var insertApplicant = "INSERT INTO Applicants (BookingId, FullName, Email, Mobile, Address, FunctionName, FunctionType, ExpectedGuests, CreatedAt) " +
                                                   "VALUES (@BookingId, @FullName, '', '', '', '', '', 0, GETUTCDATE());";
                            using (var cmd2 = new System.Data.SqlClient.SqlCommand(insertApplicant, conn, tran))
                            {
                                cmd2.Parameters.AddWithValue("@BookingId", bookingId);
                                cmd2.Parameters.AddWithValue("@FullName", fullName);
                                cmd2.ExecuteNonQuery();
                            }
                        }
                        tran.Commit();
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "Booking created successfully.";
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h2>Create Booking (Pages)</h2>
            <asp:Label ID="lblMessage" runat="server" ForeColor="Red"></asp:Label>
            <div>
                VenueId: <asp:TextBox ID="txtVenueId" runat="server"></asp:TextBox>
            </div>
            <div>
                FromDate (yyyy-MM-dd): <asp:TextBox ID="txtFromDate" runat="server"></asp:TextBox>
            </div>
            <div>
                ToDate (yyyy-MM-dd): <asp:TextBox ID="txtToDate" runat="server"></asp:TextBox>
            </div>
            <div>
                Full Name: <asp:TextBox ID="txtFullName" runat="server"></asp:TextBox>
            </div>
            <div>
                <asp:Button ID="btnCreate" runat="server" Text="Create" OnClick="btnCreate_Click" />
            </div>
        </div>
    </form>
</body>
</html>