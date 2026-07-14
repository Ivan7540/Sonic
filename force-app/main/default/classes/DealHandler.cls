/*
Date created: 05/11/2021
Developer: Connor Huglin
JIRA number: PS-1097
*/
public class DealHandler extends TH_BaseObject {
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