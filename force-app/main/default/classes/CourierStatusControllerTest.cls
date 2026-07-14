/*
Date created: 11/10/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1025
*/
@IsTest(SeeAllData = false)
public class CourierStatusControllerTest 
{
    @isTest
    static void status()
    {
        Test.startTest();

        String result = CourierStatusController.getWaybillStatus('WAS652258');

        Test.stopTest();

        System.assertEquals('Waybill WAS652258 sent for delivery', result);
    }
}