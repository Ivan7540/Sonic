/**
 * Created by JurgitaG on 3/1/2021.
 */

public without sharing class LeadSelectionController
{
	@AuraEnabled
	public static List<Lead> getDuplicateLeads(String firstName, String lastName, String company, String phone){
		Lead aLead = new Lead();
		aLead.FirstName = firstName;
		aLead.LastName = lastName;
		aLead.Company = company;
		aLead.Phone = phone;

		System.debug(aLead);
		Database.SaveResult res = Database.insert(aLead,false);
		List<Id> duplicateIds = new List<Id>();
		if (res.isSuccess()) {
			// Operation was successful, so get the ID of the record that was processed
			System.debug('Successfully inserted Lead. Lead ID: ' + res.getId());
		}
		else {

			Datacloud.DuplicateResult duplicateResult;
			List<Datacloud.MatchRecord> matchRecords;

			// Operation failed, so get all errors
			for(Database.Error duplicateError : res.getErrors()) {

				duplicateResult = ((Database.DuplicateError)duplicateError).getDuplicateResult();
				System.debug('The following error has occurred.--duplicateResult--'+duplicateResult);

			}

			for(Datacloud.MatchResult duplicateMatchResult : duplicateResult.getMatchResults()) {
				matchRecords = duplicateMatchResult.getMatchRecords();
				System.debug('The following error has occurred.--matchRecords--'+matchRecords);
			}
			System.debug('total.--matchRecords--'+matchRecords);
			for(Datacloud.MatchRecord duplicateMatchRecord : matchRecords) {
				duplicateIds.add(duplicateMatchRecord.getRecord().Id);
				System.debug('duplicateIds--'+duplicateIds);

			}
		}
		List<Lead> duplicateLeads = [SELECT Id, Name, Phone, Company FROM Lead WHERE Id IN: duplicateIds];
		List<Contact> duplicateContacts = [SELECT Id, Name, Phone, Account.Name, AccountId FROM Contact WHERE Id IN: duplicateIds];
		System.debug(duplicateLeads);
		List<SObject> duplicates = new List<SObject>();
		duplicates.addAll(duplicateLeads);
		duplicates.addAll(duplicateContacts);
		return duplicateLeads;
	}

	@AuraEnabled
	public static List<Contact> getDuplicateContacts(String firstName, String lastName, String company, String phone){
		Lead aLead = new Lead();
		aLead.FirstName = firstName;
		aLead.LastName = lastName;
		aLead.Company = company;
		aLead.Phone = phone;

		System.debug(aLead);
		Database.SaveResult res = Database.insert(aLead,false);
		List<Id> duplicateIds = new List<Id>();
		if (res.isSuccess()) {
			// Operation was successful, so get the ID of the record that was processed
			System.debug('Successfully inserted Lead. Lead ID: ' + res.getId());
		}
		else {

			Datacloud.DuplicateResult duplicateResult;
			List<Datacloud.MatchRecord> matchRecords;

			// Operation failed, so get all errors
			for(Database.Error duplicateError : res.getErrors()) {

				duplicateResult = ((Database.DuplicateError)duplicateError).getDuplicateResult();
				System.debug('The following error has occurred.--duplicateResult--'+duplicateResult);

			}

			for(Datacloud.MatchResult duplicateMatchResult : duplicateResult.getMatchResults()) {
				matchRecords = duplicateMatchResult.getMatchRecords();
				System.debug('The following error has occurred.--matchRecords--'+matchRecords);
			}
			System.debug('total.--matchRecords--'+matchRecords);
			for(Datacloud.MatchRecord duplicateMatchRecord : matchRecords) {
				duplicateIds.add(duplicateMatchRecord.getRecord().Id);
				System.debug('duplicateIds--'+duplicateIds);

			}
		}

		List<Contact> duplicateContacts = [SELECT Id, Name, Phone, Account.Name, AccountId FROM Contact WHERE Id IN: duplicateIds];
//		List<Contact> duplicateContacts = [SELECT Id, Name, Phone, Account.Name, AccountId FROM Contact ];
		return duplicateContacts;
	}
}