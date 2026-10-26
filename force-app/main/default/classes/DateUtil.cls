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

    public static Boolean areSameMonth(Date seed, Date examined)
    {
        Integer seedYear = seed.year();
        Integer examinedYear = examined.year();
        Integer seedMonth = seed.month();
        Integer examinedMonth = examined.month();

        return seedYear == examinedYear && seedMonth == examinedMonth;
    }

    public static String dateSuffix(Integer day)
    {     
        if(day == null || day < 1 || day > 31)
        {
            return '';
        }

        if(day >= 11 && day <= 13)
        {
            return 'th';
        }
        
        switch on Math.mod(day, 10)
        {
            when 1
            {
                return 'st';
            }
            when 2
            {
                return 'nd';
            }
            when 3
            {
                return 'rd';
            }
            when else
            {
                return 'th';
            }
        }
    }

    public static String dateSuffix(String day)
    {
        if(String.isBlank(day) || !day.isNumeric())
        {
            return '';
        }

        return dateSuffix(Integer.valueOf(day));
    }
}