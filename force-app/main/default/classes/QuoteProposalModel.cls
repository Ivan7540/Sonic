/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The QuoteProposal model represents a quote document in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quoteproposal_model.htm
* Jira number:	PS-8			 
* 				
**/
public class QuoteProposalModel {
	@InvocableVariable @AuraEnabled public String name;
    @InvocableVariable @AuraEnabled public Id quoteId;
    @InvocableVariable @AuraEnabled public Id templateId;
    @InvocableVariable @AuraEnabled public String language;
    @InvocableVariable @AuraEnabled public String outputFormat;
    @InvocableVariable @AuraEnabled public String paperSize;
}