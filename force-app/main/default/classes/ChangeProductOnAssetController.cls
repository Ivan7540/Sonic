public class ChangeProductOnAssetController {	    
    @AuraEnabled
    public static List<Product2> getSelectableProducts(String productFamily){
        system.debug('PRODUCT FAMILY: ' + productFamily);
        
		List<Product2> productBundles = [SELECT Id FROM Product2 WHERE Family =: productFamily];
        Set<Id> bundleIdLs = new Set<Id>();
        
        for(Product2 bundleProduct : productBundles){
            bundleIdLs.add(bundleProduct.Id);
        }
        
        List<SBQQ__ProductOption__c> productOptions = [SELECT Id, RelatedRentalProduct__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c IN :bundleIdLs AND FeatureName__c = 'Device'];
        Set<Id> rentalproductIdLs = new Set<Id>();
        
        for(SBQQ__ProductOption__c pOption: productOptions){
            rentalproductIdLs.add(pOption.SBQQ__OptionalSKU__c);
        }
        
        List<Product2> selectableProducts = [SELECT Id, Name, RelatedRentalProduct__c FROM Product2 WHERE RelatedRentalProduct__c IN: rentalproductIdLs];
        system.debug('selectableProducts: ' + selectableProducts);
        
        return selectableProducts;
    }
}