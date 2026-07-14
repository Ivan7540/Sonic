/**
* Author	 :	Ajit Gopu
* Date		 :	11 Jan 2021
* Desc		 :	The Option model represents a product option data model in Salesforce CPQ.
* 			 :	https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_option_model_3.htm
* 			 :	OptionModel cannot be made invocable variable because of Set<Id> type of variables that are not compatible
* Jira number:	PS-8				
**/
public class OptionModel {
	public SBQQ__ProductOption__c record; 
    public Map<String,String> externalConfigurationData; 
    public Boolean configurable; 
    public Boolean configurationRequired; 
    public Boolean quantityEditable; 
    public Boolean priceEditable; 
    public Decimal productQuantityScale; 
    public Boolean priorOptionExists; 
    public Set<Id> dependentIds; 
    public Map<String,Set<Id>> controllingGroups; 
    public Map<String,Set<Id>> exclusionGroups; 
    public String reconfigureDimensionWarning; 
    public Boolean hasDimension; 
    public Boolean isUpgrade; 
    public String dynamicOptionKey; 
}