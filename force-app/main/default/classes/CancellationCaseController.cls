public class CancellationCaseController 
{
    public Id cancellationCaseId {get; set;}
    public Case cancellation;
    public Date lastInvoiceDate;
    public SBQQ__QuoteLine__c cancellationFee;

    public Case getCancellation()
    {
        if(cancellationCaseId != null)
        {
            cancellation = 
            [
                SELECT  Id,
                        Account.Name,
                        CreatedDate,
                        Effective_Date__c,
                        RelatedQuote__c,
                        RelatedQuote__r.SBQQ__StartDate__c
                FROM Case
                WHERE Id = :cancellationCaseId
                LIMIT 1
            ];
        }

        return cancellation;
    }

    public Date getLastInvoiceDate()
    {
        if(cancellation != null && cancellation.Effective_Date__c != null)
        {
            lastInvoiceDate = DateUtil.lastOfMonth(cancellation.Effective_Date__c).addDays(15);
        }

        return lastInvoiceDate;
    }

    public SBQQ__QuoteLine__c getCanellationFee()
    {
        if(cancellation != null && cancellation.RelatedQuote__c != null)
        {
            List<SBQQ__QuoteLine__c> results = 
            [
                SELECT  Id,
                        SBQQ__NetPrice__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c = :cancellation.RelatedQuote__c
                AND SBQQ__Product__r.ProductCode = :UTIL_Constants.CANCELLATION_CODE
                ORDER BY CreatedDate DESC
            ];

            if(!results.isEmpty())
            {
                cancellationFee = results[0];
            }            
        }

        return cancellationFee;
    }
}