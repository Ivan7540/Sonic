({
    doInit : function(cmp, event) {
        //Nothing to do
    },
    calculateStaticResourceName : function(cmp, event, fields){
        var resourceName = 'QM_' + fields.Product__c;
        resourceName += fields.Device__c;
        resourceName += fields.ContractTerm__c;
        if(fields.Device__c == "SS_SP_630"){
            if(!$A.util.isEmpty(fields.MasterpassQuantity__c) && fields.MasterpassQuantity__c > 0){
                resourceName += 'Masterpass';
            }
            if(!$A.util.isEmpty(fields.SwitchpayQuantity__c) && fields.SwitchpayQuantity__c > 0){
                resourceName += 'SwitchPay';
            }
        }
        if(fields.Product__c ==  "Lite"){
            if(!$A.util.isEmpty(fields.BluetoothPrinterQuantity__c) && fields.BluetoothPrinterQuantity__c > 0){
                resourceName += "Bluetooth";
            }
        }
        if(fields.Device__c == "SS_BT50" || fields.Device__c == "SS_HUMBLE_BT50"){
            if(!$A.util.isEmpty(fields.DeviceType__c)){
                resourceName += fields.DeviceType__c;
            }
        }
        if(fields.Product__c == "ClassicPlusWithPOS"){
            if(!$A.util.isEmpty(fields.PaymentServer__c)){
                resourceName += fields.PaymentServer__c;
            }
            if(!$A.util.isEmpty(fields.PEDQuantity__c) && fields.PEDQuantity__c > 0){
                resourceName += "PED";
            }
        }
        if(!$A.util.isEmpty(fields.VAS__c)){
            resourceName += fields.VAS__c;
        }
        if(!$A.util.isEmpty(fields.GiftLoyaltyPaymentType__c)){
            resourceName += fields.GiftLoyaltyPaymentType__c;
        }
        if(!$A.util.isEmpty(fields.CardDesignType__c)){
            resourceName += fields.CardDesignType__c;
        }
        if(!$A.util.isEmpty(fields.AdditionalBrandedCards__c) && fields.AdditionalBrandedCards__c > 0){
            resourceName += 'AddCards';
        }
        if(!$A.util.isEmpty(fields.AdditionalEnrolmentForms__c) && fields.AdditionalEnrolmentForms__c > 0){
            resourceName += 'AddForms';
        }
        if(fields.ContractTerm__c == "None"){
            cmp.set("v.saleType", "Outright Purchase");
        } else{
            cmp.set("v.saleType", "Rental");
        }
        if(fields.Product__c == "Humble"){
            cmp.set("v.thirdParty", "Humble");
        } else if (fields.Product__c == "GAAP"){
              cmp.set("v.thirdParty", "GAAP");
        }
        else{
            cmp.set("v.thirdParty", "");
        }
        if((fields.ContractTerm__c == "None") || (fields.Product__c == "Humble") || (fields.Product__c == "GAAP")){
            cmp.set("v.disableAdd", true);
        } else{
            cmp.set("v.disableAdd", false);
        }
        
        console.log("SR Name: " + resourceName);
        cmp.set("v.staticResourceName", resourceName);
    },
    setFieldParams : function(cmp, fieldName, fieldValue){
        switch(fieldName){
            case "Product__c":
                cmp.set("v.productName", fieldValue);
                break;
            case "Device__c":
                cmp.set("v.deviceName", fieldValue);
                break;
            case "PaymentServer__c":
                cmp.set("v.paymentServer", fieldValue);
                break;
            case "ContractTerm__c":
                cmp.set("v.contractTerm", fieldValue);
                break;
            case "LineDiscount__c":
                cmp.set("v.lineDiscount", fieldValue);
                break;
            case "LineDiscountAmount__c":
                cmp.set("v.lineDiscountAmount", fieldValue);
                break;
            case "VAS__c":
                cmp.set("v.selectedVAS", fieldValue);
                break;
        }
    }
})