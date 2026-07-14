/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The QuoteTerm model represents the quote term object in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quoteterm_model.htm
* Jira number:	PS-8	 
* 				
**/
public class QuoteTermModel {
	@InvocableVariable @AuraEnabled public String value;
    @InvocableVariable @AuraEnabled public String type;
    @InvocableVariable @AuraEnabled public Id standardTermId;
    @InvocableVariable @AuraEnabled public Id quoteId;
    @InvocableVariable @AuraEnabled public Boolean locked;
    @InvocableVariable @AuraEnabled public String label;
    @InvocableVariable @AuraEnabled public Id id;
}