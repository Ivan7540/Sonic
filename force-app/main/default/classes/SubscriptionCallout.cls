/*
Date created: 08/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-219
*/
@RestResource(urlMapping='/billing/*')
global class SubscriptionCallout 
{
    @HttpGet
    global static List<BillingUtil.BillingContract> getContracts()
    {
        String requestUri = RestContext.request.requestURI;
        String merchantNumber = requestUri.substring(requestUri.lastIndexOf('/') + 1);

        List<MerchantId__c> merchantIds = getMerchantIds(merchantNumber);
        Id accountId = merchantIds[0].Account__c;
        List<Contract> contracts = getActiveContractsForAccount(accountId);
        Set<Id> rateContractIds = UTIL_System.extractListIds(contracts, Contract.RateContract__c.getDescribe().getLocalName(), true);
        Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>> rateMap = getRateSubscriptionMap(rateContractIds);
        Map<Id, List<OrderItem>> onceOffMap = getOnceOffs(contracts);    
        Map<Id, List<SObject>> rebateMap = getRebatesMap(contracts); 
        Map<Id, List<SBQQ__Subscription__c>> subsMap = getSubscriptionMap(contracts);

        List<BillingUtil.BillingContract> results = new List<BillingUtil.BillingContract>();

        for(Contract contr: contracts)
        {
            BillingUtil.BillingContract newBillingRecord = new BillingUtil.BillingContract();
            newBillingRecord.contractRecord = contr;
            newBillingRecord.merchantRecords = merchantIds;
            newBillingRecord.subscriptionRecords = subsMap.get(contr.Id);
            newBillingRecord.onceOffRecords = onceOffMap.get(contr.Id);
            newBillingRecord.rates = rateMap.get(contr.RateContract__c);
            newBillingRecord.legacyRebates = rebateMap.get(contr.Id);

            results.add(newBillingRecord);           
        }

        return results;
    }

    private static List<Contract> getActiveContractsForAccount(Id accountId)
    {
        return
        [
            SELECT  Id, 
                    Name,
                    ContractNumber__c,
                    Acquiring_Bank__c,
                    Owner.Email,
                    ActivatedDate, 
                    StartDate,
                    Cancellation_Effective_Date__c, 
                    ContractTerm, 
                    Contract_Terms__c,
                    InstallationDate__c,
                    EndDate,
                    AccountId,
                    Status,
                    SBQQ__OpportunityPricebookId__c, 
                    Account.Name, 
                    Account.DebtorCode__c,
                    Account.VAS_Billing_Structure__c,
                    Account.Monthly_Swipe_Value_Card_Value__c,
                    Account.ShippingState,
                    RateContract__c,
                    Contract_Type__c,
                    ContractType__c,
                    RootProductFamily__c,
                    SBQQ__Order__c,
                    SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Sub_Type__c
            FROM Contract            
            WHERE AccountId = :accountId            
        ];
    }

    private static List<MerchantId__c> getMerchantIds(String merchantNumber)
    {
        return
        [
            SELECT  Id,
                    Name,
                    Type__c,
                    Product_Family__c,
                    AcquiringBank__c,
                    Account__c
            FROM MerchantId__c
            WHERE Name = :merchantNumber
            AND Type__c != :BillingUtil.CAPITEC_TYPE
        ];
    }

    private static Map<Id, List<OrderItem>> getOnceOffs(List<Contract> contracts)
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
                    Order.SBQQ__Quote__r.SBQQ__MasterContract__c,
                    SBQQ__QuotedListPrice__c,
                    Product2.ExternalId,
                    Product2.ProductCode,
                    Product2.Name,
                    Order.EffectiveDate,
                    Order.EndDate,
                    ServiceDate,
                    CurrencyISOCode
            FROM OrderItem
            WHERE Order.SBQQ__Quote__r.SBQQ__MasterContract__c IN :contracts
            AND Product2.SBQQ__SubscriptionPricing__c = null
        ];

        Map<Id, List<OrderItem>> contractMap = new Map<Id, List<OrderItem>>();

        for(OrderItem item :results)
        {
            Id masterContractId = item.Order.SBQQ__Quote__r.SBQQ__MasterContract__c;

            if(contractMap.containsKey(masterContractId))
            {
                contractMap.get(masterContractId).add(item);
            }
            else
            {
                contractMap.put(masterContractId, new List<OrderItem>{item});
            }
        }

        return contractMap;
    }

    private static Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>> getRateSubscriptionMap(Set<Id> rateContractIds)
    {
        Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>> result = new Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>>();

        List<SBQQ__SubscriptionConsumptionSchedule__c> schedules =
        [
            SELECT  Id,                     
                    SBQQ__Subscription__r.SBQQ__Product__r.Name,
                    SBQQ__Subscription__r.SBQQ__StartDate__c,
                    SBQQ__Subscription__r.Termination_Date__c,
                    SBQQ__Subscription__r.SBQQ__Contract__r.StartDate,
                    SBQQ__Subscription__r.SBQQ__Contract__r.EndDate,
                    SBQQ__Subscription__r.SBQQ__Contract__c,
                    (
                        SELECT  Id,
                                Name,
                                SBQQ__Price__c,
                                SBQQ__SubscriptionConsumptionSchedule__c,
                                SBQQ__SubscriptionConsumptionSchedule__r.Name,
                                CurrencyISOCode
                        FROM SBQQ__SubscriptionConsumptionRates__r
                    )
            FROM SBQQ__SubscriptionConsumptionSchedule__c                    
            WHERE SBQQ__Subscription__r.SBQQ__Contract__c = :rateContractIds 
        ];

        for(SBQQ__SubscriptionConsumptionSchedule__c schedule :schedules)
        {
            if(result.containsKey(schedule.SBQQ__Subscription__r.SBQQ__Contract__c))
            {
                result.get(schedule.SBQQ__Subscription__r.SBQQ__Contract__c).addAll(schedule.SBQQ__SubscriptionConsumptionRates__r);
            }
            else
            {
                result.put(schedule.SBQQ__Subscription__r.SBQQ__Contract__c, schedule.SBQQ__SubscriptionConsumptionRates__r);
            }
        }

        return result;
    }

    public static Map<Id, List<SBQQ__Subscription__c>> getSubscriptionMap(List<Contract> contracts)
    {
        List<SBQQ__Subscription__c> subscriptions = 
        [
            SELECT  Id,
                    Name,
                    SBQQ__Contract__c,
                    SBQQ__Quantity__c,
                    SBQQ__Product__c,
                    SBQQ__Product__r.ProductCode,
                    SBQQ__Product__r.ExternalId,
                    SBQQ__Product__r.Name,
                    SBQQ__Product__r.Family,
                    SBQQ__ListPrice__c,                            
                    SBQQ__NetPrice__c,
                    TotalPrice__c,
                    SBQQ__StartDate__c,
                    Termination_Date__c,
                    CurrencyISOCode,
                    SBQQ__RevisedSubscription__c,
                    SBQQ__BundledQuantity__c,
                    (
                        SELECT  Id,
                                Name,
                                RebatePercent__c,
                                Subscription__c,
                                MigratedRebateProduct__c,
                                MigratedContract__c,
                                Quantity__c,
                                RebateAmount__c
                        FROM Rebates__r
                    )
                    // ,(
                    //     SELECT  Id,
                    //             SBQQ__Quantity__c,
                    //             SBQQ__NetPrice__c,
                    //             SBQQ__StartDate__c,
                    //             Termination_Date__c
                    //     FROM SBQQ__Revisions__r
                    // )
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Contract__c IN :contracts
        ];

        Map<Id, List<SBQQ__Subscription__c>> subscriptionMap = new Map<Id, List<SBQQ__Subscription__c>>();
        Map<Id, List<SBQQ__Subscription__c>> revisionMap = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> originalSubscriptions = new List<SBQQ__Subscription__c>();

        for(SBQQ__Subscription__c subscription: subscriptions)
        {
            if(subscription.SBQQ__RevisedSubscription__c == null)
            {
                if(subscriptionMap.containsKey(subscription.SBQQ__Contract__c))
                {
                    subscriptionMap.get(subscription.SBQQ__Contract__c).add(subscription);
                }
                else 
                {
                    subscriptionMap.put(subscription.SBQQ__Contract__c, new List<SBQQ__Subscription__c>{subscription});
                }

                originalSubscriptions.add(subscription);
            }
            else 
            {
                if(revisionMap.containsKey(subscription.SBQQ__RevisedSubscription__c))
                {
                    revisionMap.get(subscription.SBQQ__RevisedSubscription__c).add(subscription);
                }
                else 
                {
                    revisionMap.put(subscription.SBQQ__RevisedSubscription__c, new List<SBQQ__Subscription__c>{subscription});
                }
            }
        }

        if(!revisionMap.isEmpty())
        {
            List<SBQQ__Subscription__c> locallyUpdated = new List<SBQQ__Subscription__c>();

            for(SBQQ__Subscription__c originalSubscription: originalSubscriptions)
            {
                if(!revisionMap.containsKey(originalSubscription.Id))
                {
                    continue;
                }

                List<SBQQ__Subscription__c> revisions = revisionMap.get(originalSubscription.Id);

                for(SBQQ__Subscription__c revision: revisions)
                {
                    originalSubscription.SBQQ__Quantity__c = originalSubscription.SBQQ__Quantity__c + revision.SBQQ__Quantity__c;
                    //originalSubscription.SBQQ__NetPrice__c = originalSubscription.SBQQ__NetPrice__c + revision.SBQQ__NetPrice__c;
                }
                
                locallyUpdated.add(originalSubscription);
            }

            Formula.recalculateFormulas(locallyUpdated);
        }        

        return subscriptionMap;
    }

    public static Map<Id, List<SObject>> getRebatesMap(List<Contract> contracts)
    {
        List<Rebate__c> rebates =
        [
            SELECT  Id,
                    Name,
                    RebatePercent__c,
                    Subscription__c,
                    Subscription__r.SBQQ__Contract__c,
                    MigratedRebateProduct__c,
                    MigratedContract__c,
                    MigratedRebateProduct__r.ProductCode,
                    MigratedRebateProduct__r.ExternalId,
                    MigratedRebateProduct__r.Name,
                    Quantity__c,
                    RebateAmount__c,
                    StartDate__c,
                    EndDate__c
            FROM Rebate__c
            WHERE MigratedContract__c IN :contracts
        ];

        return UTIL_System.convertListToMap(rebates, Rebate__c.MigratedContract__c.getDescribe().getLocalName());
    }
}