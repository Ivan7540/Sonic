public class DateUtil 
{
    public static Date lastOfMonth(Date startDate)
    {
        Date firstNextMonth = startDate.addMonths(1).toStartOfMonth();
        Date lastDay = firstNextMonth.addDays(-1);
        return lastDay;
    }

    public static String formatDate(Date unformattedDate, String format)
    {
        if(unformattedDate == null)
        {
            return null;
        }
        
        Datetime intermediate = (Datetime)unformattedDate;
        return intermediate.format(format);
    }
}