/**
 * Created by ViktorijaR on 1/20/2022.
 */

@IsTest
private class TEST_AccountDeactivationJobSched
{
	private static Account testAccount;

	static void setup()
	{

	}

	@IsTest
	static void testActiveContract()
	{
		setup();

		AccountDeactivationJobSched scheduledJob = new AccountDeactivationJobSched();
		Test.startTest();
		AccountDeactivationJobSched.start();
		scheduledJob.execute(null);
		Test.stopTest();

	}
}