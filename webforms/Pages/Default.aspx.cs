using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace HutatmaBooking.WebForms
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindBookings();
            }
        }

n        private void BindBookings()
        {
            var connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString;
            if (string.IsNullOrWhiteSpace(connStr))
            {
                return;
            }

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand("SELECT TOP 100 b.Id, a.FullName, b.VenueId, b.FromDate, b.ToDate, b.Status FROM Bookings b LEFT JOIN Applicants a ON a.BookingId = b.Id ORDER BY b.Id DESC", conn))
            using (var da = new SqlDataAdapter(cmd))
            {
                var dt = new DataTable();
                da.Fill(dt);
                gridBookings.DataSource = dt;
                gridBookings.DataBind();
            }
        }
    }
}