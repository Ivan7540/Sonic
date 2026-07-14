/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Quote Line Group model represents a quote line group data model in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quotelinegroup_model_2.htm
* Jira number:	PS-8				 
* 				
**/
public class QuoteLineGroupModel {
	@InvocableVariable @AuraEnabled public SBQQ__QuoteLineGroup__c record;
    @InvocableVariable @AuraEnabled public Decimal netNonSegmentTotal;
    @InvocableVariable @AuraEnabled public Integer key;
}