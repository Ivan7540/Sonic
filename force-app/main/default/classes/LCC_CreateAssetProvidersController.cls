public class LCC_CreateAssetProvidersController {
    public class AssetData{
        @AuraEnabled public Asset thisAsset;
        //@AuraEnabled public List<Terminal__c> terminals;
        @AuraEnabled public List<MerchantId__c> merchantIds;
        @AuraEnabled public List<AssetProvider__c> assetProviders;
        @AuraEnabled public List<comboOption> options;
        @AuraEnabled public String validationMessage;
    }
    
    public class comboOption{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
    @AuraEnabled
    public static string saveTerminals(String assetsDataString){
        system.debug('String: ' + assetsDataString);
        List<AssetData> assetsData = (List<AssetData>)JSON.deserialize(assetsDataString, List<AssetData>.class);
        List<AssetProvider__c> providersToUpdate = new List<AssetProvider__c>();
        
        Set<Id> terminalIds = new Set<Id>();
        
        for(AssetData eachData : assetsData){
            system.debug('Providers: ' + assetsData);
            providersToUpdate.addAll(eachData.assetProviders);
            for(AssetProvider__c eachProvider : eachData.assetProviders){
                terminalIds.add(eachProvider.Terminal__c);
            }
        }
        List<Terminal__c> terminals = [Select Id,
                                       Name,
                                       TerminalNumber__c
                                       From Terminal__c
                                       where Id in :terminalIds
                                       And Status__c = 'In Progress'];
        
        for(Terminal__c eachTerminal : terminals){
            eachTerminal.TerminalNumber__c = eachTerminal.TerminalNumber__c.left(3) + eachTerminal.Name;
            eachTerminal.Status__c = 'Active';
        }
        try{
            update providersToUpdate;
            update terminals;
            return 'Success';
        }catch(Exception e){
            return e.getMessage(); 
        }
    }
    
    @AuraEnabled
    public static List<AssetData> createTerminalIds(Id workOrderId){
        WorkOrder__c thisWO = [Select Id,
                               Order__c,
                               Account__c 
                               From WorkOrder__c
                               Where Id = :workOrderId];
        
        List<AssetData> assetData = new List<AssetData>();
        Map<String, List<MerchantId__c>> merchantIdsByFamilyMap = new Map<String, List<MerchantId__c>>();
        
        List<MerchantId__c> merchantIds = [Select Id,
                                           AcquiringBank__c,
                                           Name,
                                           Product_Family__c,
                                           Type__c
                                           From MerchantId__c
                                           Where Account__c = :thisWO.Account__c AND Active__c = true];
        
        //Create map of Merchant Ids based on family
        for(MerchantId__c eachMerchantId : merchantIds){
            if(merchantIdsByFamilyMap.containsKey(eachMerchantId.Product_Family__c)){
                merchantIdsByFamilyMap.get(eachMerchantId.Product_Family__c).add(eachMerchantId);
            }else{
                merchantIdsByFamilyMap.put(eachMerchantId.Product_Family__c, new List<MerchantId__c>{eachMerchantId});
            }
        }
        
        List<WorkOrderLineItem__c> orderItems = 
        [
            Select Id, 
            WorkOrder__c,
            WorkOrder__r.Order__c,
            WorkOrder__r.Account__c,
            Asset__r.Product2.Name,
            Asset__r.Product2.Family,
            Asset__r.Product2.Prefix__c,
            Asset__r.Product2.ProductCode,
            Asset__r.SerialNumber,
            Asset__r.Name,
            Asset__c,
            Asset__r.SBQQ__RootId__c,
            Asset__r.SBQQ__RequiredById__c,
            Asset__r.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RootProductFamily__c
            From WorkOrderLineItem__c
            Where WorkOrder__c = :thisWO.Id
            And Asset__r.Product2.NeedsTerminalId__c = true];
        
        Set<Id> assetsThatNeedMasterpassOrSwitchpay = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        for(WorkOrderLineItem__c item : orderItems){
            List<Asset> itemAssets = new List<Asset>();
            if(item.Asset__r.Product2.ProductCode == DAL_Product.masterpassRentalPC || item.Asset__r.Product2.ProductCode == DAL_Product.switchpayRentalPC){
                for(WorkOrderLineItem__c MPitem : orderItems){
                    if(MPitem.Asset__c == item.Asset__r.SBQQ__RequiredById__c){
                        assetsThatNeedMasterpassOrSwitchpay.add(MPitem.Asset__c);
                    }
                }
            }

            assetIds.add(item.Asset__c);
        }
        
        Map<Id, List<AssetProvider__c>> assetProvidersMap = new Map<Id, List<AssetProvider__c>>();
        List<AssetProvider__c> assetProviders = 
            [
                Select Id,
                Account__c,
                Asset__c,
                Name,
                MerchantId__c,
                Service__c,
                Terminal__c,
                Terminal__r.Id,
                Terminal__r.Provider__c,
                Terminal__r.Status__c,
                Terminal__r.Account__c,
                Terminal__r.TerminalNumber__c
                From AssetProvider__c
                Where Asset__c = :assetIds
                And Terminal__r.Status__c != 'Inactive'
            ];
        
        for(AssetProvider__c eachAssetProvider : assetProviders){
            if(assetProvidersMap.containsKey(eachAssetProvider.Asset__c)){
                assetProvidersMap.get(eachAssetProvider.Asset__c).add(eachAssetProvider);
            }else{
                assetProvidersMap.put(eachAssetProvider.Asset__c, new List<AssetProvider__c>{eachAssetProvider});
            }
        }
        
        List<Terminal__c> newTerminals = new List<Terminal__c>();
        for(WorkOrderLineItem__c thisItem : orderItems){
            AssetData thisAssetData = new AssetData();
            //thisAssetData.terminals = new List<Terminal__c>();
            thisAssetData.merchantIds = new List<MerchantId__c>();
            //only one device asset per order line(based on product structre)
            thisAssetData.thisAsset = new Asset(Id = thisItem.Asset__c,
                                                SerialNumber = thisItem.Asset__r.SerialNumber,
                                                Name = thisItem.Asset__r.Name);
            thisAssetData.assetProviders = new List<AssetProvider__c>();
            if(assetProvidersMap.containsKey(thisAssetData.thisAsset.Id)){
                thisAssetData.assetProviders = assetProvidersMap.get(thisAssetData.thisAsset.Id);
                
                if(assetsThatNeedMasterpassOrSwitchpay.contains(thisAssetData.thisAsset.Id)){
                    Boolean masterpassNeeded = true;
                    for(AssetProvider__c assetProvider : thisAssetData.assetProviders){
                        if(assetProvider.Service__c == 'Switch Pay'){
                            masterpassNeeded = false;
                        }
                    }
                    if(masterpassNeeded){
                        AssetProvider__c newAssetProvider = new AssetProvider__c(Account__c = thisItem.WorkOrder__r.Account__c, Asset__c = thisAssetData.thisAsset.Id, Name = 'Masterpass',Service__c = 'Switch Pay', Terminal__c = thisAssetData.assetProviders[0].Terminal__c, Terminal__r = thisAssetData.assetProviders[0].Terminal__r);
                        insert newAssetProvider;
                        thisAssetData.assetProviders.add(newAssetProvider);
                    }
                }
                
            }else{
                //create terminal asset provider
                Terminal__c newTerminal = new Terminal__c();
                newTerminal.Provider__c = thisItem.Asset__r.Product2.ProductCode == DAL_Product.sp630PC? 'Innervation':'ACS';
                newTerminal.Status__c = 'In Progress';
                newTerminal.Account__c = thisItem.WorkOrder__r.Account__c;
                newTerminal.TerminalNumber__c = thisItem.Asset__r.Product2.Prefix__c + 'xxxxx';
                insert newTerminal;
                newTerminals.add(newTerminal);
                if(assetsThatNeedMasterpassOrSwitchpay.contains(thisItem.Asset__c)){
                    // create another asset provider 
                    AssetProvider__c newAssetProvider = new AssetProvider__c(Account__c = thisItem.WorkOrder__r.Account__c,Asset__c = thisItem.Asset__c, Name = 'Masterpass', MerchantId__c = null, Service__c = 'Switch Pay', Terminal__c = newTerminal.Id, Terminal__r = newTerminal);
                    insert newAssetProvider;
                    thisAssetData.assetProviders.add(newAssetProvider);
                }
                AssetProvider__c newAssetProvider = new AssetProvider__c();
                newAssetProvider.Account__c = thisItem.WorkOrder__r.Account__c;
                newAssetProvider.Asset__c = thisItem.Asset__c;
                newAssetProvider.Name = thisItem.Asset__r.Product2.Name;
                newAssetProvider.MerchantId__c = null;
                newAssetProvider.Service__c = 'Sureswipe Acquiring';
                newAssetProvider.Terminal__c = newTerminal.Id;
                newAssetProvider.Terminal__r = newTerminal;
                insert newAssetProvider;
                thisAssetData.assetProviders.add(newAssetProvider);
            }
            if(merchantIdsByFamilyMap.containsKey(thisItem.Asset__r.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RootProductFamily__c)){
                thisAssetData.merchantIds = merchantIdsByFamilyMap.get(thisItem.Asset__r.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RootProductFamily__c);
                thisAssetData.options = new List<comboOption>();
                for(MerchantId__c eachMerchantId : thisAssetData.merchantIds){
                    comboOption thisOption = new comboOption();
                    thisOption.label = String.isBlank(eachMerchantId.Type__c)?eachMerchantId.Name: eachMerchantId.Name; //Removed Type
                    thisOption.value = eachMerchantId.Id;
                    thisAssetData.options.add(thisOption);
                }
            }else{
                thisAssetData.merchantIds = new List<MerchantId__c>();
                thisAssetData.validationMessage = 'No Merchant IDs found!';
            }
            assetData.add(thisAssetData);
        }
        return assetData;
    }
    
}