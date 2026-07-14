/*
Date created: 20/05/2021
Developer: Ajit Gopu
JIRA number: PS-57
*/
public class SwitchPayCalloutInvocable 
{
	@InvocableMethod(label='Call SwitchPay' category='Asset')
    public static void switchPayInvocable(List<Id> switchPayId)
    {
        if(switchPayId.size() != 1)
        {
            return;
        }

        List<AssetProvider__c> providers = SwitchPayCallout.getAssetProvidersByAsset(switchPayId[0], null);
        
        if(providers.isEmpty())
        {
            return;
        }
        
        Account account = providers[0].Account__r;
        List<AccountContactRelation> contactList = SwitchPayCallout.getRelations(account.Id);
        List<OpportunityLineItem> oppProducts = SwitchPayCallout.getOpportunityProducts(providers[0].Asset__r.RelatedOpportunity__c);

        for(OpportunityLineItem opProd :oppProducts)
        {
            if(opProd.ProductCode == DAL_Product.MORETYME_NET || opProd.ProductCode == DAL_Product.MORETYME_GROSS)
            {
                SwitchPayCallout.isTymeValidStore(account, contactList);         
                break;
            }
        }        

        SwitchPayCallout.flowgearMerchantCreation(switchPayId[0]);
    }    
}