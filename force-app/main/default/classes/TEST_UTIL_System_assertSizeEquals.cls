@isTest(SeeAllData = false)
private class TEST_UTIL_System_assertSizeEquals
{
	static testMethod void doTest()
	{
		Test.startTest();

		Account a = DAL_Account.insertItem();

		SObject[] items = new List<SObject>();
		items.add(a);

		String message = DAL_BaseObject.generateRandomName();

		try
		{
			UTIL_System.assertSizeEquals(items, items.size(), message);
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{
			system.assert(false, 'TEST 1. Size is correct. This exception must be not thrown.');
		}

		try
		{
			UTIL_System.assertSizeEquals(items, items.size() + 1, message);
			system.assert(false, 'TEST 2. Size is NOT correct. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}

		Test.stopTest();
	}
}