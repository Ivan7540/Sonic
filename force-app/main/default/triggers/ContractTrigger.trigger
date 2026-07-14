trigger ContractTrigger on Contract (after insert, after update, after undelete) 
{
    FACTORY_TriggerHandler.createHandler(FACTORY_TriggerHandler.TriggerHandler.TH_CONTRACT);
}