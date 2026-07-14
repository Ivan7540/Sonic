trigger WorkOrderTrigger on WorkOrder__c (after insert, after update, after undelete, before insert)
{
    FACTORY_TriggerHandler.createHandler(FACTORY_TriggerHandler.TriggerHandler.TH_WORKORDER);
}