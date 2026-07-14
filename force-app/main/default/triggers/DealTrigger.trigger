trigger DealTrigger on Deal__c (after insert, after update, after undelete) {
    FACTORY_TriggerHandler.createHandler(FACTORY_TriggerHandler.TriggerHandler.TH_DEAL);
}