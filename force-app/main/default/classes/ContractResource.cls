/*
Date created: 21/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-358
*/
@RestResource(urlMapping='/contract/*')
global class ContractResource 
{
    @HttpGet
    global static List<BillingUtil.BillingContract> getNonGiftContracts()
    {
        Map<String, String> requestParams = RestContext.request.params;

        String billingDateParam = BillingUtil.managedParameterGet(requestParams, BillingUtil.DATE_PARAM);        
        Date billingDate = BillingUtil.convertParameterToDate(billingDateParam);

        Integer queryOffset = Integer.valueOf(BillingUtil.managedParameterGet(requestParams, BillingUtil.OFFSET_PARAM));
        Integer queryLimit = Integer.valueOf(BillingUtil.managedParameterGet(requestParams, BillingUtil.LIMIT_PARAM));

        List<Contract> noGiftContracts = BillingUtil.getNonGiftContracts(billingDate, queryOffset, queryLimit);
System.debug('Contract: '+noGiftContracts.size());
        /* Test enabling code 
        List<Contract> sampledContracts = new List<Contract>();
        Set<Id> accountIds = new Set<Id>();

        for(Contract contr :noGiftContracts)
        {
            if(!accountIds.contains(contr.AccountId) && accountIds.size() < 1001)
            {
                accountIds.add(contr.AccountId);
            }

            if(accountIds.contains(contr.AccountId))
            {
                sampledContracts.add(contr);
            }
        }
        /* Test enabling code end */

        // return BillingUtil.produceBillingContracts(sampledContracts, billingDate);
        return BillingUtil.produceBillingContracts(noGiftContracts, billingDate);
    }
}