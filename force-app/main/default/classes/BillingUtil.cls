/*
Date created: 20/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-358
*/
global class BillingUtil 
{
    public static final String CONTRACT_NAME = Contract.SObjectType.getDescribe().getLocalName();
    public static final String DATE_PARAM = 'billingDate';
    public static final String OFFSET_PARAM = 'offset';
    public static final String LIMIT_PARAM = 'limit';
    public static final String PARAM_ERROR = 'Parameter "{0}" missing from the request URI';
    public static final String ACTIVE_STATUS = 'Activated';
    public static final String SUSPENDED_STATUS = 'Suspended';
    public static final String DEACTIVATED_STATUS = 'Deactivated';
    public static final String GIFT_LOYALTY_TYPE = 'Gift and Loyalty';
    public static final String CAPITEC_TYPE = 'Capitec Merchant Number';
    public static final String INSTALL_CODE = 'JSINSTALF';
    private static final String MERCHANT_KEY_TEMPLATE = '{0}{1}';
    public static final String FIELD_TYPE = Contract.ContractType__c.getDescribe().getLocalName();
    
    public static Date convertParameterToDate(String parameter)
    {
        Date billingDate;

        try 
        {
            billingDate = Date.parse(parameter.replaceAll('-', '/'));
        } 
        catch (TypeException ex) 
        {
            throw new BillingUtil.BillingException('Parameter passed cannot be parsed to a valid date');
        }

        return billingDate;
    }

    public static String managedParameterGet(Map<String, String> paramMap, String key)
    {
        String result = paramMap.get(key);

        if(result == null)
        {
            throw new BillingException(String.format(PARAM_ERROR, new String[]{key}));
        }

        return result;
    }

    public static List<Contract> getNonGiftContracts(Date billingDate, Integer offset, Integer limitParam)
    {
        Set<String> nonGiftTypes = UTIL_System.getPicklistEntriesMap(Contract.getSObjectType(), FIELD_TYPE).keySet();
        nonGiftTypes.remove(GIFT_LOYALTY_TYPE);
        return getBillingContracts(billingDate, nonGiftTypes, offset, limitParam);
    }

    public static List<Contract> getGiftContracts(Date billingDate, Integer offset, Integer limitParam)
    {
        return getBillingContracts(billingDate, new Set<String>{GIFT_LOYALTY_TYPE}, offset, limitParam);
    }

    public static List<BillingUtil.BillingContract> produceBillingContracts(List<Contract> contracts, Date billingDate)
    {
        List<BillingUtil.BillingContract> results = new List<BillingUtil.BillingContract>();
        Set<Id> rateContractIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();

        for(Contract contra: contracts)
        {
            accountIds.add(contra.AccountId);
            rateContractIds.add(contra.RateContract__c);

            if(contra.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Sub_Type__c == 'Acquiring Only' && contra.RateContract__c == null)
            {
                rateContractIds.add(contra.Id);
            }

            contractIds.add(contra.Id);
        }

        Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>> rateMap = getRateSubscriptionMap(rateContractIds, billingDate);
        Map<Id, List<SBQQ__Subscription__c>> subscriptionMap = getSubscriptionMap(contracts, billingDate);
        Map<Id, Set<MerchantId__c>> merchantIdMap = BillingUtil.getMerchantIdsMap(contractIds);
        Map<String, List<MerchantId__c>> migratedNumberMap = getMigratedMerchantIds(accountIds);
        Map<Id, List<OrderItem>> orderProductMap = getOnceOffs(contracts, billingDate);
        Map<Id, List<OrderItem>> initialOrderProductMap = getInitialOnceOffs(accountIds, billingDate);

        // List<SBQQ__Subscription__c> excluded = new List<SBQQ__Subscription__c>();
        // excluded.addAll(subscriptionMap.values());
        Map<Id, List<SObject>> rebateMap = BillingUtil.getRebatesMap(contracts, billingDate);

        for(Contract contr: contracts)
        {
            BillingUtil.BillingContract newBillingRecord = new BillingUtil.BillingContract();
            
            newBillingRecord.contractRecord = contr;
            newBillingRecord.rates = rateMap.get(contr.RateContract__c);

            if(contr.SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Sub_Type__c == 'Acquiring Only' && contr.RateContract__c == null)
            {
                newBillingRecord.rates = rateMap.get(contr.Id);
            }

            newBillingRecord.subscriptionRecords = subscriptionMap.get(contr.Id);
            newBillingRecord.legacyRebates = rebateMap.get(contr.Id);
            newBillingRecord.onceOffRecords = orderProductMap.get(contr.Id);

            if(initialOrderProductMap.containsKey(contr.AccountId))
            {
                if(newBillingRecord.onceOffRecords != null)
                {
                    newBillingRecord.onceOffRecords.addAll(initialOrderProductMap.get(contr.AccountId));
                }
                else
                {
                    newBillingRecord.onceOffRecords = initialOrderProductMap.get(contr.AccountId);
                }
            }

            newBillingRecord.merchantRecords = new List<MerchantId__c>(merchantIdMap.get(contr.Id));
            String key = String.format(MERCHANT_KEY_TEMPLATE, new String[]{contr.AccountId, contr.ContractType__c});

            if(migratedNumberMap.containsKey(key))
            {
                if(newBillingRecord.merchantRecords != null)
                {
                    newBillingRecord.merchantRecords.addAll(migratedNumberMap.get(key));
                }
                else
                {
                    newBillingRecord.merchantRecords = migratedNumberMap.get(key);
                }
            }            

            results.add(newBillingRecord);
        }

        return results;
    }  

    private static List<Contract> getBillingContracts(Date billingDate, Set<String> contractTypes, Integer offset, Integer limitParam)
    {
        return
        [
            SELECT 
                Id, 
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
                Account.ShippingState,
                RateContract__c,
                Contract_Type__c,
                ContractType__c,
                RootProductFamily__c,
                SBQQ__Order__c,
                SBQQ__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Sub_Type__c
            FROM Contract 
            WHERE (Status = :ACTIVE_STATUS OR Status = :SUSPENDED_STATUS OR 
            (Status = :DEACTIVATED_STATUS AND Cancellation_Effective_Date__c >= :billingDate.toStartOfMonth()))
            //AND Account.Channel__c = 'SME'
            AND ContractType__c IN :contractTypes
            AND InstallationDate__c <= :DateUtil.lastOfMonth(billingDate)
            AND ContractNumber__c > :offset
            ORDER BY ContractNumber__c ASC
            LIMIT :limitParam
        ];
    }
    
    public static Map<Id, List<SBQQ__Subscription__c>> getSubscriptionMap(List<Contract> contracts, Date billingDate)
    {        
        Date periodStartDate = billingDate.toStartOfMonth();
        Date periodEndDate = DateUtil.lastOfMonth(billingDate);
        
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
                        WHERE Status__c = 'Active'
                        AND StartDate__c <= :periodEndDate
                        AND EndDate__c >= :periodStartDate
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
            AND SBQQ__RevisedSubscription__c = null
            AND SBQQ__StartDate__c <= :periodEndDate
            AND Termination_Date__c >= :periodStartDate
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
                    // originalSubscription.SBQQ__NetPrice__c = originalSubscription.SBQQ__NetPrice__c + revision.SBQQ__NetPrice__c;
                }
                
                locallyUpdated.add(originalSubscription);
            }

            Formula.recalculateFormulas(locallyUpdated);
        }

        return subscriptionMap;
    }

    public static Map<Id, Set<MerchantId__c>> getMerchantIdsMap(Set<Id> contractIds)
    {
        Map<Id, Set<MerchantId__c>> result = new Map<Id, Set<MerchantId__c>>();

        List<AssetProvider__c> providers = 
        [
            SELECT  Id,
                    Asset__c,
                    Contract__c,
                    MerchantId__c,
                    MerchantId__r.Name,
            		MerchantId__r.Type__c,
                    MerchantId__r.Product_Family__c,
                    MerchantId__r.AcquiringBank__c,
                    MerchantId__r.Account__c
            FROM AssetProvider__c
            WHERE Contract__c IN :contractIds
            AND MerchantId__c != null
            AND MerchantId__r.Type__c != :CAPITEC_TYPE
        ];

        for(AssetProvider__c provider :providers)
        {
            MerchantId__c merchantNumber = new MerchantId__c();
            merchantNumber.Id = provider.MerchantId__c;
            merchantNumber.Name = provider.MerchantId__r.Name;
            merchantNumber.Type__c = provider.MerchantId__r.Type__c;
            merchantNumber.Product_Family__c = provider.MerchantId__r.Product_Family__c;
            merchantNumber.AcquiringBank__c = provider.MerchantId__r.AcquiringBank__c;
            merchantNumber.Account__c = provider.MerchantId__r.Account__c;

            if(result.containsKey(provider.Contract__c))
            {
                result.get(provider.Contract__c).add(merchantNumber);
            }
            else
            {
                result.put(provider.Contract__c, new Set<MerchantId__c>{merchantNumber});
            }
        }

        return result;
    }

    private static Map<String, List<MerchantId__c>> getMigratedMerchantIds(Set<Id> accountIds)
    {
        Map<String, List<MerchantId__c>> merchantNumMap = new Map<String, List<MerchantId__c>>();

        List<MerchantId__c> results =
        [
            SELECT  Id,
                    Name,
                    Type__c,
                    Product_Family__c,
                    AcquiringBank__c,
                    Account__c
            FROM MerchantId__c
            WHERE Account__c IN :accountIds
            AND Type__c != :CAPITEC_TYPE
        ];

        for(MerchantId__c merchantNum :results)
        {
            String key = String.format(MERCHANT_KEY_TEMPLATE, new String[]{merchantNum.Account__c, merchantNum.Product_Family__c});

            if(merchantNumMap.containsKey(key))
            {
                merchantNumMap.get(key).add(merchantNum);
            }
            else
            {
                merchantNumMap.put(key, new List<MerchantId__c>{merchantNum});
            }
        }

        return merchantNumMap;
    }

    private static Map<Id, List<OrderItem>> getOnceOffs(List<Contract> contracts, Date billingDate)
    {
        Date periodStartDate = billingDate.toStartOfMonth();
        Date periodEndDate = periodStartDate.addMonths(1);

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
                    Order.ActivatedDate,
                    Order.EffectiveDate,
                    Order.EndDate,
                    Order.InstallationDate__c,
                    ServiceDate,
                    CurrencyISOCode
            FROM OrderItem
            WHERE Order.SBQQ__Quote__r.SBQQ__MasterContract__c IN :contracts
            AND Product2.SBQQ__SubscriptionPricing__c = null
            AND Product2.ExternalId != :INSTALL_CODE
            AND Order.ActivatedDate >= :periodStartDate
            AND Order.ActivatedDate < :periodEndDate
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

    private static Map<Id, List<OrderItem>> getInitialOnceOffs(Set<Id> accountIds, Date billingDate)
    {
        Date periodStartDate = billingDate.toStartOfMonth();
        Date periodEndDate = periodStartDate.addMonths(1);

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
                    Order.ActivatedDate,
                    Order.EffectiveDate,
                    Order.EndDate,
                    Order.InstallationDate__c,
                    ServiceDate,
                    CurrencyISOCode,
                    Order.AccountId
            FROM OrderItem
            WHERE Order.AccountId IN :accountIds
            AND Product2.SBQQ__SubscriptionPricing__c = null
            AND Order.SBQQ__Quote__r.SBQQ__MasterContract__c = null
            AND Order.InstallationDate__c >= :periodStartDate
            AND Order.InstallationDate__c < :periodEndDate
        ];

        Map<Id, List<OrderItem>> accountItemMap = new Map<Id, List<OrderItem>>();

        for(OrderItem item :results)
        {
            Id accountId = item.Order.AccountId;

            if(accountItemMap.containsKey(accountId))
            {
                accountItemMap.get(accountId).add(item);
            }
            else
            {
                accountItemMap.put(accountId, new List<OrderItem>{item});
            }
        }

        return accountItemMap;
    }
    
    public static Map<Id, List<SObject>> getRebatesMap(List<Contract> contracts, Date billingDate)
    {
        Date periodStartDate = billingDate.toStartOfMonth();
        Date periodEndDate = DateUtil.lastOfMonth(billingDate);

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
                    RebateAmount__c
            FROM Rebate__c
            WHERE MigratedContract__c IN :contracts
            AND StartDate__c <= :periodEndDate
            AND EndDate__c >= :periodStartDate
        ];

        return UTIL_System.convertListToMap(rebates, Rebate__c.MigratedContract__c.getDescribe().getLocalName());
    }

    private static Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>> getRateSubscriptionMap(Set<Id> rateContractIds, Date billingDate)
    {
        Date periodStartDate = billingDate.toStartOfMonth();
        Date periodEndDate = DateUtil.lastOfMonth(billingDate);
        Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>> result = new Map<Id, List<SBQQ__SubscriptionConsumptionRate__c>>();
        Set<Id> revisedScheduleSubscriptionIds = new Set<Id>();

        List<SBQQ__SubscriptionConsumptionSchedule__c> schedules =
        [
            SELECT  Id,                     
                    SBQQ__Subscription__r.SBQQ__Product__r.Name,
                    SBQQ__Subscription__r.SBQQ__StartDate__c,
                    SBQQ__Subscription__r.Termination_Date__c,
                    SBQQ__Subscription__r.SBQQ__Contract__r.StartDate,
                    SBQQ__Subscription__r.SBQQ__Contract__r.EndDate,
                    SBQQ__Subscription__r.SBQQ__Contract__c,
                    SBQQ__Subscription__r.SBQQ__RevisedSubscription__c,
                    (
                        SELECT  Id,
                                Name,
                                SBQQ__Price__c,
                                SBQQ__SubscriptionConsumptionSchedule__c,
                                SBQQ__SubscriptionConsumptionSchedule__r.Name,
                                SBQQ__SubscriptionConsumptionSchedule__r.SBQQ__Subscription__r.SBQQ__Product__r.ExternalId,
                                CurrencyISOCode
                        FROM SBQQ__SubscriptionConsumptionRates__r
                    )
            FROM SBQQ__SubscriptionConsumptionSchedule__c                    
            WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN :rateContractIds
            AND SBQQ__Subscription__r.SBQQ__StartDate__c <= :periodEndDate
            AND SBQQ__Subscription__r.Termination_Date__c >= :periodStartDate
        ];

        for(SBQQ__SubscriptionConsumptionSchedule__c schedule :schedules)
        {
            if(schedule.SBQQ__Subscription__r.SBQQ__RevisedSubscription__c != null)
            {
                revisedScheduleSubscriptionIds.add(schedule.SBQQ__Subscription__r.SBQQ__RevisedSubscription__c);
            }
        }

        for(SBQQ__SubscriptionConsumptionSchedule__c schedule :schedules)
        {
            if(revisedScheduleSubscriptionIds.contains(schedule.SBQQ__Subscription__c))
            {
                continue;
            }

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
    
    global class BillingContract
    {
        public Contract contractRecord;
        public List<SBQQ__Subscription__c> subscriptionRecords;
        public List<MerchantId__c> merchantRecords;
        public List<OrderItem> onceOffRecords;
        public List<SBQQ__SubscriptionConsumptionRate__c> rates;
        public List<Rebate__c> legacyRebates;
    }
    
    global class BillingException extends Exception
    {
        
    }
}