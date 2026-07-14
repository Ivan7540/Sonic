@isTest(SeeAllData = false)
private class TEST_UTIL_System_FindWhereIn
{
	public static final String TEST_NAME = 'TestName';

	static testMethod void testfindWhere()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Integer inc = 0;

		Account acc1 = DAL_Account.insertItem();
		acc1.Name = TEST_NAME + (++inc);

		Account acc2 = DAL_Account.insertItem();
		acc2.Name = TEST_NAME + (++inc);

		itemsList.add(acc1);
		itemsList.add(acc2);

		List<Account> results = new List<Account>();

		Test.startTest();

		results = UTIL_System.findWhereIn(itemsList, DAL_BaseObject.FIELD_NAME, new List<Object> {'TestName1', 'TestName2'});

		Test.stopTest();

		System.assertEquals(false, results.isEmpty(), 'List should not be empty');
		System.assertEquals(2, results.size(), 'Wrong List size: ' + results.size());

		System.assertEquals(1, UTIL_System.findWhere(results, DAL_BaseObject.FIELD_NAME, 'TestName1').size(), 'Missing object TestName1');
		System.assertEquals(1, UTIL_System.findWhere(results, DAL_BaseObject.FIELD_NAME, 'TestName2').size(), 'Missing object TestName2');
	}
}