@isTest(SeeAllData = false)
private class TEST_UTIL_System_assertIDSetEquals
{
	static testMethod void doTest()
	{
		Test.startTest();

		Account a = DAL_Account.insertItem();

		Set<ID> set1 = new Set<ID>();
		set1.add(a.id);
		Set<ID> set2 = new Set<ID>(set1);

		String message = DAL_BaseObject.generateRandomName();

		try
		{
			UTIL_System.assertIDSetEquals(set1, new Set<ID>(), message);
			system.assert(false, 'TEST 1. Sets are not equal. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}

		try
		{
			UTIL_System.assertIDSetEquals(set1, set2, message);
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{
			system.assert(false, 'TEST 2. Sets are equal. This exception must be not thrown.');
		}

		try
		{
			a = DAL_Account.insertItem();

			set2 = new Set<ID>();
			set2.add(a.id);
			UTIL_System.assertIDSetEquals(set1, set2, message);
			system.assert(false, 'TEST 3. Sets are not equal. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}
		Test.stopTest();
	}
}