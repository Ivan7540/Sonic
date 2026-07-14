/*
Date created: 12/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-485
*/
public class OpportunityHandler extends TH_BaseObject
{
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public override void bulkAfter()
    {
        if(trigger.isUpdate || trigger.isInsert || trigger.isUndelete)
        {
            StatusTrackingUtil.updateTrackers(trigger.new, trigger.oldMap);
        }

        if(trigger.isUpdate || trigger.isInsert)
        {
            List<Id> oppIdLst = new List<Id>();
            Map<Id, String> oppDocStatusMap = new Map<Id, String>();
            Map<Id, String> oppStatusMap = new Map<Id, String>();
            
            for(Opportunity opp : (List<Opportunity>)trigger.new)
            {
                Opportunity oldRecord;

                if(trigger.isUpdate)
                {
                    oldRecord = (Opportunity)trigger.oldMap.get(opp.Id);
                }
                
                if(oldRecord == null || opp.DocumentCheckStatus__c != oldRecord.DocumentCheckStatus__c)
                {
                    oppDocStatusMap.put(opp.Id,opp.DocumentCheckStatus__c);
                }
    
                if(oldRecord == null || opp.StageName != oldRecord.StageName)
                {
                    oppStatusMap.put(opp.Id,opp.StageName);
                }
            }
    
            if((oppDocStatusMap.size() > 0) || (oppStatusMap.size() > 0))
            {
                updateDeals(oppDocStatusMap, oppStatusMap);
            }
        }        
    }

    private static void updateDeals(Map<Id, String> oppDocStatusMap, Map<Id, String> oppStatusMap)
    {
        Set<Id> dealIds = new Set<Id>();
        dealIds.addAll(oppDocStatusMap.keySet());
        dealIds.addAll(oppStatusMap.keySet());
        List<Deal__c> dealLst =[SELECT Id, Status__c, DocumentCheck__c, Opportunity__c FROM Deal__c WHERE Opportunity__c IN :dealIds];
        
        if(dealLst.size() > 0)
        {
            for(Deal__c dLst : dealLst)
            {
                if(oppDocStatusMap.containsKey(dLst.Opportunity__c))
                {
                    dLst.DocumentCheck__c = oppDocStatusMap.get(dLst.Opportunity__c);
                }

                if(oppStatusmap.containsKey(dLst.Opportunity__c))
                {
                    dLst.Status__c = oppStatusMap.get(dLst.Opportunity__c);
                } 
            }

            update dealLst;
        }
    }
}