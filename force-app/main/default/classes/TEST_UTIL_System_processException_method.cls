@isTest(SeeAllData = false)
private class TEST_UTIL_System_processException_method
{
	static testMethod void doTest()
	{
		Test.startTest();

		Account a = DAL_Account.insertItem();

		Exception error;

		error = new System.NoDataFoundException();

		UTIL_System.processException(error, a);

		try
		{
			//this triggers DMLException
			insert new Account();
		}
		catch(System.DMLException e)
		{
			error = e;
			UTIL_System.processException(error, a);
		}

		Test.stopTest();
	}
}