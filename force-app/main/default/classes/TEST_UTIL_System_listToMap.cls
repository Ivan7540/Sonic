@isTest(SeeAllData = false)
private class TEST_UTIL_System_listToMap
{
	public static final String TEST_STRING_KEY = 'key';

	static testMethod void testListToMapSet()
	{
		Test.startTest();

		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Account acc1 = DAL_Account.insertItem();
		itemsList.add(acc1);
		Map<ID, Set<Id>> mapSet = new Map<ID, Set<Id>>();
		mapSet = UTIL_System.convertListToMapSet(itemsList, DAL_BaseObject.FIELD_OWNER_ID, DAL_BaseObject.FIELD_ID);
		Set<ID> setId = mapSet.get(null);
		Test.stopTest();
		System.assertEquals(setId.isEmpty(), false, 'Set should not be empty');
		System.assertEquals(setId.contains((Id)acc1.get(DAL_BaseObject.FIELD_ID)), true, 'Set should contain this account ID');
	}

	static testMethod void testListToMap()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Map<ID, List<Account>> mapList = new Map<ID, List<Account>>();
		Test.startTest();
		mapList = UTIL_System.convertListToMap(itemsList, DAL_BaseObject.FIELD_OWNER_ID);
		Test.stopTest();

		List<Account> newList = mapList.get(null);
		System.assertEquals(newList.isEmpty(), false, 'List shouldnt be empty');
		System.assertEquals(newList.size(), 3, 'List should have 3 items');
	}

	static testMethod void testListToSingleMap()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Account acc1 = DAL_Account.insertItem();
		itemsList.add(acc1);

		Map<Id, SObject> mapLits = new Map<ID, SObject>();
		Test.startTest();
		mapLits = UTIL_System.convertListToSingleMap(itemsList, DAL_BaseObject.FIELD_ID);
		Test.stopTest();

		System.assertEquals(mapLits.isEmpty(), false, 'List shouldnt be empty');
		System.assertEquals(mapLits.get((Id)acc1.get(DAL_BaseObject.FIELD_ID)), acc1, 'Objects should be equals');
	}

	static testMethod void testListToSingleMapCompoundKey()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Account acc1 = DAL_Account.insertItem();
		itemsList.add(acc1);
		Map<String, SObject> mapLits = new Map<String, SObject>();
		String[] keyList = new String[] {DAL_BaseObject.FIELD_ID, DAL_BaseObject.FIELD_NAME};

		Test.startTest();
		mapLits = UTIL_System.convertListToSingleMap(itemsList, keyList);
		Test.stopTest();

		String key = UTIL_System.getCompoundKey(acc1, keyList);
		System.assertEquals(mapLits.isEmpty(), false, 'List shouldnt be empty');
		System.assertEquals(mapLits.get(key), acc1, 'Objects should be equals');
	}

	static testMethod void testExtractListFromMap()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Map<String, List<Account>> testMap = new Map<String, List<Account>>();

		testMap.put(TEST_STRING_KEY, itemsList);
		List<Account> extractedList = new List<Account>();
		Test.startTest();
		extractedList = UTIL_System.extractListFromMap(testMap);
		Test.stopTest();
		System.assertEquals(extractedList.isEmpty(), false, 'List shouldnt be empty');
		System.assertEquals(testMap.get(TEST_STRING_KEY).size(), extractedList.size(), 'Objects should be equals');
	}

	static testMethod void testConvertToStringMap()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.newItem(),
				DAL_Account.newItem(),
				DAL_Account.newItem()
		};

		String nomen = 'Account Name ';
		Integer inc = 0;

		for(Account acc: itemsList)
			acc.Name = nomen + (++inc);

		DAL_BaseObject.InsertDBObjects(itemsList);

		Map<String, List<SObject>> expected;

		Test.startTest();

		expected = UTIL_System.convertListToStringMap(itemsList, DAL_BaseObject.FIELD_NAME);

		Test.stopTest();

		System.assertNotEquals(null, expected, 'No map returned');
		System.assertEquals(3, expected.keySet().size(), 'Map returned of wrong size: ' + expected.keySet().size());

		System.assertNotEquals(null, expected.get('Account Name 1'), 'Object List is null for Account Name 1');
		System.assertNotEquals(null, expected.get('Account Name 2'), 'Object List is null for Account Name 2');
		System.assertNotEquals(null, expected.get('Account Name 3'), 'Object List is null for Account Name 3');

		System.assert(!expected.get('Account Name 1').isEmpty(), 'Object List is empty for Account Name 1');
		System.assert(!expected.get('Account Name 2').isEmpty(), 'Object List is empty for Account Name 2');
		System.assert(!expected.get('Account Name 3').isEmpty(), 'Object List is empty for Account Name 3');

		System.assertEquals(1, expected.get('Account Name 1').size(), 'Object List is wrong size for Account Name 1: ' + expected.get('Account Name 1').size());
		System.assertEquals(1, expected.get('Account Name 2').size(), 'Object List is wrong size for Account Name 2: ' + expected.get('Account Name 2').size());
		System.assertEquals(1, expected.get('Account Name 3').size(), 'Object List is wrong size for Account Name 3: ' + expected.get('Account Name 3').size());

		System.assertEquals('Account Name 1', ((Account)expected.get('Account Name 1')[0]).Name, 'Account Name 1 not under correct key');
		System.assertEquals('Account Name 2', ((Account)expected.get('Account Name 2')[0]).Name, 'Account Name 2 not under correct key');
		System.assertEquals('Account Name 3', ((Account)expected.get('Account Name 3')[0]).Name, 'Account Name 3 not under correct key');
	}

	static testMethod void testConvertToSingleStringMap()
	{
		List<Account> itemsList = new List<Account>
		{
				DAL_Account.newItem(),
				DAL_Account.newItem(),
				DAL_Account.newItem()
		};

		String nomen = 'Account Name ';
		Integer inc = 0;

		for(Account acc: itemsList)
			acc.Name = nomen + (++inc);

		DAL_BaseObject.InsertDBObjects(itemsList);

		Map<String, SObject> expected;

		Test.startTest();

		expected = UTIL_System.convertListToSingleStringMap(itemsList, DAL_BaseObject.FIELD_NAME);

		Test.stopTest();

		System.assertNotEquals(null, expected, 'No map returned');
		System.assertEquals(3, expected.keySet().size(), 'Map returned of wrong size: ' + expected.keySet().size());

		System.assertNotEquals(null, expected.get('Account Name 1'), 'Object is null for Account Name 1');
		System.assertNotEquals(null, expected.get('Account Name 2'), 'Object is null for Account Name 2');
		System.assertNotEquals(null, expected.get('Account Name 3'), 'Object is null for Account Name 3');

		System.assertEquals('Account Name 1', ((Account)expected.get('Account Name 1')).Name, 'Account Name 1 not under correct key');
		System.assertEquals('Account Name 2', ((Account)expected.get('Account Name 2')).Name, 'Account Name 2 not under correct key');
		System.assertEquals('Account Name 3', ((Account)expected.get('Account Name 3')).Name, 'Account Name 3 not under correct key');
	}
}