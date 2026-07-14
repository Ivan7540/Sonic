public class DAL_BusinessHours
{
    public static BusinessHours getDefaultHours()
    {
        List<BusinessHours> results =
        [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = 'Default'
        ];

        if(results.size() == 1)
        {
            return results[0];
        }
        else
        {
            return null;
        }
    }
}