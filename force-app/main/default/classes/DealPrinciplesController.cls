/**
 * Created by JurgitaG on 4/22/2021.
 */

public class DealPrinciplesController
{
	public class DealPrinciple{
		@AuraEnabled public Id contactId;
		@AuraEnabled public Id accountId;
		@AuraEnabled public Id relationId;
		@AuraEnabled public String firstname;
		@AuraEnabled public String lastname;
		@AuraEnabled public String phone;// mobile phone
		@AuraEnabled public String Roles;
		@AuraEnabled public String key;
		@AuraEnabled public String accountName;
		@AuraEnabled public String email;
		@AuraEnabled public String idNumber;
		@AuraEnabled public String landline;//Landline number will be saved in Phone field
		@AuraEnabled public String relationshipStrength;
	}

	@AuraEnabled
	public static List<DealPrinciple> getAccountContacts(String dealId){
		List<AccountContactRelation> relations = [
				SELECT
						Id, ContactId, AccountId, Relationship_Strength__c, Roles, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Email, Contact.MobilePhone, Contact.ID_Number_Residential_Permit__c
				FROM AccountContactRelation
				WHERE AccountId IN (SELECT Account__c FROM Deal__c WHERE Id =:dealId)
		];
		List<DealPrinciple> dealPrinciples = new List<DealPrinciplesController.DealPrinciple>();
		for (AccountContactRelation relation:relations){
			DealPrinciple aDealPrinciple = new DealPrinciple();
			aDealPrinciple.phone =relation.Contact.MobilePhone;
			aDealPrinciple.email =relation.Contact.Email;
			aDealPrinciple.landline =relation.Contact.Phone;
			aDealPrinciple.firstname =relation.Contact.FirstName;
			aDealPrinciple.lastname =relation.Contact.LastName;
			aDealPrinciple.idNumber =relation.Contact.ID_Number_Residential_Permit__c;
			aDealPrinciple.Roles =relation.Roles;
			aDealPrinciple.contactId =relation.ContactId;
			aDealPrinciple.relationId =relation.Id;
			aDealPrinciple.accountId =relation.AccountId;
			aDealPrinciple.relationshipStrength =relation.Relationship_Strength__c;
			dealPrinciples.add(aDealPrinciple);
		}
		return dealPrinciples;

	}


	@AuraEnabled
	public static String saveContacts(String principlesString, String recordId, String deletedIds){
		List<Deal__c> deals = [SELECT Account__c FROM Deal__c WHERE Id = :recordId];
		if(deals.isEmpty()){
			return 'Deal do not exist!';
		}
		if (deals.get(0).Account__c == null)
		{
			return 'Deal do not have Account!';
		}
		Id accId = deals.get(0).Account__c;

		List<Contact> listForUpdate = new List<Contact>();
		List<Contact> listForInsert = new List<Contact>();
		List<AccountContactRelation> newRelations = new List<AccountContactRelation>();
		List<AccountContactRelation> relationsForUpdate = new List<AccountContactRelation>();
		System.debug(principlesString);
		List<DealPrinciple> principles =(List<DealPrinciple>)System.JSON.deserializeStrict(principlesString, List<DealPrinciple>.Class);
		System.debug(principles);
		Map<String, DealPrinciple> contactMapByPhone = new Map<String, DealPrinciple>();
		Set<Id> contactIds = new Set<Id>();
		for (DealPrinciple principle: principles){

			if (principle.contactId == null)
			{
				Contact aContact = fillContactFields(principle);
				aContact.AccountId = accId;
				contactMapByPhone.put(aContact.MobilePhone, principle);
				listForInsert.add(aContact);
			}
			if (principle.relationId == null && principle.contactId != null && !contactIds.contains(principle.contactId))
			{
				Contact aContact = fillContactFields(principle);
				aContact.Id = principle.contactId;
				contactIds.add(principle.contactId);
				listForUpdate.add(aContact);
				newRelations.add(new AccountContactRelation(ContactId=principle.contactId, AccountId = accId, Roles = principle.Roles, Relationship_Strength__c = principle.relationshipStrength));
			}
			 if (principle.relationId != null && principle.contactId != null && !contactIds.contains(principle.contactId))
			{
				Contact aContact = fillContactFields(principle);
				aContact.Id = principle.contactId;
				listForUpdate.add(aContact);
				contactIds.add(principle.contactId);
				relationsForUpdate.add(new AccountContactRelation(ContactId=principle.contactId, AccountId = accId, Roles = principle.Roles, Id = principle.relationId, Relationship_Strength__c = principle.relationshipStrength));
			}
		}
		insert listForInsert;
		Set<Id> resultIds = (new Map<Id,SObject>(listForInsert)).keySet();
		List<AccountContactRelation> relations = [SELECT
				Id, ContactId, AccountId, Roles, Relationship_Strength__c, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.MobilePhone, Contact.Email, Contact.ID_Number_Residential_Permit__c
		FROM AccountContactRelation WHERE ContactId IN :resultIds
		];
		for (AccountContactRelation relation: relations){
			DealPrinciple aPrinciple = contactMapByPhone.get(relation.Contact.MobilePhone);
			relation.Roles = aPrinciple.Roles;
			relation.Relationship_Strength__c =aPrinciple.relationshipStrength;
			relationsForUpdate.add(new AccountContactRelation(Roles = aPrinciple.Roles, Id = relation.Id, Relationship_Strength__c = aPrinciple.relationshipStrength));
		}
		update listForUpdate;
		update relationsForUpdate;
		insert newRelations;
		List<String> deletedContacts =(List<String>)System.JSON.deserializeStrict(deletedIds, List<String>.Class);
		System.debug(deletedContacts);

		List<Contact> listToDelete = new List<Contact>();
		for (String deletedContact: deletedContacts){
			if (deletedContact instanceof Id) {
				Contact aContact = new Contact();
				aContact.Id = Id.valueOf(deletedContact);
				listToDelete.add(aContact);
			}
		}
		delete listToDelete;
		return 'Success';
	}

	public static Contact fillContactFields(DealPrinciple principle){
		Contact aContact = new Contact();
		aContact.FirstName = principle.firstname;
		aContact.LastName = principle.lastname;
		aContact.MobilePhone = principle.phone;
		aContact.Phone = principle.landline;
		aContact.Email = principle.email;
		aContact.ID_Number_Residential_Permit__c = principle.idNumber;

		return aContact;
	}
}