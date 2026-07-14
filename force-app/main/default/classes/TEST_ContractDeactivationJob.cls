/**
 * Created by JurgitaG on 6/14/2021.
 */

@IsTest
private class TEST_ContractDeactivationJob
{
	private static Account testAccount;

	static void setup()
	{
		testAccount = TestDataFactory.createTestAccounts(1, 0, 'Gauteng')[0];

	}

	@IsTest
	static void testActiveContract(){
		setup();
		Contract testContract = TestDataFactory.createContract(testAccount.Id,1, Date.today().addMonths(-2));
		testContract.Cancellation_Effective_Date__c = Date.today().addMonths(-2);
		testContract.Status = DAL_Contract.STATUS_DRAFT;

		insert testContract;
		testContract.Status = DAL_Contract.STATUS_ACTIVATED;

		update testContract;
		List<Contract> activeList = [SELECT Id, Status, StartDate FROM Contract WHERE Status =:DAL_Contract.STATUS_ACTIVATED];
		System.assertEquals(1,activeList.size());

		Test.startTest();
		Database.executeBatch(new ContractDeactivationJob());
		Test.stopTest();

		 activeList = [SELECT Id, Status, StartDate FROM Contract WHERE Status =:DAL_Contract.STATUS_DEACTIVATED];
		System.debug(activeList);
		System.assertEquals(1,activeList.size());
	}
	@IsTest
	static void testMultipleContract(){
		setup();
		Contract testContract = TestDataFactory.createContract(testAccount.Id,1, Date.today().addMonths(-2));
		Contract testContract2 = TestDataFactory.createContract(testAccount.Id,5, Date.today().addMonths(2));
		testContract.Cancellation_Effective_Date__c = Date.today().addMonths(-2);
		testContract2.Cancellation_Effective_Date__c = Date.today().addMonths(1);
		testContract.Status = DAL_Contract.STATUS_DRAFT;
		testContract2.Status = DAL_Contract.STATUS_DRAFT;

		insert testContract;
		insert testContract2;
		testContract.Status = DAL_Contract.STATUS_ACTIVATED;
		testContract2.Status = DAL_Contract.STATUS_ACTIVATED;

		update testContract;
		update testContract2;
		List<Contract> activeList = [SELECT Id, Status, StartDate FROM Contract WHERE Status =:DAL_Contract.STATUS_ACTIVATED];
		System.assertEquals(2,activeList.size());

		Test.startTest();
		Database.executeBatch(new ContractDeactivationJob());
		Test.stopTest();

		 activeList = [SELECT Id, Status, StartDate FROM Contract WHERE Status =:DAL_Contract.STATUS_DEACTIVATED];
		System.debug(activeList);
		System.assertEquals(1,activeList.size());
	}
}