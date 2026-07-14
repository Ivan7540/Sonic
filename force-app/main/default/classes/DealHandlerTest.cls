@isTest
public class DealHandlerTest {
    public static testMethod void testDealHandler(){
        Deal__c deal = new Deal__c();
        
        test.startTest();
        insert deal;
        test.stopTest();
    }
}