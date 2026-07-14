/*
Date created: 23/04/2021
Developer: Ivan Vrtacnik
JIRA number: PS-363
*/
public class StatusTrackingUtil 
{
    public static final String FIELD_VALUE_FIELD = PicklistValueAge__c.TrackedFieldValue__c.getDescribe().getLocalName();
    public static final String FIELD_TARGET_OBJECT = PicklistValueAge__c.TrackedObjectAPIName__c.getDescribe().getLocalName();
    public static final String OBJECT_NAME = PicklistValueAge__c.SObjectType.getDescribe().getLocalName();
    public static final String FIELD_TRACKED_FIELD = PicklistValueAge__c.TrackedFieldName__c.getDescribe().getLocalName();
    public static final String LAST_MODIFIED = 'LastModifiedDate';
    private static final String MULTI_REF_FIELD_ERROR = 'You have created two custom lookup fields for the same objects. This is redundant. Please remove one of the fields and adjust the custom metadata accordingly.';
    private static Map<String, List<StatusHistory__mdt>> StatusHistoryMap;

    /**
    * Queries custom metadata and arranges it in a map with the object name as the key.
    * */
    private static void populateStatusHistoryMap()
    {
        // As custom metadata cannot be created with code,
        // a fixed metadata record is needed for testing
        // purposes. To prevent this record from interfering
        // with production records, it is marked as a test record,
        // ignored outside of a testing context, while regular
        // records are ignored during testing.
        List<StatusHistory__mdt> metas =
        [
                SELECT  ObjectName__c,
                        FieldAPIName__c,
                        TrackingReferenceField__c,
                        TestingRecord__c,
                        TerminatingValue__c
                FROM StatusHistory__mdt
                WHERE TestingRecord__c = :Test.isRunningTest()
        ];

        StatusHistoryMap = new Map<String, List<StatusHistory__mdt>>();

        for (StatusHistory__mdt item : metas)
        {
            List<StatusHistory__mdt> value = StatusHistoryMap.get(item.ObjectName__c);

            if(value == null)
            {
                StatusHistoryMap.put(item.ObjectName__c, new List<StatusHistory__mdt>{item});
            }               
            else
            {
                value.add(item);
                StatusHistoryMap.put(item.ObjectName__c, value);
            }
        }
    }

    /**
    * Returns a list of custom metadata records specific for the object. API name of the
    * object is used as the argument
    * */
    public static List<StatusHistory__mdt> getStatusHistoryByObject(String objectName)
    {
        if(StatusHistoryMap == null)
        {
            populateStatusHistoryMap();
        }            

        return StatusHistoryMap.get(objectName);
    }

    private static Boolean validate(StatusHistory__mdt meta, String trackedObjectType)
    {
        Boolean res = true;
        // Field map variables used to reduce line length
        Map<String, Schema.SObjectField> targetFieldMap = UTIL_System.getObjectFieldMap(trackedObjectType);

        // If field API names are not correctly configured in the custom metadata, the code will not work properly
        if(!UTIL_System.validFieldName(OBJECT_NAME, meta.TrackingReferenceField__c))
        {
            System.debug(LoggingLevel.ERROR, 'Metadata is misconfigured. Check the Tracking Reference Field value.');
            res = false;
        }

        if(!UTIL_System.validFieldName(trackedObjectType, meta.FieldAPIName__c))
        {
            System.debug(LoggingLevel.ERROR, 'Metadata is misconfigured. Check the Field API Name value.');
            res = false;
        }

        // Tracking can only be done on Picklist fields
        if(targetFieldMap.get(meta.FieldAPIName__c).getDescribe().getType() != Schema.DisplayType.Picklist)
        {
            System.debug(LoggingLevel.ERROR, 'Metadata is misconfigured. Tracked field is not a Picklist.');
            res = false;
        }

        return res;
    }

    /**
    * Creates an individual Tracker record based on the passed custom metadata and the object the tracker is
    * meant to monitor
    * */
    private static PicklistValueAge__c createTrackerFromMeta (StatusHistory__mdt meta, SObject trackedObject, Boolean isActive)
    {
        PicklistValueAge__c tracker = new PicklistValueAge__c();
        String trackedValue = String.valueOf(trackedObject.get(meta.FieldAPIName__c));

        tracker.Name = composeTrackerName(meta, trackedValue, trackedObject);
        tracker.UpsertKey__c = composeTrackerKey(trackedObject.Id, meta, trackedValue);
        tracker.TrackedObjectAPIName__c = meta.ObjectName__c;
        tracker.TrackedFieldName__c = meta.FieldAPIName__c;
        tracker.Active__c = isActive;
        // Put and get methods are used as the field names are not known at compile time.
        // The field referencing the observed record can be a custom field, to enable
        // monitoring of custom objects, and the Tracker can monitor a custom field as well
        tracker.TimeStatusEntered__c = DateTime.valueOf(trackedObject.get(LAST_MODIFIED));
        tracker.put(meta.TrackingReferenceField__c, trackedObject.Id);
        tracker.put(FIELD_VALUE_FIELD, trackedValue);

        return tracker;
    }

    private static String composeTrackerName(StatusHistory__mdt meta, String trackedValue, SObject trackedObject)
    {
        String nameFormat = '{0} - {1}';
        String label = trackedObject.getSObjectType().getDescribe().fields.getMap().get(meta.FieldAPIName__c).getDescribe().getLabel();
        
        return String.format(nameFormat, new List<String>{label, trackedValue});
    }

    private static String composeTrackerKey(String trackedId, StatusHistory__mdt meta, String trackedValue)
    {
        return trackedId + meta.FieldAPIName__c + trackedValue;
    }

