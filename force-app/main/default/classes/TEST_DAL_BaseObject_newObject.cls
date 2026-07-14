@isTest(SeeAllData=false)
private class TEST_DAL_BaseObject_newObject
{
	public static final String ACCOUNT_OBJ_NAME = Account.SObjectType.getDescribe().getLocalName();

	static testMethod void test_newObject()
	{
		SObject a = DAL_BaseObject.newObject(ACCOUNT_OBJ_NAME);
		Schema.sObjectType expected = Account.SObjectType;
		System.assertEquals(expected, a.getSobjectType());

		//Null object
		SObject empty = DAL_BaseObject.newObject(DAL_BaseObject.generateRandomName());
		System.assertEquals(null, empty);
	}
}