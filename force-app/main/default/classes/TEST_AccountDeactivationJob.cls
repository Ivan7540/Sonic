/**
 * Created by JurgitaG on 6/14/2021.
 */

@IsTest
private class TEST_AccountDeactivationJob
{
	private static Account testAccount;

	static void setup()
	{
		testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];

	}

	@IsTest
	static void testInactiveContract(){
		setup();
		Contract testContract = TestDataFactory.createContract(testAccount.Id,1, Date.today().addMonths(-2));
		testContract.Cancellation_Effective_Date__c = Date.today().addMonths(-2);
		testContract.Status = DAL_Contract.STATUS_DRAFT;

		insert testContract;
		Contract testContract2 = TestDataFactory.createContract(testAccount.Id,1, Date.today().addMonths(-2));
		testContract2.Cancellation_Effective_Date__c = Date.today().addMonths(-2);
		testContract2.Status = DAL_Contract.STATUS_DRAFT;

		insert testContract2;
//		testContract.Status = DAL_Contract.STATUS_ACTIVATED;
//		update testContract;
		testContract.RateContract__c = testContract2.Id;
//		testContract.Status = DAL_Contract.STATUS_CANCELLED;
//		update testContract;

		List<Account> activeList = [SELECT Id, Status__c FROM Account WHERE Status__c =:DAL_Account.STATUS_ACTIVE];
		System.assertEquals(1,activeList.size());

		Test.startTest();
		Database.executeBatch(new AccountDeactivationJob());
		Test.stopTest();

		activeList = [SELECT Id, Status__c FROM Account WHERE Status__c =:DAL_Account.STATUS_INACTIVE];
		System.debug(activeList);
//		System.assertEquals(1,activeList.size());

	}
	@IsTest
	static void testActiveContract(){
		setup();
		Contract testContract = TestDataFactory.createContract(testAccount.Id,1, Date.today().addMonths(-2));
		Contract testContract2 = TestDataFactory.createContract(testAccount.Id,1, Date.today().addMonths(1));
		testContract.Cancellation_Effective_Date__c = Date.today().addMonths(-2);
		testContract.Status = DAL_Contract.STATUS_DRAFT;

		insert testContract2;
		insert testContract;
		testContract.Status = DAL_Contract.STATUS_DEACTIVATED;
		testContract2.Status = DAL_Contract.STATUS_ACTIVATED;

		update testContract;
		update testContract2;
		List<Account> activeList = [SELECT Id, Status__c FROM Account WHERE Status__c =:DAL_Account.STATUS_ACTIVE];
		System.assertEquals(1,activeList.size());

		Test.startTest();
		Database.executeBatch(new AccountDeactivationJob());
		Test.stopTest();

		activeList = [SELECT Id, Status__c FROM Account WHERE Status__c =:DAL_Account.STATUS_INACTIVE];
		System.debug(activeList);
		System.assertEquals(0,activeList.size());

	}
}