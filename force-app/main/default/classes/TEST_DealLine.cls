/**
 * Created by ViktorijaR on 12/14/2021.
 */

@IsTest(SeeAllData=false)
private class TEST_DealLine
{

	private static List<Deal__c> testDeals;
	private static List<Deal_Line__c> testDealLineParents;
	private static List<Deal_Line__c> testDealLineChilds;

	static void setup()
	{
		testDeals = TestDataFactory.createDeals(1);
		testDealLineParents = TestDataFactory.createTestDealLines(1, testDeals[0].Id, null);
		testDealLineChilds = TestDataFactory.createTestDealLines(1, testDeals[0].Id, testDealLineParents[0].Id);
	}

	@IsTest
	static void testDeleteParentDealLine()
	{
		setup();
		Test.startTest();
        delete testDealLineChilds;
		Test.stopTest();
	}
}