/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The ConfigAttribute model represents the configuration attribute object in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_configattr_model_5.htm
* Jira number:	PS-8	 
* 				
**/
public class ConfigAttributeModel {
	@InvocableVariable @AuraEnabled public String name; 
    @InvocableVariable @AuraEnabled public String targetFieldName; 
    @InvocableVariable @AuraEnabled public Decimal displayOrder; 
    @InvocableVariable @AuraEnabled public String colmnOrder;
    @InvocableVariable @AuraEnabled public Boolean required;
    @InvocableVariable @AuraEnabled public Id featureId;
    @InvocableVariable @AuraEnabled public String position;
    @InvocableVariable @AuraEnabled public Boolean appliedImmediately;
    @InvocableVariable @AuraEnabled public Boolean applyToProductOptions;
    @InvocableVariable @AuraEnabled public Boolean autoSelect;
    @InvocableVariable @AuraEnabled public String[] shownValues;
    @InvocableVariable @AuraEnabled public String[] hiddenValues;
    @InvocableVariable @AuraEnabled public Boolean hidden;
    @InvocableVariable @AuraEnabled public String noSuchFieldName;
    @InvocableVariable @AuraEnabled public Id myId;
}