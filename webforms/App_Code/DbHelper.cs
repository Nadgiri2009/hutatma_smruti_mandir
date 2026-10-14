using System.Configuration;

namespace HutatmaBooking.WebForms.App_Code
{
    public static class DbHelper
    {
        public static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString;
        }
    }
}
