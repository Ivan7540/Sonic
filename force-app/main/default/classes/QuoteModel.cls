/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Quote model represents a CPQ quote data model in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quote_model_9.htm
* Jira number:	PS-8	
* 				
**/
public class QuoteModel {
	@InvocableVariable @AuraEnabled public SBQQ__Quote__c record;
    @InvocableVariable @AuraEnabled public QuoteLineModel[] lineItems;
    @InvocableVariable @AuraEnabled public QuoteLineGroupModel[] lineItemGroups;
    @InvocableVariable @AuraEnabled public Integer nextKey;
    @InvocableVariable @AuraEnabled public Boolean applyAdditionalDiscountLast;
    @InvocableVariable @AuraEnabled public Boolean applyPartnerDiscountFirst;
    @InvocableVariable @AuraEnabled public Boolean channelDiscountsOffList;
    @InvocableVariable @AuraEnabled public Decimal customerTotal;
    @InvocableVariable @AuraEnabled public Decimal netTotal;
    @InvocableVariable @AuraEnabled public Decimal netNonSegmentTotal;
}