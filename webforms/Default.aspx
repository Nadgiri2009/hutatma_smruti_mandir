<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HutatmaBooking.WebForms.Default" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Hutatma Booking - Bookings</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="gridBookings" runat="server" AutoGenerateColumns="true"></asp:GridView>
        </div>
    </form>
</body>
</html>