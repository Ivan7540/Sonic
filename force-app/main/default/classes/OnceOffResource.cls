@RestResource(urlMapping='/onceoff/*')
global class OnceOffResource 
{
    @HttpGet
    global static List<OrderItem> getProds()
    {
        String requestUri = RestContext.request.requestURI;
        String param = requestUri.substring(requestUri.lastIndexOf('/') + 1);

        MerchantId__c merchantNumber = getMerchantNumber(param);

        List<OrderItem> orderProducts = getOnceOffs(merchantNumber.Account__c);
        return orderProducts;
    }

    private static MerchantId__c getMerchantNumber(String merchNumber)
    {
        return
        [
            SELECT  Id, 
                    Name,
                    Account__c
            FROM MerchantId__c
            WHERE Name = :merchNumber
            LIMIT 1
        ];
    }

    private static List<OrderItem> getOnceOffs(Id accountId)
    {
        List<OrderItem> results =
        [
            SELECT  Id,
                    OrderId,
                    TotalPrice,
                    Quantity,
                    UnitPrice,
                    Product2.SBQQ__AssetConversion__c,
                    Product2.SBQQ__SubscriptionPricing__c,
                    PricebookEntry.Product2.SBQQ__AssetConversion__c,
                    Product2.ExternalId,
                    Order.EffectiveDate,
                    Order.EndDate,
                    ServiceDate,
                    CurrencyISOCode
            FROM OrderItem
            WHERE Order.AccountId = :accountId
            AND Product2.SBQQ__AssetConversion__c = null
            AND Product2.SBQQ__SubscriptionPricing__c = null
        ];

        return results;
    }
}