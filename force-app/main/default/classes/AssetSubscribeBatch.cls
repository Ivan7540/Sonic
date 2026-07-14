global class AssetSubscribeBatch implements Database.Stateful, Database.Batchable<SObject>
{
    private Set<Id> exceptionAssetsIds;
    global final String DEVICE_CODE;
    global final String RENTAL_CODE;

    global AssetSubscribeBatch(String deviceCode, String rentCode)
    {
        this.exceptionAssetsIds = new Set<Id>();
        this.DEVICE_CODE = deviceCode;
        this.RENTAL_CODE = rentCode;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id, AccountId, Product2.RelatedRentalProduct__r.ProductCode FROM Asset WHERE SBQQ__RequiredBySubscription__c = null AND Product2.ProductCode = :DEVICE_CODE AND Id NOT IN :exceptionAssetsIds AND Status IN (\'Installed\', \'Linked\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Asset> assets)
    {
        Map<Id, Double> totalSubscriptionPerAccount = new Map<Id, Double>();
        Map<Id, List<SBQQ__Subscription__c>> accountSubscriptionMap = new Map<Id, List<SBQQ__Subscription__c>>();
        Map<Id, List<Asset>> assetMap = UTIL_System.convertListToMap(assets, Asset.AccountId.getDescribe().getLocalName());

        List<SBQQ__Subscription__c> subscriptions = getAccountSubscriptions(assetMap.keySet());

        for(SBQQ__Subscription__c sub :subscriptions)
        {
            if(accountSubscriptionMap.containsKey(sub.SBQQ__Account__c))
            {
                accountSubscriptionMap.get(sub.SBQQ__Account__c).add(sub);
                totalSubscriptionPerAccount.put(sub.SBQQ__Account__c, totalSubscriptionPerAccount.get(sub.SBQQ__Account__c) + sub.SBQQ__Quantity__c);
            }
            else
            {
                accountSubscriptionMap.put(sub.SBQQ__Account__c, new List<SBQQ__Subscription__c>{sub});
                totalSubscriptionPerAccount.put(sub.SBQQ__Account__c, sub.SBQQ__Quantity__c);
            }
        }

        List<Asset> toUpdate =  new List<Asset>(); 

        for(Id accountId :assetMap.keySet())
        {
            Integer subscriptionTotal = (Integer)totalSubscriptionPerAccount.get(accountId);
            List<Asset> accountAssets = assetMap.get(accountId);

            if(accountAssets.size() != subscriptionTotal)
            {
                processExceptions(accountAssets);
            }
            else
            {
                toUpdate.addAll(processNonExceptions(assetMap.get(accountId), accountSubscriptionMap.get(accountId)));
            }
        }
        
        Database.update(toUpdate, false);
    }

    global void finish(Database.BatchableContext bc) 
    {
        
    }

    private void processExceptions(List<Asset> exceptionAssets)
    {
        for(Asset a :exceptionAssets)
        {
            exceptionAssetsIds.add(a.Id);
        }
    }

    private List<Asset> processNonExceptions(List<Asset> accountAssets, List<SBQQ__Subscription__c> subscriptions)
    {
        List<Asset> subscribedAssets = new List<Asset>();        
        Integer assetCounter = 0;

        for(SBQQ__Subscription__c sub :subscriptions)
        {
            // Before while loop starts, quantity counter is reset for the current Subscription
            Integer assignedQuantity = 0;

            // 'While' loop assigns Assets until it has assigned as many as the Subscriptions quantity requires
            while (assignedQuantity < sub.SBQQ__Quantity__c && assetCounter < accountAssets.size()) 
            {
                // fetch next Asset
                Asset next = accountAssets[assetCounter];
                // Assign Asset to current Subscription
                next.SBQQ__RequiredBySubscription__c = sub.Id;
                // Add Asset to updated list
                subscribedAssets.add(next);
                // Increase counter to fetch another Asset in next 'while' loop iteration
                assetCounter++;
                // Track the number of assigned Assets
                assignedQuantity++;
            }
        }

        return subscribedAssets;
    }

    private List<SBQQ__Subscription__c> getAccountSubscriptions(Set<Id> accountIds)
    {
        return
        [
            SELECT  Id,
                    SBQQ__Account__c,
                    SBQQ__Quantity__c,
                    SBQQ__Product__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Account__c IN :accountIds
            AND SBQQ__Product__r.ProductCode = :RENTAL_CODE
            AND SBQQ__StartDate__c <= TODAY
            AND (Termination_Date__c >= TODAY OR Termination_Date__c = null)
            ORDER BY SBQQ__Quantity__c DESC
        ];
    }
}