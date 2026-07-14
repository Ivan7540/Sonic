@isTest
public class WorkOrderConfigurationTest 
{
    private static String WORKORDERSTAGE_NAME = WorkOrderStage__mdt.getSObjectType().getDescribe().getLocalName();
    private static String PRODUCT_NAME = Product2.getSObjectType().getDescribe().getLocalName();
    private static String WORKORDER_NAME = WorkOrder__c.getSObjectType().getDescribe().getLocalName();
    private static String ACTION_NAME = WorkOrderAction__c.getSObjectType().getDescribe().getLocalName();
    private static String ACTIONTEMPLATE_NAME = ActionTemplate__mdt.getSObjectType().getDescribe().getLocalName();

    @isTest
    static void productPicklist()
    {
        comparePicklist(WORKORDERSTAGE_NAME, WorkOrderStage__mdt.Product__c.getDescribe().getLocalName(),
        PRODUCT_NAME, Product2.Family.getDescribe().getLocalName());        
    }

    @isTest
    static void statusPicklist()
    {
        comparePicklist(WORKORDERSTAGE_NAME, WorkOrderStage__mdt.Work_Order_Status__c.getDescribe().getLocalName(),
        WORKORDER_NAME, WorkOrder__c.Status__c.getDescribe().getLocalName());        
    }

    @isTest
    static void recordTypePicklist()
    {
        Schema.DescribeFieldResult stageField = UTIL_System.getFieldDescribe(WORKORDERSTAGE_NAME, WorkOrderStage__mdt.Work_Order_Record_Type__c.getDescribe().getLocalName());
        List<PicklistEntry> stageEntries = stageField.getPicklistValues();
        List<RecordType> workorderRecordTypes = getWorkOrderRecordtypes();
        
        System.assertEquals(workorderRecordTypes.size(), stageEntries.size(), 'Picklist size mismatched with number of recordTypes');

        Set<String> stageValueSet = new Set<String>();

        for(PicklistEntry ple: stageEntries)
        {
            stageValueSet.add(ple.getValue());
        }

        for(RecordType rt: workorderRecordTypes)
        {
            System.assert(stageValueSet.contains(rt.DeveloperName), 'Picklist missing value ' + rt.DeveloperName);
        }
    }

    @isTest
    static void actionPicklist()
    {
        comparePicklist(ACTIONTEMPLATE_NAME, ActionTemplate__mdt.CompletionAction__c.getDescribe().getLocalName(),
        ACTION_NAME, WorkOrderAction__c.CompletionAction__c.getDescribe().getLocalName());        
    }

    @isTest
    static void actionStatusPicklist()
    {
        comparePicklist(ACTIONTEMPLATE_NAME, ActionTemplate__mdt.NewStatus__c.getDescribe().getLocalName(),
        ACTION_NAME, WorkOrderAction__c.NewStatus__c.getDescribe().getLocalName());        
    }

    @isTest
    static void actionWorkorderStatusPicklist()
    {
        comparePicklist(ACTION_NAME, WorkOrderAction__c.NewStatus__c.getDescribe().getLocalName(),
        WORKORDER_NAME, WorkOrder__c.Status__c.getDescribe().getLocalName());        
    }

    private static List<RecordType> getWorkOrderRecordtypes()
    {
        return 
        [
            SELECT  Id, 
                    Name, 
                    DeveloperName
            FROM RecordType
            WHERE SobjectType = :WORKORDER_NAME
        ];
    }

    public static void comparePicklist(String object1Name, String field1Name, String object2Name, String field2Name)
    {
        String errorTemplate = '{0} Not replicated in {1}';

        Schema.DescribeFieldResult object1Describe = UTIL_System.getFieldDescribe(object1Name, field1Name);
        Schema.DescribeFieldResult object2Describe = UTIL_System.getFieldDescribe(object2Name, field2Name);

        List<PicklistEntry> object1Values = object1Describe.getPicklistValues();
        List<PicklistEntry> object2Values = object2Describe.getPicklistValues();

        System.assertEquals(object1Values.size(), object2Values.size(), 'Picklist sizes mismatched');

        Set<String> object1ValueSet = new Set<String>();

        for(PicklistEntry ple: object1Values)
        {
            object1ValueSet.add(ple.getValue());
        }

        for(PicklistEntry ple: object2Values)
        {
            String value = ple.getValue();
            System.assert(object1ValueSet.contains(value), String.format(errorTemplate, new String[]{value, field2Name}));
        }        
    }
}