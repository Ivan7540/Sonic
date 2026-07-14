@isTest(SeeAllData = false)
private class TEST_UTIL_System_assertEmptyList
{
	static testMethod void doTest()
	{
		Test.startTest();

		String message = DAL_BaseObject.generateRandomName();

		try
		{
			UTIL_System.assertEmptyList(new List<SObject>(), message);
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{
			system.assert(false, 'TEST 1. Size is correct. This exception must be not thrown.');
		}

		try
		{
			Account a = DAL_Account.insertItem();

			SObject[] items = new List<SObject>();
			items.add(a);

			UTIL_System.assertEmptyList(items, message);
			system.assert(false, 'TEST 2. Size is NOT correct. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}

		Test.stopTest();
	}
}