/*
Date created: 19/01/2021
Developer: Ivan Vrtacnik
JIRA number: PS-33
*/
public class LeadHandler extends TH_BaseObject
{
    List<Lead> newLeads = Trigger.new;
    Map<Id, SObject> oldRecordMap = Trigger.oldMap;

    public override void bulkBefore()
    {
        if(!Trigger.isUpdate)
        {
            return;
        }
        
        Id defaultHoursId = DAL_BusinessHours.getDefaultHours().Id;
        Map<String, Lead_Escalation_Time__mdt> escalationMap = getEscalationTimeMap();

        for(Lead newRecord :newLeads)
        {
            Lead oldRecord = (Lead)oldRecordMap.get(newRecord.Id);

            if(newRecord.Status == DAL_Lead.STATUS_WORKING && newRecord.Status != oldRecord.Status)
            {
                Lead_Escalation_Time__mdt escalation = escalationMap.get(newRecord.LeadSource);

                if(escalation != null)
                {
                    Long escalationTime = (Long)escalation.Time_Hours__c * 3600000;
                    newRecord.Escalation_Time__c = BusinessHours.add(defaultHoursId, Datetime.now(), escalationTime);
                }                
            }
        }
    }

    public override void bulkAfter()
    {
        if(trigger.isUpdate || trigger.isInsert || trigger.isUndelete)
        {
            StatusTrackingUtil.updateTrackers(trigger.new, trigger.oldMap);
        }
    }

    private Map<String, Lead_Escalation_Time__mdt> getEscalationTimeMap()
    {
        List<Lead_Escalation_Time__mdt> metaRecords = 
        [
            SELECT  DeveloperName,
                    Label, 
                    Time_Hours__c 
            FROM Lead_Escalation_Time__mdt
        ];

        Map<String, Lead_Escalation_Time__mdt> sourceEscalationMap = new Map<String, Lead_Escalation_Time__mdt>();

        for(Lead_Escalation_Time__mdt item : metaRecords)
        {
            sourceEscalationMap.put(item.Label, item);
        }

        return sourceEscalationMap;
    }
}