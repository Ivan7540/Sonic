@isTest(SeeAllData = false)
private class TEST_UTIL_System_pickListEntries
{
	private static String FIELD_ACCOUNT_SOURCE = 'AccountSource';
	public static final String ACCOUNT_OBJ_NAME = Account.SObjectType.getDescribe().getLocalName();

	static testMethod void testPickListEntriesMap()
	{
		Account a = DAL_Account.insertItem();

		Test.startTest();

		Schema.SObjectType token = Schema.getGlobalDescribe().get(ACCOUNT_OBJ_NAME);
		Map<String, String> picklistMap = UTIL_System.getPicklistEntriesMap(token, FIELD_ACCOUNT_SOURCE);

		Test.stopTest();

		System.assertEquals(false, picklistMap.isEmpty());

	}

	static testMethod void testPickListEntriesList()
	{
		Account a = DAL_Account.insertItem();

		Test.startTest();

		List<Schema.PicklistEntry> pickListEntries = UTIL_System.getPicklistEntries(ACCOUNT_OBJ_NAME, FIELD_ACCOUNT_SOURCE);

		Test.stopTest();

		System.assertEquals(false, pickListEntries.isEmpty());

	}
}