@isTest(SeeAllData = false)
private class TEST_UTIL_System_Omit
{
	static testMethod void testOmit()
	{
		List<Account> accounts = new List<Account>
		{
				DAL_Account.insertItem(),
				DAL_Account.insertItem(),
				DAL_Account.insertItem()
		};

		Account a1 = DAL_Account.insertItem();
		Account a2 = DAL_Account.insertItem();

		accounts.add(a1);
		accounts.add(a2);

		Set<ID> idList = UTIL_System.extractListIds(accounts);
		Set<ID> idToBeOmited = new Set<ID> {a1.ID, a2.ID};

		Test.startTest();
		Set<ID> results = UTIL_System.omit(idList, idToBeOmited);
		List<Account> omitWhereResutls = UTIL_System.omitWhere(accounts, DAL_BaseObject.FIELD_ID, (Id)a1.get(DAL_BaseObject.FIELD_ID));
		Set<ID> concatResults = UTIL_System.concat(results, idToBeOmited);
		Test.stopTest();

		System.assertEquals(3, results.size(), 'Should be left 3 Ids in list');
		System.assertEquals(4, omitWhereResutls.size(), 'Should remove one account from list and be left 4 items in list');
		System.assertEquals(5, concatResults.size(), 'Should add 2 into set and be size of 5');

	}
}