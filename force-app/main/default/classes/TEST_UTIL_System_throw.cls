@isTest(SeeAllData = false)
private class TEST_UTIL_System_throw
{

	public static final String ERR_MSG = 'myTestThrow';
	static testMethod void doTest()
	{
		Boolean exceptionThrown = false;
		Test.startTest();

		try
		{
			UTIL_System.justThrow();
		}
		catch(Exception e)
		{
			exceptionThrown = true;
		}

		System.AssertEquals(exceptionThrown, true, 'justThrow() not thrown');
		exceptionThrown = false;

		try
		{
			UTIL_System.justThrow(ERR_MSG);
		}
		catch(Exception e)
		{
			Boolean expectedExceptionThrown = e.getMessage().contains(ERR_MSG);
			System.AssertEquals(expectedExceptionThrown, true);
			exceptionThrown = true;
		}

		System.AssertEquals(exceptionThrown, true, 'justThrow(msg) not thrown');
		exceptionThrown = false;

		Test.stopTest();
	}
}