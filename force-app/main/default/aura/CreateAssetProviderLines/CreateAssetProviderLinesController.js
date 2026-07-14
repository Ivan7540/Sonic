({
    doInit : function(cmp, event, helper) {
        helper.getData(cmp, event);
    },
    handleMIDChange : function(cmp, event, helper){
        var providerId = event.getSource().get("v.name");
        var merchantId = event.getSource().get("v.value");
        
        var assets = cmp.get("v.assetsData");
        
        for(var i in assets){
            for(var j in assets[i].assetProviders){
                if(assets[i].assetProviders[j].Id == providerId){
                    assets[i].assetProviders[j].MerchantId__c = merchantId;
                }
            }
        }
        cmp.set("v.assetsData", assets);
    },
    handleProviderChange : function(cmp, event, helper){
        
    },
    handleSaveClick : function(cmp, event, helper){
        helper.saveData(cmp, event, helper);
    },
    handleCancelClick : function(cmp, event, helper){
        helper.getData(cmp, event);
    }
})