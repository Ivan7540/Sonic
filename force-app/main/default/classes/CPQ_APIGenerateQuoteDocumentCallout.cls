/**
* Author	:	Swapnil Walse
* Date		:	07 May 2021
* Desc		:	callout class to generate quote document
* 			:	CPQ creates a job to generate document. return parameter is job id
* 			:	It is assumed that the template id to be used is populated on the quote record in 
*               SBQQ__QuoteTemplateId__c field, if not provided in input.
* 				
**/
@RestResource(urlMapping='/SonicCPQ/GenerateQuoteDocument')
global class CPQ_APIGenerateQuoteDocumentCallout {
    
    global class requestParams{
        public Id quoteId;
        public String templateId;
        String documentName;
    }
	@HttpPost
    global static List<String> generateQuoteDocument(List<requestParams> inputs){
        List<String> jobIds = new List<String>();
        
        for(requestParams eachInput : inputs){
            //if template id is null it is assumed it is on the quote record, if not global default template will be used.
            Id templateId = String.isBlank(eachInput.templateId)? null:eachInput.templateId;
            String jobId = CPQ_APIWrapper.generateQuoteProposal(eachInput.quoteId, eachInput.documentName, null, null, templateId, null);  
            if(!String.isBlank(jobId)) jobIds.add(jobId.replaceAll('"', ''));
        }
        return jobIds;
    }
}