/**
 * Created by JurgitaG on 6/14/2021.
 */

global class AccountDeactivationJobSched implements Schedulable
{
	global void execute(SchedulableContext ctx)
	{
		Database.executeBatch(new AccountDeactivationJob());
	}

	global static void start(){

	}

}