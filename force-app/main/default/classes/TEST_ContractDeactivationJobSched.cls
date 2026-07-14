/**
 * Created by ViktorijaR on 1/20/2022.
 */

@IsTest
private class TEST_ContractDeactivationJobSched
{

	static void setup()
	{

	}

	@IsTest
	static void testDeactivativeContract()
	{
		setup();

		ContractDeactivationJobSched scheduledJob = new ContractDeactivationJobSched();
		Test.startTest();
		ContractDeactivationJobSched.start();
		scheduledJob.execute(null);
		Test.stopTest();

	}

}