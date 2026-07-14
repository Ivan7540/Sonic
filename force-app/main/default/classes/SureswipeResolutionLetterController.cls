/**
 * Created by JurgitaG on 11/4/2021.
 * PS-1126
 */

public class SureswipeResolutionLetterController
{
	public class principleDetails
	{
		public String principleName { get; set; }
		public String signaturetext { get; set; }
		public String principleEmail { get; set; }
	}

	public String shippingCity { get; set; }
	public String registrationNumber { get; set; }
	public String resolutionDate { get; set; }
	public String resolutionDay{ get; set; }
	public String resolutionMonth { get; set; }
	public String resolutionYear { get; set; }
	public String company { get; set; }
	public String mainDirectorName { get; set; }
	public String mainDirectorId { get; set; }
	public String mainDirector { get; set; }
	public List<principleDetails> principles { get; set; }

	public final Deal__c deal{get;set;}
	public class ResolutionData{
		@InvocableVariable public String dealId;
		@InvocableVariable public String mainDirector;
	}
	public SureswipeResolutionLetterController()
	{
		this.principles = new List<principleDetails>();
		this.deal = [Select Id,
				Account__c,
				Account__r.Name,
				Account__r.ShippingCity,
				Account__r.RegistrationNumber__c
		From Deal__c
		where Id = : ApexPages.currentPage().getParameters().get('id')];
		String JSONString = ApexPages.currentPage().getParameters().get('JSONString');// this is passedas encoded as saving and querying above does not work
		String decodedJSON = EncodingUtil.urlDecode(JSONString, 'UTF-8');
		system.debug('Decoded:'  + decodedJSON);
		if(!String.isBlank(decodedJSON))
		{
			ResolutionData riskData = (ResolutionData) JSON.deserialize(decodedJSON, ResolutionData.class);
			this.mainDirector = riskData.mainDirector;
		}
		this.shippingCity = this.deal.Account__r.ShippingCity;
		this.company = this.deal.Account__r.Name;
		this.registrationNumber = this.deal.Account__r.RegistrationNumber__c;
		Date d = Date.today();
		Integer y = d.year();
		Integer m = d.month();
		Integer day = d.day();
		DateTime dt = DateTime.newInstance(y,m,day);
		this.resolutionYear = dt.format('YYYY');
		this.resolutionDay = day.format();
		this.resolutionMonth = dt.format('MMMM');
		Integer i= 1;
		for (AccountContactRelation principle : [
				SELECT Id, Contact.Name,ContactId,Contact.ID_Number_Residential_Permit__c, Contact.Email
				FROM AccountContactRelation
				WHERE AccountId=:deal.Account__c AND Roles INCLUDES ('Director') ORDER BY CreatedDate ASC]){
			if(mainDirector == principle.ContactId){
				this.mainDirectorName=principle.Contact.Name;
				this.mainDirectorId = principle.Contact.ID_Number_Residential_Permit__c;
			}
			principleDetails principleItem = new principleDetails();
			principleItem.principleName = principle.Contact.Name;
			principleItem.principleEmail = principle.Contact.Email;
			principleItem.signaturetext = 'signer' + i;
			this.principles.add(principleItem);
			i++;
		}

	}

	@InvocableMethod
	public Static List<Id> saveResolutionData(List<ResolutionData> inputs){
		List<Id> contentDocumentIds = new List<Id>();
		Set<Id> dealIds = new Set<Id>();
		for(ResolutionData eachInput : inputs){
			dealIds.add(eachInput.dealId);
		}
		Map<Id, Deal__c> dealsMap = new Map<Id, Deal__c>([Select Id,
				Account__c,
				Account__r.Name
		From Deal__c
		where Id in :dealIds]);


		//Generate PDF and attach to deal with tag
		for(ResolutionData eachInput : inputs){
			contentDocumentIds.add(generateAndSavePDF(eachInput.dealId, EncodingUtil.urlEncode(JSON.serialize(eachInput),'UTF-8')));
		}
		return contentDocumentIds;
	}
	public static Id generateAndSavePDF(Id dealId, string URLEncodedJSONString){
		PageReference riskPDF = new PageReference('/apex/SureswipeResolutionLetter?id=' + dealId + '&JSONString=' + URLEncodedJSONString);
		//Create Document
		ContentVersion cv = new ContentVersion();
		cv.Title = 'Resolution Letter';
		cv.PathOnClient = 'ResolutionLetter.pdf';
		cv.DocumentType_fileupload__c = 'Resolution Letter';
		cv.TagCsv = 'Resolution Letter';
		if(Test.isRunningTest()){
			cv.VersionData = Blob.valueOf('Test Content');
		}else{
			cv.VersionData = riskPDF.getContentAsPDF();
		}

		cv.Origin = 'C';
		Insert cv;
		Id conDoc = [SELECT
				ContentDocumentId
		FROM ContentVersion
		WHERE Id =:cv.Id].ContentDocumentId;
		//Create ContentDocumentLink
		ContentDocumentLink cDe = new ContentDocumentLink();
		cDe.ContentDocumentId = conDoc;
		cDe.LinkedEntityId = dealId;
		cDe.ShareType = 'I';
		insert cDe;
		return conDoc;
	}
}