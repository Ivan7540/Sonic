/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Configuration model represents a bundle product in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_config_model_6.htm
* 			 :	ConfigurationModel cannot be made invocable variable because of Set<Id> type of variables that are not compatible
* Jira number:	PS-8				
**/
public class ConfigurationModel {
	public Id configuredProductId; 
    public Id optionId; 
    public SBQQ__ProductOption__c optionData; // Editable data about the option in question, such as quantity or discount 
    public SBQQ__ProductOption__c configurationData; 
    public SBQQ__ProductOption__c inheritedConfigurationData; 
    public ConfigurationModel[] optionConfigurations; 
    public Boolean configured;
    public Boolean configurationEntered;
    public Boolean changedByProductActions; 
    public Boolean isDynamicOption; 
    public Boolean isUpgrade; 
    public Set<Id> disabledOptionIds; 
    public Set<Id> hiddenOptionIds; 
    public Decimal listPrice; 
    public Boolean priceEditable; 
    public String[] validationMessages; 
    public String dynamicOptionKey; 
}