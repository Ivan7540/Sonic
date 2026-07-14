/**
 * Created by JurgitaG on 6/14/2021.
 */

global class ContractDeactivationJob
		implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC)
	{

		return Database.getQueryLocator([
				SELECT
						Id, Status, Cancellation_Effective_Date__c
				FROM Contract WHERE Status= :DAL_Contract.STATUS_ACTIVATED AND
				Cancellation_Effective_Date__c < TODAY AND Cancellation_Effective_Date__c !=null
		]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		for (Contract aContract : (List<Contract>)scope){
			aContract.Status=DAL_Contract.STATUS_DEACTIVATED;
		}
		update scope;
	}

	global void finish(Database.BatchableContext bc)
	{
		System.debug('Contracts are deactivated');
	}
}