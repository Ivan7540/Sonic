trigger LeadTrigger on Lead (before update, after insert, after update, after undelete) 
{
    FACTORY_TriggerHandler.createHandler(FACTORY_TriggerHandler.TriggerHandler.TH_LEAD);
}