/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Product model represents a product data model in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_product_model_8.htm
* Jira number:	PS-8 
* 				
**/
public class ProductModel {
	@InvocableVariable @AuraEnabled public Product2 record;
    @InvocableVariable @AuraEnabled public Id upgradedAssetId;
    @InvocableVariable @AuraEnabled public String currencySymbol;
    @InvocableVariable @AuraEnabled public String currencyCode;
    @InvocableVariable @AuraEnabled public String[] featureCategories;
    @InvocableVariable @AuraEnabled public OptionModel[] options;
    @InvocableVariable @AuraEnabled public FeatureModel[] features;
    @InvocableVariable @AuraEnabled public ConfigurationModel configuration;
    @InvocableVariable @AuraEnabled public ConfigAttributeModel[] configurationAttributes;
    @InvocableVariable @AuraEnabled public ConfigAttributeModel[] inheritedConfigurationAttributes;
    @InvocableVariable @AuraEnabled public ConstraintModel[] constraints;
}