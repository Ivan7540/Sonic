/*
Date created: 17/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-507
*/
global class SetCommissionMonthInvocable 
{
    @InvocableMethod(label = 'Set Commission Month' description = 'Return a date of the first day of next month from the passed in date')
    public static List<Date> setCommissionMonth(List<Date> inputs)
    {
        List<Date> outputDates = new List<Date>();

        for(Date input: inputs)
        {
            outputDates.add(input.addMonths(1).toStartOfMonth());
        }
        
        return outputDates;
    }
}