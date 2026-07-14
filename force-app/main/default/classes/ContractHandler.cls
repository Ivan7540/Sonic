/*
Date created: 12/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-481
*/
public class ContractHandler extends TH_BaseObject
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
    }
}