    /*
    @InvocableMethod
    public static void invokeUpdate(List<Id> objectId)
    {

    }
    */

    /**
    * Method invoked by triggers of monitored objects when they are updated. Triggers for custom objects need
    * to be created for the functionality to work for them.
    * */
    public static void updateTrackers(List<SObject> newList, Map<Id, SObject> oldMap)
    {
        if(newList == null || newList.isEmpty())
        {
            return;
        }            

        String objectTypeName = newList[0].getSObjectType().getDescribe().getName();
        List<StatusHistory__mdt> metaList = getStatusHistoryByObject(objectTypeName);

        for(Integer i = 0; i < metaList.size(); i++)
        {
            if(!validate(metaList[i], objectTypeName))
            {
                metaList.remove(i);
            }                
        }

        // If there is no valid custom metadata created for the object, no trackers should exist
        if(metaList == null)
        {
            return;
        }         

        List<PicklistValueAge__c> trackersToUpdate = new List<PicklistValueAge__c>();
        SObject oldRec;

        // Each monitored object can have multiple fields being tracked. Only if one of the
        // tracked fields has been changed should the associated Tracker record be updated
        for(SObject newRec: newList)
        {
            for(StatusHistory__mdt meta: metaList)
            {
                if(oldMap != null)
                {
                    oldRec = oldMap.get(newRec.Id);
                    Object oldValue = oldRec.get(meta.FieldAPIName__c);
                    Object newValue = newRec.get(meta.FieldAPIName__c);
                    
                    if(oldRec != null && newValue != oldValue)
                    {
                        Boolean startCounter;

                        if(meta.TerminatingValue__c == null)
                        {
                            startCounter = true;
                        }
                        else
                        {
                            Set<String> terminatingValues = new Set<String>(meta.TerminatingValue__c.split(';'));
                            startCounter = !terminatingValues.contains((String)newValue);
                        }
                        
                        trackersToUpdate.add(createTrackerFromMeta(meta, oldRec, false));                        
                        trackersToUpdate.add(createTrackerFromMeta(meta, newRec, startCounter));
                    }
                }
                else
                {
                    trackersToUpdate.add(createTrackerFromMeta(meta, newRec, true));
                }
            }
        }

        upsert trackersToUpdate UpsertKey__c;
    }

    /**
    * Method invoked by triggers of monitored objects when they are deleted. Triggers for custom objects need
    * to be created for the functionality to work for them.
    * */
    /*
    public static void deleteTrackers(List<SObject> oldList)
    {
        if(oldList == null || oldList.isEmpty())
        {
            return;
        }            

        String objectTypeName = oldList[0].getSObjectType().getDescribe().getName();
        List<StatusHistory__mdt> metaList = getStatusHistoryByObject(objectTypeName);

        // If there is no custom metadata created for the object, no trackers should exist
        if(metaList == null)
        {
            return;
        }            

        Set<String> refFieldNames = new Set<String>();

        for(StatusHistory__mdt meta: metaList)
        {
           refFieldNames.add(meta.TrackingReferenceField__c); 
        }            

        Set<Id> oldIds = UTIL_System.extractListIds(oldList);

        // Trackers for the same object will use the same lookup field to reference it
        List<PicklistValueAge__c> trackersToDelete = getTrackersByTargetIds(oldIds, new List<String>(refFieldNames));
        DAL_BaseObject.DeleteDBObjects(trackersToDelete);        
    }
    */

    /**
    * Returns a list of Tracker records based on target Ids and the reference field name passed in
    * */
    /*
    @testVisible
    private static List<PicklistValueAge__c> getTrackersByTargetIds(Set<Id> targetIds, List<String> targetRefFields)
    {
        // Querying of associated Tracker records is dynamic, as the field referencing the
        // monitored object is not know at compile time
        al.SoqlBuilder soqlB = new al.SoqlBuilder()
        .selectx(DAL_BaseObject.FIELD_ID)
        .selectx(FIELD_VALUE_FIELD)
        .selectx(FIELD_TRACKED_FIELD)
        .selectx(FIELD_TARGET_OBJECT)
        .fromx(OBJECT_NAME);

        List<Id> idList = new List<Id>(targetIds);
        al.SetCondition refField;

        if(targetRefFields.size() > 1)
        {
            System.debug(LoggingLevel.ERROR, MULTI_REF_FIELD_ERROR);
            al.OrCondition our = new al.OrCondition();

            for(String targetRefField: targetRefFields)
            {
                refField = createInField(targetRefField, idList);
                soqlB.selectx(targetRefField);
                our.add(refField);
            }

            soqlB.wherex(our);
        }
        else
        {
            refField = createInField(targetRefFields[0], idList);
            soqlB.selectx(targetRefFields[0]);
            soqlB.wherex(refField);
        }

        return Database.query(soqlB.toSoql());
    }
    

    private static al.SetCondition createInField(String fieldName, List<Id> idList)
    {
        al.SetCondition refField = new al.SetCondition();
        refField.field(fieldName);
        refField.inx(idList);

        return refField;
    }
    

    public static List<PicklistValueAge__c> getTrackersById(Set<Id> trackerIds)
    {
        return
        [
            SELECT  Id,
            TrackedObjectAPIName__c,
            TrackedFieldValue__c,
            TrackedFieldName__c
            FROM PicklistValueAge__c
            WHERE Id IN :trackerIds
        ];
    }
    */

    public static List<PicklistValueAge__c> getAll()
    {
        return
        [
            SELECT  Id,
            TrackedObjectAPIName__c,
            TrackedFieldValue__c,
            TrackedFieldName__c
            FROM PicklistValueAge__c
            LIMIT 10000
        ];
    }
}