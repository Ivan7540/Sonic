/*
Date created: 19/01/2021
Developer: Ivan Vrtacnik
JIRA number: PS-33
*/
@isTest(SeeAllData=false)
public class LeadHandlerTest 
{
    @isTest
    static void testUpdateEscalation()
    {
        Lead testLead = TestDataFactory.createLead(DAL_Lead.SOURCE_WEB);
        testLead = DAL_Lead.getById(testLead.Id);

        System.assertEquals(null, testLead.Escalation_Time__c);

        Test.startTest();

        testLead.Status = DAL_Lead.STATUS_WORKING;
        DAL_BaseObject.UpdateDBObject(testLead);

        Test.stopTest();

        testLead = DAL_Lead.getById(testLead.Id);

        System.assertNotEquals(null, testLead.Escalation_Time__c);
    }

    @isTest
    static void testNotUpdateEscalation()
    {
        Lead testLead = TestDataFactory.createLead(DAL_Lead.SOURCE_WEB);
        testLead = DAL_Lead.getById(testLead.Id);

        System.assertEquals(null, testLead.Escalation_Time__c);

        Test.startTest();

        testLead.Status = DAL_Lead.STATUS_CONTACT;
        DAL_BaseObject.UpdateDBObject(testLead);

        Test.stopTest();

        testLead = DAL_Lead.getById(testLead.Id);

        System.assertEquals(null, testLead.Escalation_Time__c);
    }
}