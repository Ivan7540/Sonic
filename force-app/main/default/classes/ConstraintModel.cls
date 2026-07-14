/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Constraint model represents the option constraint object in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_constraint_model_7.htm
* Jira number:	PS-8				 
* 				
**/
public class ConstraintModel {
	@InvocableVariable @AuraEnabled public SBQQ__OptionConstraint__c record; 
    @InvocableVariable @AuraEnabled public Boolean priorOptionExists; 
}