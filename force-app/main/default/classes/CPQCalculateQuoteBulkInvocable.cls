global class CPQCalculateQuoteBulkInvocable 
{
    @InvocableMethod
    public static void calculate(List<List<Id>> quoteIds) 
    {
        for(List<Id> quoteId :quoteIds)
        {
            CPQ_APICalculateQuoteInvocable.calculateQuote(quoteId);
        }
    }
}