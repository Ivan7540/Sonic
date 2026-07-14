/*
Date created: 23/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-363
*/
public class WorkOrderHandler extends TH_BaseObject
{
    List<WorkOrder__c> newWorkOrders= Trigger.new;

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

    public override void bulkBefore(){
        if(! trigger.isInsert)
        {
            return;
        }
        Id defaultHoursId = DAL_BusinessHours.getDefaultHours().Id;
        for(WorkOrder__c newRecord :newWorkOrders)
        {
            newRecord.InstallationTAT__c = calculateTAT(newRecord.ProductFamily__c, defaultHoursId);
        }
    }

    @TestVisible
    private Date calculateTAT(String productFamily, Id defaultHours){
        Integer days = 2;
        Datetime currentDate = Datetime.now();
        if(productFamily == DAL_Product.PRODUCT_FAMILY_INTEGRATED)
            days =12;

        Integer hoursToAdd = 8;
        Long difference = 1000 * 60 * 60 * days*hoursToAdd;
        Datetime tatTime = BusinessHours.add(defaultHours, currentDate, difference);
        return Date.newInstance(tatTime.year(), tatTime.month(), tatTime.day());
    }
}