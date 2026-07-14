@isTest(SeeAllData = false)
private class TEST_UTIL_System_Extract_Values
{
	public static final String TEST_NAME = 'TestName';

	static testMethod void testExtract()
	{
		List<Account> itemsList = new List<Account>();

		Integer inc = 0;

		Account acc1 = DAL_Account.insertItem();
		acc1.Name = TEST_NAME + (++inc);

		Account acc2 = DAL_Account.insertItem();
		acc2.Name = TEST_NAME + (++inc);

		itemsList.add(acc1);
		itemsList.add(acc2);

		List<String> results = new List<String>();

		Test.startTest();

		results = UTIL_System.extractListValues(itemsList, DAL_BaseObject.FIELD_NAME);

		Test.stopTest();

		System.assertEquals(false, results.isEmpty(), 'List should not be empty');
		System.assertEquals(2, results.size(), 'Wrong List size: ' + results.size());

		Set<String> resultSet = new Set<String>(results);

		System.assert(resultSet.contains('TestName1'), 'Missing object TestName1');
		System.assert(resultSet.contains('TestName2'), 'Missing object TestName2');
	}
}