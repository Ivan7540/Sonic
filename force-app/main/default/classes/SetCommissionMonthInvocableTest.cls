/*
Date created: 17/05/2021
Developer: Ivan Vrtacnik
JIRA number: PS-507
*/
@isTest(SeeAllData = false)
public class SetCommissionMonthInvocableTest 
{
    @isTest
    static void monthSetting()
    {
        Date installDate = Date.newInstance(2021, 04, 22);

        // Account testAccount = TestDataFactory.createTestAccounts(1, 1, null)[0];
        // Contract testContract = TestDataFactory.createContract(testAccount.Id, 24, Date.today().addMonths(-1).toStartOfMonth());
        // testContract.InstallationDate__c = installDate;
        // DAL_BaseObject.InsertDBObject(testContract);

        // SetCommissionMonthInvocable.CommissionInput input = new SetCommissionMonthInvocable.CommissionInput();
        // input.accountId = testAccount.Id;
        // input.installationDate = installDate;

        Test.startTest();

        List<Date> results = SetCommissionMonthInvocable.setCommissionMonth(new List<Date>{installDate});

        Test.stopTest();

        System.assertEquals(1, results.size(), 'Incorrect number of resulting dates returned');
        System.assertEquals(Date.newInstance(2021, 05, 01), results[0], 'Commission date set incorrectly');

        // testAccount = getUpdatedAccount(testAccount.Id);

        // System.assertNotEquals(null, testAccount, 'Test Account not found in query, check test class');
        // System.assertEquals(Date.newInstance(2021, 05, 01), testAccount.Commission_Month__c, 'Commission date set incorrectly');
    }

    // private static Account getUpdatedAccount(Id accountId)
    // {
    //     return
    //     [
    //         SELECT  Id,
    //                 Commission_Month__c
    //         FROM Account
    //         WHERE Id = :accountId
    //         LIMIT 1
    //     ];
    // }
}