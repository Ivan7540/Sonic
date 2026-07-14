@isTest(SeeAllData = false)
private class TEST_UTIL_System_hasExtractField
{
	public static final String NON_EXISTING_FIELD = 'nothingn';

	static testMethod void testHasField()
	{
		Account account = DAL_Account.insertItem();
		Boolean hasField;

		Test.startTest();

		hasField = UTIL_System.hasSObjectField(account, DAL_BaseObject.FIELD_NAME);
		System.assertEquals(hasField, true, 'Account object always has Name field. Should be true');
		hasField = UTIL_System.hasSObjectField(account, NON_EXISTING_FIELD);
		System.assertEquals(hasField, false, 'Account doesnt have this field. Should be false');

		Test.stopTest();
	}

	static testMethod void testExtractListIds()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};
		Set<ID> ids;

		Test.startTest();

		ids = UTIL_System.extractListIds(itemsList);
		System.assertEquals(3, ids.size(), 'Should be 3 ids in Set');

		itemsList.add(new Account(
				id = null
		));

		ids = UTIL_System.extractListIds(itemsList, DAL_BaseObject.FIELD_ID);
		System.assertEquals(4, ids.size(), 'Should be 4 ids in Set');

		ids = UTIL_System.extractListIds(itemsList, DAL_BaseObject.FIELD_ID, true);
		System.assertEquals(3, ids.size(), 'Should be 3 ids in Set');

		Test.stopTest();
	}
}