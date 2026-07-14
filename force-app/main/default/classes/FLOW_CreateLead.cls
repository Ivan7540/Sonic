/**
 * Created by JurgitaG on 2/4/2021.
 */

public without sharing class FLOW_CreateLead
{

	@InvocableMethod(label='Create Lead' category='Lead')
	public static List<Id> createLead(List<LeadRequest> requests)
	{
		List<Id> leadIds = new List<Id>();
		List<Lead> leadsToCreate = new List<Lead>();
		for (LeadRequest aRequest : requests)
		{
			Lead aLead = new Lead();
			aLead.FirstName = aRequest.firstname;
			aLead.LastName = aRequest.lastname;
			aLead.Company = aRequest.company;
			aLead.Phone = aRequest.landline;
			aLead.MobilePhone = aRequest.phone;
			aLead.Email = aRequest.email;
			leadsToCreate.add(aLead);
		}
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult[] results = Database.insert(leadsToCreate, dml);

		for (Database.SaveResult res : results)
		{

			if (res.isSuccess())
			{
				// Operation was successful, so get the ID of the record that was processed
				System.debug('Successfully inserted Lead. Lead ID: ' + res.getId());
				leadIds.add(res.getId());

			}
		}
		return leadIds;
	}
	public class LeadRequest
	{
		@InvocableVariable(label='First Name' description='' required=true)
		public String firstname;

		@InvocableVariable(label='LastName' description=''required=true)
		public String lastname;

		@InvocableVariable(label='Company' description='')
		public String company;

		@InvocableVariable(label='Phone' description='' required=true)
		public String phone;
		@InvocableVariable(label='Landline Phone' description='')
		public String landline;
		@InvocableVariable(label='Email' description='')
		public String email;
	}

}