using System;
using System.Web;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using HutatmaBooking.WebForms.App_Code;

namespace HutatmaBooking.WebForms.App_Code
{
    public class CreateBookingHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            try
            {
                var req = context.Request;
                int venueId = 0;
                DateTime fromDate = DateTime.MinValue, toDate = DateTime.MinValue;
                int.TryParse(req.Form["VenueId"] ?? req["VenueId"], out venueId);
                DateTime.TryParse(req.Form["FromDate"] ?? req["FromDate"], out fromDate);
                DateTime.TryParse(req.Form["ToDate"] ?? req["ToDate"], out toDate);
                var fullName = (req.Form["FullName"] ?? req["FullName"] ?? string.Empty).Trim();

                if (venueId <= 0 || fromDate == DateTime.MinValue || toDate == DateTime.MinValue)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write(new JavaScriptSerializer().Serialize(new { success = false, error = "Invalid input. Required: VenueId, FromDate, ToDate." }));
                    return;
                }

                var connStr = DbHelper.GetConnectionString();
                if (string.IsNullOrWhiteSpace(connStr))
                {
                    context.Response.StatusCode = 500;
                    context.Response.Write(new JavaScriptSerializer().Serialize(new { success = false, error = "No DB connection configured." }));
                    return;
                }

                using (var conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    using (var tran = conn.BeginTransaction())
                    {
                        var bookingNumber = Guid.NewGuid().ToString("N").Substring(0,8).ToUpper();
                        int venuePricingId = 0;
                        using (var lookup = new SqlCommand("SELECT TOP 1 Id FROM VenuePricing WHERE VenueId = @VenueId", conn, tran))
                        {
                            lookup.Parameters.AddWithValue("@VenueId", venueId);
                            var vpObj = lookup.ExecuteScalar();
                            if (vpObj == null)
                            {
                                tran.Rollback();
                                context.Response.StatusCode = 400;
                                context.Response.Write(new JavaScriptSerializer().Serialize(new { success = false, error = "No pricing found for the given VenueId." }));
                                return;
                            }
                            venuePricingId = Convert.ToInt32(vpObj);
                        }

                        var insertBooking = "INSERT INTO Bookings (VenueId, VenuePricingId, FromDate, ToDate, Session, TotalDays, BaseRent, HolidayCharge, EquipmentCharge, SecurityDeposit, CGSTAmount, SGSTAmount, GrandTotal, Status, CreatedAt, BookingNumber) " +
                                            "VALUES (@VenueId, @VenuePricingId, @FromDate, @ToDate, 'FullDay', DATEDIFF(day, @FromDate, @ToDate) + 1, 0, @HolidayCharge, @EquipmentCharge, @SecurityDeposit, @CGSTAmount, @SGSTAmount, @GrandTotal, 'PendingPayment', GETUTCDATE(), @BookingNumber); SELECT SCOPE_IDENTITY();";
                        int bookingId = 0;
                        using (var cmd = new SqlCommand(insertBooking, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@VenueId", venueId);
                            cmd.Parameters.AddWithValue("@VenuePricingId", venuePricingId);
                            cmd.Parameters.AddWithValue("@FromDate", fromDate);
                            cmd.Parameters.AddWithValue("@ToDate", toDate);
                            cmd.Parameters.AddWithValue("@BookingNumber", bookingNumber);
                            cmd.Parameters.AddWithValue("@HolidayCharge", 0);
                            cmd.Parameters.AddWithValue("@EquipmentCharge", 0);
                            cmd.Parameters.AddWithValue("@SecurityDeposit", 0);
                            cmd.Parameters.AddWithValue("@CGSTAmount", 0);
                            cmd.Parameters.AddWithValue("@SGSTAmount", 0);
                            cmd.Parameters.AddWithValue("@GrandTotal", 0);
                            var idObj = cmd.ExecuteScalar();
                            bookingId = Convert.ToInt32(idObj);

                            var insertApplicant = "INSERT INTO Applicants (BookingId, FullName, Email, Mobile, AlternateMobile, Address, FunctionName, FunctionType, ExpectedGuests, IDProofType, IDProofFile, CreatedAt) " +
                                                       "VALUES (@BookingId, @FullName, @Email, @Mobile, NULL, @Address, @FunctionName, @FunctionType, @ExpectedGuests, @IDProofType, NULL, GETUTCDATE());";
                                using (var cmd2 = new SqlCommand(insertApplicant, conn, tran))
                                {
                                    cmd2.Parameters.AddWithValue("@BookingId", bookingId);
                                    cmd2.Parameters.AddWithValue("@FullName", fullName);
                                    cmd2.Parameters.AddWithValue("@Email", "");
                                    cmd2.Parameters.AddWithValue("@Mobile", "");
                                    cmd2.Parameters.AddWithValue("@Address", "");
                                    cmd2.Parameters.AddWithValue("@FunctionName", "");
                                    cmd2.Parameters.AddWithValue("@FunctionType", "");
                                    cmd2.Parameters.AddWithValue("@ExpectedGuests", 0);
                                    cmd2.Parameters.AddWithValue("@IDProofType", "");
                                    cmd2.ExecuteNonQuery();
                                }
                        }
                        tran.Commit();
                        context.Response.StatusCode = 201;
                        context.Response.Write(new JavaScriptSerializer().Serialize(new { success = true, bookingId = bookingId }));
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                try
                {
                    context.Response.StatusCode = 500;
                    context.Response.Write(new JavaScriptSerializer().Serialize(new { success = false, error = ex.Message }));
                }
                catch { }
            }
        }

        public bool IsReusable { get { return false; } }
    }
}
