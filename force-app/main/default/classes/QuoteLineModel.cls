/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Quote Line model represents a quote line data model in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quoteline_model_1.htm
* Jira number:	PS-8				
* 				
**/

public class QuoteLineModel {
	@InvocableVariable @AuraEnabled public SBQQ__QuoteLine__c record;
    @InvocableVariable @AuraEnabled public Boolean amountDiscountProrated;
    @InvocableVariable @AuraEnabled public Integer parentGroupKey;
    @InvocableVariable @AuraEnabled public Integer parentItemKey;
    @InvocableVariable @AuraEnabled public Integer key;
    @InvocableVariable @AuraEnabled public Boolean upliftable;
    @InvocableVariable @AuraEnabled public String configurationType;
    @InvocableVariable @AuraEnabled public String configurationEvent;
    @InvocableVariable @AuraEnabled public Boolean reconfigurationDisabled;
    @InvocableVariable @AuraEnabled public Boolean descriptionLocked;
    @InvocableVariable @AuraEnabled public Boolean productQuantityEditable;
    @InvocableVariable @AuraEnabled public Decimal productQuantityScale;
    @InvocableVariable @AuraEnabled public String dimensionType;
    @InvocableVariable @AuraEnabled public Boolean productHasDimensions;
    @InvocableVariable @AuraEnabled public Decimal targetCustomerAmount;
    @InvocableVariable @AuraEnabled public Decimal targetCustomerTotal;
}