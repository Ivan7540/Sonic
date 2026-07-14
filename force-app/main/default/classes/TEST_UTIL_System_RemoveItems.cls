@isTest(SeeAllData = false)
private class TEST_UTIL_System_RemoveItems
{
	public static final Set<String> SET_TO_REMOVE = new Set<String> {'not empty', 'not_blank'};

	static testMethod void testRemoveItems()
	{
		List<String> init_list = new List<String>();
		Test.startTest();
		List<String> resultsList = UTIL_System.removeItems(init_list, SET_TO_REMOVE);
		System.assertEquals(true, resultsList.isEmpty(), 'List should be empty');

		init_list = new List<String> {'a', 'b', 'not empty', 'c', 'full', 'not_blank'};

		resultsList = UTIL_System.removeItems(init_list, SET_TO_REMOVE);
		System.assertEquals(4, resultsList.size(), 'This list should 3 items size');
		Test.stopTest();
	}
}