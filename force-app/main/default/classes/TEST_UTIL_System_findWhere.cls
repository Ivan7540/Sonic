@isTest(SeeAllData = false)
private class TEST_UTIL_System_findWhere
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
		Account acc1 = DAL_Account.insertItem();
		acc1.Name = TEST_NAME;
		Account acc2 = DAL_Account.insertItem();
		acc2.Name = TEST_NAME;
		itemsList.add(acc1);
		itemsList.add(acc2);
		List<Account> results = new List<Account>();
		Test.startTest();
		results = UTIL_System.findWhere(itemsList, DAL_BaseObject.FIELD_ID, (Id)acc1.get(DAL_BaseObject.FIELD_ID));
		Test.stopTest();

		System.assertEquals(results.isEmpty(), false, 'List shouldnt be empty ');
		System.assertEquals(results.get(0), acc1, 'Results should match acc1');

	}
}