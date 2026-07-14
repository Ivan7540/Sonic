@isTest(SeeAllData=false)
private class TEST_DAL_BaseObject_generateRandom
{
	public static final String EMAIL_SUFFIX = '@mailinator.com';

	static testMethod void test_generateRandomNumber()
	{
		String randomNumber = DAL_BaseObject.generateRandomNumber();
		Integer randomInteger= DAL_BaseObject.generateRandomInteger();
		Boolean isNumeric = randomNumber.isNumeric();
		System.assertEquals(true, isNumeric);

		Integer expectedLength = 15;
		System.assertEquals(expectedLength, randomNumber.length());

	}

	static testMethod void test_generateRandomName()
	{
		String randomName = DAL_BaseObject.generateRandomName();

		Boolean isAlphabetic = randomName.isAlpha();
		System.assertEquals(true, isAlphabetic);

		Integer expectedLength = 15;
		System.assertEquals(expectedLength, randomName.length());
	}

	static testMethod void test_generateRandomDescription()
	{
		String randomDescription = DAL_BaseObject.generateRandomDescription();

		Boolean isAlphabetic = randomDescription.isAlpha();
		System.assertEquals(true, isAlphabetic);

		Integer expectedLength = 80;
		System.assertEquals(expectedLength, randomDescription.length());
	}

	static testMethod void test_generateRandomEmail()
	{
		String randomEmail = DAL_BaseObject.generateRandomEmail();

		String randomEmailSuffix = randomEmail.substring(15, randomEmail.length());
		System.assertEquals(EMAIL_SUFFIX, randomEmailSuffix);
	}
}