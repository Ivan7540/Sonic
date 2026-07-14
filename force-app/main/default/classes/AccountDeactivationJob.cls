global class AccountDeactivationJob implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator([
				SELECT
						Id, Status__c
				FROM Account
				WHERE Status__c = :DAL_Account.STATUS_ACTIVE
				AND id NOT IN
				(select AccountId from Contract WHERE Status != :DAL_Contract.STATUS_CANCELLED)
		]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		for (Account anAccount : (List<Account>) scope)
		{
			anAccount.Status__c = DAL_Account.STATUS_INACTIVE;
		}
		update scope;
	}

	global void finish(Database.BatchableContext bc)
	{
		System.debug('Accounts are deactivated');
	}

}