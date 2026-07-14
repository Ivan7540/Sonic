@isTest(SeeAllData = false)
private class TEST_UTIL_System_setToList
{
	static testMethod void doTest()
	{
		Set<Id> initIdsSet = null;
		Set<String> initStringSet = null;

		List<Id> resultIdsList;
		List<String> resultStringList;

		Test.startTest();

		resultIdsList = UTIL_System.setToList(initIdsSet);
		System.assertEquals(null, resultIdsList, 'Ids should be null now');

		resultStringList = UTIL_System.setToList(initStringSet);
		System.assertEquals(null, resultStringList, 'Strings should be null now');

		resultStringList = UTIL_System.setToList(new Set<String> {'a', 'b', 'c', ''});
		System.assertEquals(4, resultStringList.size(), 'String list size does not match');

		Test.stopTest();
	}
}