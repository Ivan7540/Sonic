/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Feature model represents a product feature data model in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_feature_model_4.htm
* Jira number:	PS-8				 
* 				
**/
public class FeatureModel {
	@InvocableVariable @AuraEnabled public SBQQ__ProductFeature__c record; 
    @InvocableVariable @AuraEnabled public String instructionsText; 
    @InvocableVariable @AuraEnabled public Boolean containsUpgrades; 
}