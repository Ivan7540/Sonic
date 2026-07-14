/**
* Author	:	Swapnil Walse
* Date		:	19 May 2021
* Desc		:	controller for add merchant number component used in flows.
* 				
**/
public class LCC_AddMerchantNumberController 
{
    @AuraEnabled
    public static List<MerchantId__c> getMerchantIds(String recordId)
    {

        return 
        [
            SELECT  Id,
                    Name,
                    mccCode__c,
                    AcquiringBank__c,
                    Description__c,
                    Type__c,
                    Product_Family__c
            FROM MerchantId__c
            WHERE Account__c = :recordId
            AND Active__c = true
        ];
    }
}