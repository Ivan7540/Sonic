@isTest(SeeAllData = false)
private class TEST_UTIL_System_trimSet
{
	public static final Set<String> INIT_SET = new Set<String> {'', '', 'not empty', ' ', 'full', 'not_blank'};

	static testMethod void doTest()
	{
		Set<String> result;
		Test.startTest();
		result = UTIL_System.trimSet(INIT_SET);
		Test.stopTest();
		System.assertEquals(3, result.size(), 'result size is ' + result.size());
	}
}