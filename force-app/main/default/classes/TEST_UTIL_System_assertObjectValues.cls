@isTest(SeeAllData = false)
private class TEST_UTIL_System_assertObjectValues
{
	static testMethod void doTest()
	{
		Test.startTest();

		Account a = DAL_Account.insertItem();

		String message = DAL_BaseObject.generateRandomName();

		String[] fieldNames = new List<String>();
		fieldNames.add('Name');
		fieldNames.add('OwnerId');
		fieldNames.add('Phone');
		fieldNames.add('BillingStreet');
		fieldNames.add('BillingCity');
		fieldNames.add('BillingState');
		fieldNames.add('BillingCountry');

		Object[] values = new List<Object>();
		values.add(a.Name);
		values.add(a.OwnerId);
		values.add(a.Phone);
		values.add(a.BillingStreet);
		values.add(a.BillingCity);
		values.add(a.BillingState);
		values.add(a.BillingCountry);

		try
		{
			UTIL_System.assertObjectValues(a, fieldNames, values, message);
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{
			system.assert(false, 'TEST 1. Data are equal. This exception must be not thrown.');
		}

		try
		{
			values[0] = DAL_BaseObject.generateRandomName();
			UTIL_System.assertObjectValues(a, fieldNames, values, message);
			system.assert(false, 'TEST 2. Data are not equal. This exception must be thrown.');
		}
		catch(UTIL_System.AssertionException anAssertionException)
		{

		}

		Test.stopTest();
	}
}