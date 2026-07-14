@isTest(SeeAllData = false)
private class TEST_UTIL_Stack
{
	static testMethod void test_objectStack_push()
	{
		Test.startTest();

		UTIL_Stack.ObjectStack objectStack = new UTIL_Stack.ObjectStack();

		try
		{
			objectStack.push(null);
			System.assert(false, 'NullValueNotAllowedException must be thrown');
		}
		catch(UTIL_Stack.NullValueNotAllowedException aNullValueNotAllowedException)
		{
		}

		Test.stopTest();
	}

	static testMethod void test_objectStack_peak()
	{
		Test.startTest();

		UTIL_Stack.ObjectStack objectStack = new UTIL_Stack.ObjectStack();

		try
		{
			objectStack.peak();
			System.assert(false, 'StackUnderflowException must be thrown');
		}
		catch(UTIL_Stack.StackUnderflowException aStackUnderflowException)
		{
		}

		String test1 = DAL_BaseObject.generateRandomName();
		objectStack.push(test1);

		try
		{
			objectStack.peek(2);
			System.assert(false, 'StackOverflowException must be thrown');
		}
		catch(UTIL_Stack.StackOverflowException aStackOverflowException)
		{
		}

		Object test2 = objectStack.peak();

		system.assertEquals(test1, '' + test2, 'Stack.peak has to return what was added');

		Test.stopTest();
	}
}