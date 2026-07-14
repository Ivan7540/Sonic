@isTest(SeeAllData = false)
private class TEST_UTIL_System_excludeItemsFromList
{
	static testMethod void doTest()
	{
		Account acc1 = DAL_Account.insertItem();
		Account acc2 = DAL_Account.insertItem();
		Account acc3 = DAL_Account.insertItem();
		List<Account> itemsList = new List<Account>
		{
				acc1,
				acc2,
				acc3
		};
		List<Account> exludeItemsList = new List<Account>
		{
				acc1,
				acc3
		};
		List<Account> results;

		Test.startTest();

		results = UTIL_System.excludeItemsFromList(itemsList, exludeItemsList);

		Test.stopTest();

		UTIL_System.assertSizeEquals(results, 1, 'Icorect size. Must be left only 1 item');
		System.assertEquals(results.get(0), acc2, 'Wrong item. Only item in list should be "b"');
	}
}