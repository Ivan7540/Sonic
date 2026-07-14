/**
 * Created by JurgitaG on 6/14/2021.
 */

global class ContractDeactivationJobSched implements Schedulable
{
	global void execute(SchedulableContext ctx)
	{
		Database.executeBatch(new ContractDeactivationJob());
	}

	global static void start(){

	}

}