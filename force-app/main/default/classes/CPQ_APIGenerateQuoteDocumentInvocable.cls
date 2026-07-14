/**
* Author	:	Swapnil Walse
* Date		:	13 April 2021
* Desc		:	Invocable class to generate quote document
* 			:	CPQ creates a job to generate document. return parameter is job id
* 			:	It is assumed that the template id to be used is populated on the quote record in 
*               SBQQ__QuoteTemplateId__c field, if not provided in input.
* 
**/
public class CPQ_APIGenerateQuoteDocumentInvocable {
    public class requestParams{
        @InvocableVariable(label='Document Name' required=false) public String documentName;
        @InvocableVariable(label='Quote Id' required=true) public Id quoteId;
        @InvocableVariable(label='Template Id' description='Id of template to be used, leave blank if specified on quote record') public String templateId;
    }
	@InvocableMethod
    public static List<String> generateQuoteDocument(List<requestParams> inputs){
        List<String> jobIds = new List<String>();
        
        for(requestParams eachInput : inputs){
            //if template id is null it is assumed it is on the quote record, if not global default template will be used.
            if(Schema.sObjectType.SBQQ__QuoteTemplate__c.isAccessible()){
                jobIds.add(CPQ_APIWrapper.generateQuoteProposal(eachInput.quoteId, eachInput.documentName, null, null, eachInput.templateId, null));
            }else{
                //Make Flowgear Call
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Flowgear/Salesforce/CPQ/GenerateQuoteDocument');
                req.setMethod('POST');
                req.setTimeout(100000);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(eachInput));

                Http http = new Http();
                HttpResponse resp = http.send(req);
                Map<String, String> responseValues = (Map<String, String>)JSON.deserialize(resp.getBody(), Map<String, String>.class);
                jobIds.add(responseValues.get('jobId'));
            }
        }
        return jobIds;
    }
}