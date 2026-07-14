@isTest(SeeAllData = false)
private class TEST_UTIL_System_assertDateSetEquals
{
	static testMethod void doTest()
	{
		Test.startTest();

		Set<Date> set1 = new Set<Date>();
		set1.add(system.today());
		Set<Date> set2 = new Set<Date>();
		set2.add(system.today());

		String message = DAL_BaseObject.generateRandomName();

		try
		{
			UTIL_System.assertDateSetEquals(set1, new Set<Date>(), message);
			system.assert(false, 'TEST 0. Dates are not equal. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}

		try
		{
			UTIL_System.assertDateSetEquals(set1, set2, message);
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{
			system.assert(false, 'TEST 1. Dates are equal. This exception must be not thrown.');
		}

		try
		{
			set2 = new Set<Date>();
			set2.add(system.today().addDays(1));
			UTIL_System.assertDateSetEquals(set1, set2, message);
			system.assert(false, 'TEST 2. Dates are not equal. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}
		Test.stopTest();
	}
}