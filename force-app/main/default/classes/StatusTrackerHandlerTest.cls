@isTest(SeeAllData=false)
public class StatusTrackerHandlerTest 
{
    @isTest
    static void testEmptyNoInsertWorkOrder()
    {
        List<String> pickvals = UTIL_System.getPicklistEntriesMap(WorkOrder__c.getSObjectType(), 'Status__c').values();
        WorkOrder__c wo = TestDataFactory.createWorkOrder(null, null, null, null);
        wo.Status__c = pickvals[1];        
        DAL_BaseObject.UpdateDBObject(wo);

        List<PicklistValueAge__c> results = StatusTrackingUtil.getAll();
        System.assertEquals(1, results.size(), 'Wrong number of trackers');
        
        Test.startTest();
        
        PicklistValueAge__c excess = new PicklistValueAge__c();
        excess.Active__c = false;
        excess.TimesInStatus__c = 0;
        excess.TrackedFieldValue__c = pickvals[1];
        excess.TrackedObjectAPIName__c = 'WorkOrder__c';
        excess.TrackedFieldName__c = 'Status__c';
        
        DAL_BaseObject.InsertDBObject(excess);
        
        Test.stopTest();
        
        results = StatusTrackingUtil.getAll();
        System.assertEquals(1, results.size(), 'Wrong number of trackers');
    }

    @isTest
    static void testEmptyNoInsertQuote()
    {
        List<String> pickvals = UTIL_System.getPicklistEntriesMap(SBQQ__Quote__c.getSObjectType(), 'SBQQ__Status__c').values();
        SBQQ__Quote__c testQuote = TestDataFactory.createQuotes(TestDataFactory.createOpportunities(TestDataFactory.createTestAccounts(1, 0, 'GAU')), false)[0];
        testQuote.SBQQ__Status__c = pickvals[0];        
        DAL_BaseObject.UpdateDBObject(testQuote);

        List<PicklistValueAge__c> results = StatusTrackingUtil.getAll();
        System.assertEquals(4, results.size(), 'Wrong number of trackers');
        
        Test.startTest();
        
        PicklistValueAge__c excess = new PicklistValueAge__c();
        excess.Active__c = false;
        excess.TimesInStatus__c = 0;
        excess.TrackedFieldValue__c = pickvals[1];
        excess.TrackedObjectAPIName__c = 'SBQQ__Quote__c';
        excess.TrackedFieldName__c = 'SBQQ__Status__c';
        
        DAL_BaseObject.InsertDBObject(excess);
        
        Test.stopTest();
        
        results = StatusTrackingUtil.getAll();
        System.assertEquals(4, results.size(), 'Wrong number of trackers');
    }

    @isTest
    static void testEmptyNoInsertOpportunity()
    {
        List<String> pickvals = UTIL_System.getPicklistEntriesMap(Opportunity.getSObjectType(), 'StageName').values();
        Opportunity testOpp = TestDataFactory.createOpportunities(TestDataFactory.createTestAccounts(1, 0, 'GAU'))[0];
        testOpp.StageName = pickvals[0];        
        DAL_BaseObject.UpdateDBObject(testOpp);

        List<PicklistValueAge__c> results = StatusTrackingUtil.getAll();
        System.assertEquals(2, results.size(), 'Wrong number of trackers');
        
        Test.startTest();
        
        PicklistValueAge__c excess = new PicklistValueAge__c();
        excess.Active__c = false;
        excess.TimesInStatus__c = 0;
        excess.TrackedFieldValue__c = pickvals[1];
        excess.TrackedObjectAPIName__c = 'Opportunity';
        excess.TrackedFieldName__c = 'StageName';
        
        DAL_BaseObject.InsertDBObject(excess);
        
        Test.stopTest();
        
        results = StatusTrackingUtil.getAll();
        System.assertEquals(2, results.size(), 'Wrong number of trackers');
    }

    @isTest
    static void testEmptyNoInsertContract()
    {
        List<String> pickvals = UTIL_System.getPicklistEntriesMap(Contract.getSObjectType(), 'Status').values();
        Contract testContract = TestDataFactory.createContract(TestDataFactory.createTestAccounts(1, 0, 'GAU')[0].Id, 12, Date.today()); 
        DAL_BaseObject.InsertDBObject(testContract);
        testContract.Status = pickvals[0];        
        DAL_BaseObject.UpdateDBObject(testContract);

        List<PicklistValueAge__c> results = StatusTrackingUtil.getAll();
        System.assertEquals(1, results.size(), 'Wrong number of trackers');
        
        Test.startTest();
        
        PicklistValueAge__c excess = new PicklistValueAge__c();
        excess.Active__c = false;
        excess.TimesInStatus__c = 0;
        excess.TrackedFieldValue__c = pickvals[1];
        excess.TrackedObjectAPIName__c = 'Contract';
        excess.TrackedFieldName__c = 'Status';
        
        DAL_BaseObject.InsertDBObject(excess);
        
        Test.stopTest();
        
        results = StatusTrackingUtil.getAll();
        System.assertEquals(1, results.size(), 'Wrong number of trackers');
    }

    @isTest
    static void testEmptyNoInsertLead()
    {
        List<String> pickvals = UTIL_System.getPicklistEntriesMap(Lead.getSObjectType(), 'Status').values();
        Lead testLead = TestDataFactory.createLead('Web'); 
        testLead.Status = pickvals[0];        
        DAL_BaseObject.UpdateDBObject(testLead);

        List<PicklistValueAge__c> results = StatusTrackingUtil.getAll();
        System.assertEquals(1, results.size(), 'Wrong number of trackers');
        
        Test.startTest();
        
        PicklistValueAge__c excess = new PicklistValueAge__c();
        excess.Active__c = false;
        excess.TimesInStatus__c = 0;
        excess.TrackedFieldValue__c = pickvals[1];
        excess.TrackedObjectAPIName__c = 'Lead';
        excess.TrackedFieldName__c = 'Status';
        
        DAL_BaseObject.InsertDBObject(excess);
        
        Test.stopTest();
        
        results = StatusTrackingUtil.getAll();
        System.assertEquals(1, results.size(), 'Wrong number of trackers');
    }
}