/*
Date created: 21/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-358
*/
@RestResource(urlMapping='/giftContract/*')
global class GiftContractResource 
{
    @HttpGet
    global static List<BillingUtil.BillingContract> getGiftContracts()
    {
        Map<String, String> requestParams = RestContext.request.params;

        String billingDateParam = BillingUtil.managedParameterGet(requestParams, BillingUtil.DATE_PARAM);
        Date billingDate = BillingUtil.convertParameterToDate(billingDateParam);

        Integer queryOffset = Integer.valueOf(BillingUtil.managedParameterGet(requestParams, BillingUtil.OFFSET_PARAM));
        Integer queryLimit = Integer.valueOf(BillingUtil.managedParameterGet(requestParams, BillingUtil.LIMIT_PARAM));
        

        List<Contract> giftContracts = BillingUtil.getGiftContracts(billingDate, queryOffset, queryLimit);
       
        return BillingUtil.produceBillingContracts(giftContracts, billingDate);
    }
}