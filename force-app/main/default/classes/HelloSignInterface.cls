/**
* Author	:	Swapnil Walse
* Date		:	19 April 2021
* Desc		:	Interface to hellosign APIs.  
* 			:	
* 			:	 
* 
**/
global class HelloSignInterface {
    public static final String redirectURL = 'https://www.sureswipe.co.za'; //currently there is a constant url
    
    //returns the most recent created request details, either provide the signature request id, or pass object id
    public static HelloSign.ServiceObjects.SignatureRequestResponse getRecentSigningRequest(Id sigReqOrObjectId){
        String sObjectName = String.valueOf(sigReqOrObjectId.getSObjectType());
        HelloSign__HelloSign_Signature_Request__c thisRecord;
        
        if(!String.isBlank(sigReqOrObjectId) && sObjectName == 'HelloSign__HelloSign_Signature_Request__c'){
            thisRecord = [SELECT Id,
                          HelloSign__Signature_Request_ID__c,
                          HelloSign__Document_Name__c,
                          HelloSign__Message2__c,
                          HelloSign__Total_Signers__c,
                          HelloSign__Completed_Signers__c,
                          HelloSign__Latest_Action__c,
                          HelloSign__Active__c,
                          HelloSign__Related_Object_Id__c,
                          HelloSign__Opportunity__c,
                          HelloSign__Account__c,
                          HelloSign__Contact__c,
                          HelloSign__Lead__c
                          FROM HelloSign__HelloSign_Signature_Request__c
                          WHERE Id = :sigReqOrObjectId
                          Order by CreatedDate Desc
                          Limit 1];
        }else if(sObjectName == 'Account' && !String.isBlank(sigReqOrObjectId)){
            thisRecord = [SELECT Id,
                          HelloSign__Signature_Request_ID__c,
                          HelloSign__Document_Name__c,
                          HelloSign__Message2__c,
                          HelloSign__Total_Signers__c,
                          HelloSign__Completed_Signers__c,
                          HelloSign__Latest_Action__c,
                          HelloSign__Active__c,
                          HelloSign__Related_Object_Id__c,
                          HelloSign__Opportunity__c,
                          HelloSign__Account__c,
                          HelloSign__Contact__c,
                          HelloSign__Lead__c
                          FROM HelloSign__HelloSign_Signature_Request__c
                          WHERE HelloSign__Account__c = :sigReqOrObjectId
                          Order by CreatedDate Desc
                          Limit 1];
        }else if(sObjectName == 'Opportunity' && !String.isBlank(sigReqOrObjectId)){
            thisRecord = [SELECT Id,
                          HelloSign__Signature_Request_ID__c,
                          HelloSign__Document_Name__c,
                          HelloSign__Message2__c,
                          HelloSign__Total_Signers__c,
                          HelloSign__Completed_Signers__c,
                          HelloSign__Latest_Action__c,
                          HelloSign__Active__c,
                          HelloSign__Related_Object_Id__c,
                          HelloSign__Opportunity__c,
                          HelloSign__Account__c,
                          HelloSign__Contact__c,
                          HelloSign__Lead__c
                          FROM HelloSign__HelloSign_Signature_Request__c
                          WHERE HelloSign__Opportunity__c = :sigReqOrObjectId
                          Order by CreatedDate Desc
                          Limit 1];
        }else if(sObjectName == 'Contact' && !String.isBlank(sigReqOrObjectId)){
            thisRecord = [SELECT Id,
                          HelloSign__Signature_Request_ID__c,
                          HelloSign__Document_Name__c,
                          HelloSign__Message2__c,
                          HelloSign__Total_Signers__c,
                          HelloSign__Completed_Signers__c,
                          HelloSign__Latest_Action__c,
                          HelloSign__Active__c,
                          HelloSign__Related_Object_Id__c,
                          HelloSign__Opportunity__c,
                          HelloSign__Account__c,
                          HelloSign__Contact__c,
                          HelloSign__Lead__c
                          FROM HelloSign__HelloSign_Signature_Request__c
                          WHERE HelloSign__Contact__c = :sigReqOrObjectId
                          Order by CreatedDate Desc
                          Limit 1];
        }else if(sObjectName == 'Lead' && !String.isBlank(sigReqOrObjectId)){
            thisRecord = [SELECT Id,
                          HelloSign__Signature_Request_ID__c,
                          HelloSign__Document_Name__c,
                          HelloSign__Message2__c,
                          HelloSign__Total_Signers__c,
                          HelloSign__Completed_Signers__c,
                          HelloSign__Latest_Action__c,
                          HelloSign__Active__c,
                          HelloSign__Related_Object_Id__c,
                          HelloSign__Opportunity__c,
                          HelloSign__Account__c,
                          HelloSign__Contact__c,
                          HelloSign__Lead__c
                          FROM HelloSign__HelloSign_Signature_Request__c
                          WHERE HelloSign__Lead__c = :sigReqOrObjectId
                          Order by CreatedDate Desc
                          Limit 1];
        }else if(sObjectName == 'Deal__c'&& !String.isBlank(sigReqOrObjectId)){
            thisRecord = [SELECT Id,
                          HelloSign__Signature_Request_ID__c,
                          HelloSign__Document_Name__c,
                          HelloSign__Message2__c,
                          HelloSign__Total_Signers__c,
                          HelloSign__Completed_Signers__c,
                          HelloSign__Latest_Action__c,
                          HelloSign__Active__c,
                          HelloSign__Related_Object_Id__c,
                          HelloSign__Opportunity__c,
                          HelloSign__Account__c,
                          HelloSign__Contact__c,
                          HelloSign__Lead__c
                          FROM HelloSign__HelloSign_Signature_Request__c
                          WHERE Deal__c = :sigReqOrObjectId
                          Order by CreatedDate Desc
                          Limit 1];
        }
        
        HelloSign.SignatureRequestService sigReq = new HelloSign.SignatureRequestService(thisRecord.HelloSign__Signature_Request_ID__c);
        HelloSign.ServiceObjects.SignatureRequestResponse response;
        if(!Test.isRunningTest()) response = sigReq.get();
        
        // Object type: HelloSign.ServiceObjects.SignatureRequest
        //System.debug(response.signature_request);
        
        // Object type: List<HelloSign.ServiceObjects.Warning>
        //System.debug(response.warnings);
        return response;
    }
    
    //Method to send remote signing request with a predefined template
    //the caller needs to ensure that the signers role on template and the request match
    public static HelloSign.ServiceObjects.SignatureRequestResponse sendSigningRequestWithTemplate
        (Id sfdcTemplateId,//ID of template
         Id originObjectId,// ID of the source object such as account, contact, opportunity
         Map<String, Map<String,String>> signerNames,// Map must have the Roles and signers. Eg: ("BAM",{"Swapnil Walse", "swapnil.walse@tetrad.co.za"})
         Boolean sendImmediately,// This record is created later in case you want to call sendWithTemplate() for a list of records
         Boolean isTestMode) //The signature request will not be legally binding when set to true.
    {
        HelloSign.SignatureRequestService sigReq = new HelloSign.SignatureRequestService();
        
        /** Required Params **/
        HelloSign__Template__c sfdcTemplate = [SELECT Id,
                                               Name,
                                               HelloSign__Title__c,
                                               HelloSign__Message2__c,
                                               HelloSign__TemplateUUID__c
                                               FROM HelloSign__Template__c
                                               WHERE Id = :sfdcTemplateId];
        
        // Use the HelloSign__TemplateUUID__c to set our template_id
        sigReq.template_id = sfdcTemplate.HelloSign__TemplateUUID__c;
        
        List<HelloSign__SignerRole__c> signerList = [SELECT Id,
                                                     HelloSign__Role_Name__c,
                                                     HelloSign__RoleType__c,
                                                     HelloSign__IsCcRole__c,
                                                     HelloSign__SignerOrder__c,
                                                     HelloSign__SpecificContact__c,
                                                     HelloSign__SpecificContact__r.Name,
                                                     HelloSign__SpecificContact__r.Email,
                                                     HelloSign__SpecificUser__c,
                                                     HelloSign__SpecificUser__r.Name,
                                                     HelloSign__SpecificUser__r.Email,
                                                     HelloSign__SpecificEmail__c,
                                                     HelloSign__SpecificFirstName__c
                                                     FROM HelloSign__SignerRole__c
                                                     WHERE HelloSign__Template__c = :sfdcTemplateId
                                                     Order By HelloSign__SignerOrder__c Asc];
        
        sigReq.signers = new Map<String, HelloSign.ServiceObjects.Signer>();
        
        HelloSign.ServiceObjects.Signer signerObj;
        for (HelloSign__SignerRole__c rec : signerList) {
            if(!rec.HelloSign__IsCcRole__c){
                // Note: If a value is provided in the input map, then that value will be used, else default value 
                // in HelloSign__SpecificContact__c  or HelloSign__SpecificUser__c will be used
                if(signerNames.containsKey(rec.HelloSign__Role_Name__c)){
                    list<string> names = new List<string>(signerNames.get(rec.HelloSign__Role_Name__c).keySet());
                    system.debug('Role: ' + rec.HelloSign__Role_Name__c);
                    system.debug('Name: ' + names[0]);
                    system.debug('email: ' + signerNames.get(rec.HelloSign__Role_Name__c).get(names[0]));
                    signerObj = new HelloSign.ServiceObjects.Signer(
                        signerNames.get(rec.HelloSign__Role_Name__c).get(names[0]),
                        names[0]);
                    signerObj.order = Integer.valueOf(rec.HelloSign__SignerOrder__c);
                }else if(rec.HelloSign__RoleType__c == 'Specific Contact'){
                    //no override contact provided, now use default if specified
                    if(rec.HelloSign__SpecificContact__c != null){
                        signerObj = new HelloSign.ServiceObjects.Signer(
                            rec.HelloSign__SpecificContact__r.Email,
                            rec.HelloSign__SpecificContact__r.Name);
                        signerObj.order = Integer.valueOf(rec.HelloSign__SignerOrder__c);
                    }else system.debug('For Role: ' + rec.HelloSign__Role_Name__c + ' of Type: ' + rec.HelloSign__RoleType__c + ' no default contact specified');
                    
                }else if(rec.HelloSign__RoleType__c == 'Specific User'){
                    if(rec.HelloSign__SpecificUser__c != null){
                        signerObj = new HelloSign.ServiceObjects.Signer(
                            rec.HelloSign__SpecificUser__r.Email,
                            rec.HelloSign__SpecificUser__r.Name);
                        signerObj.order = Integer.valueOf(rec.HelloSign__SignerOrder__c);
                    }else system.debug('For Role: ' + rec.HelloSign__Role_Name__c + ' of Type: ' + rec.HelloSign__RoleType__c + ' no default user specified');
                }else if(rec.HelloSign__RoleType__c == 'Specific Email'){
                    signerObj = new HelloSign.ServiceObjects.Signer(
                        rec.HelloSign__SpecificEmail__c,
                        rec.HelloSign__SpecificFirstName__c + ' ' + rec.HelloSign__SpecificLastName__c);
                    signerObj.order = Integer.valueOf(rec.HelloSign__SignerOrder__c);
                }
                // Adding signers for our request is role based, which is why we put the Role Name as our key
                sigReq.signers.put(rec.HelloSign__Role_Name__c, signerObj);
            }//End I(!rec.HelloSign__IsCcRole__c)
        }//End For
        //System.debug('Signers: ' + sigReq.signers);
        /** Optional Params **/
        sigReq.test_mode = isTestMode;
        sigReq.originObjectId = originObjectId;
        sigReq.allow_decline = true;
        sigReq.template_id = sfdcTemplate.HelloSign__TemplateUUID__c;
        sigReq.title = sfdcTemplate.Name;
        sigReq.subject = sfdcTemplate.HelloSign__Title__c;
        sigReq.message = sfdcTemplate.HelloSign__Message2__c;
        sigReq.signing_redirect_url = redirectURL;
        //system.debug('SigReq: ' + sigReq);
        sigReq.ccs = new Map<String, HelloSign.ServiceObjects.CC>();
        
        //Add CC list now
        /*for (HelloSign__SignerRole__c rec : signerList) {
if(rec.HelloSign__IsCcRole__c){
String ccEmail;

// Note: If no value is populated in the lookup, HelloSign__SpecificContact__c, for example
// then you need to provide your own value
if (rec.HelloSign__Role_Name__c.startsWith('Contact')) {
ccEmail = rec.HelloSign__SpecificContact__r.Email;

} else if (rec.HelloSign__Role_Name__c.startsWith('User')) {
ccEmail = rec.HelloSign__SpecificUser__r.Email;

} else {
ccEmail = rec.HelloSign__SpecificEmail__c;
}
sigReq.ccs.put(rec.HelloSign__Role_Name__c, new HelloSign.ServiceObjects.CC(ccEmail));
}
}*/
        
        // Append additional file to the signature request
        //ContentVersion cvRec = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'myFile.pdf' LIMIT 1];
        //sigReq.fileIds = new List<Id>{ cvRec.ContentDocumentId };
        
        // Can use this to send
        HelloSign.ServiceObjects.SignatureRequestResponse response;
        if(sendImmediately){
            if(!Test.isRunningTest()) response = sigReq.sendWithTemplate();
        }else{
            // Do not create HelloSign_Signature_Request__c record immediately.
            // This record is created later in case you want to call sendWithTemplate() for a list of records
            if(!Test.isRunningTest()) response = sigReq.sendWithTemplate(false);
        }
        
        // object type: HelloSign.ServiceObjects.SignatureRequest
        //System.debug(response.signature_request);
        
        // object type: HelloSign_Signature_Request__c
        //System.debug(response.signatureRequestRecord);
        
        // object type: List<HelloSign.ServiceObjects.Warning>
        //System.debug(response.warnings);
        return response;
    }
    
    //Method to send signing request without a template.
    //Can be completely configured and used for adhoc signing
    //Signer names are always signer0, signer1 etc, and the same text tags must be used in document templates`
    public static HelloSign.ServiceObjects.SignatureRequestResponse sendSigningRequest(Id originObjectId, String reqTitle, String reqSubject, String reqMessage, 
                                                                                       List<Id> documentIds, List<HelloSignSignerName> signers, List<String> ccEmails,
                                                                                       Boolean sendImmediately, Boolean isTestMode)
    {
        HelloSign.SignatureRequestService sigReq = new HelloSign.SignatureRequestService();
        sigReq.fileIds = documentIds;        
        // Adding signers for our request are index based, which is why we are putting 0 as our key
        // Note: this is a string because sendWithTemplate for example is RoleName not index based    
        sigReq.signers = new Map<String, HelloSign.ServiceObjects.Signer>();
        Integer signerIndex = 0;
        for( HelloSignSignerName eachSigner : signers){
            sigReq.signers.put(String.valueOf(signerIndex), 
                               new HelloSign.ServiceObjects.Signer(eachSigner.emailAddress,
                                                                   eachSigner.name)
                              );
            signerIndex++;
        }
        
        /** Optional Params **/
        sigReq.test_mode = isTestMode; //The signature request will not be legally binding when set to true.
        sigReq.originObjectId = originObjectId;
        sigReq.title = reqTitle;
        sigReq.subject = reqSubject;
        sigReq.message = reqMessage;
        sigReq.signing_redirect_url = redirectURL;
        sigReq.cc_email_addresses = ccEmails;
        sigReq.allow_decline = true;
        sigReq.allow_reassign = true;
        sigReq.use_text_tags = true; //Any text tags in the document will be intepreted
        sigReq.hide_text_tags = false;	//When using Text Tags it is preferred that you set this to false and hide 
        								//your tags with white text or something similar because the automatic removal
        								//system can cause unwanted clipping.
        
        //Require a specific signer to upload an attachment
        //HelloSign.ServiceObjects.Attachment_x attachObj = new HelloSign.ServiceObjects.Attachment_x();
        //attachObj.name = 'Supplemental Attachment';
        //attachObj.instructions = 'Please attach any supplemental information, thank you.';
        //attachObj.required = false;
        //attachObj.signer_index = 0;
        //sigReq.attachments = new Map<Integer, HelloSign.ServiceObjects.Attachment_x>();
        //sigReq.attachments.put(0, attachObj);
        
        // Specify which signing options are allowed for the signer
        sigReq.signing_options = new HelloSign.ServiceObjects.SigningOptions();
        sigReq.signing_options.draw = true;
        sigReq.signing_options.phone = false;
        sigReq.signing_options.type_x = true;
        sigReq.signing_options.upload = false;
        sigReq.signing_options.default_x = 'draw';
        
        sigReq.field_options = new HelloSign.ServiceObjects.FieldOptions();
        //sigReq.field_options.date_format = 'YYYY / MM / DD';
        
        HelloSign.ServiceObjects.SignatureRequestResponse response;
        if(sendImmediately){
            // send immediately
            if(!Test.isRunningTest()) response = sigReq.send();
        }else{
            // Do not create HelloSign_Signature_Request__c record immediately.
            // This record is created later in case you want to call send() for a list of records
            if(!Test.isRunningTest()) response = sigReq.send(false);
        }
        return response;
    }

    //Method to update a signing request
    //Updates the email address for a given signer on a signature request.
    //To change any other aspect of singing request, existing must be cancelled and new one sent.
/*    public static HelloSign.ServiceObjects.SignatureRequestResponse updateSigningRequest(String sigReqId, String signatureId, string newEmailAddress){
        String oldEmailAddress;
        HelloSign.SignatureRequestService sigReq = new HelloSign.SignatureRequestService(sigReqId);
        
        // Make a get call to retrieve the signature request information
        HelloSign.ServiceObjects.SignatureRequestResponse sigReqResponse = sigReq.get();
        
        // Select the first signer. The signature_request.signatures returns a List<HelloSign.ServiceObjects.Signature>
        List<HelloSign.ServiceObjects.Signature> signers = sigReqResponse.signature_request.signatures;
        for(HelloSign.ServiceObjects.Signature eachSigner : signers){
            if(eachSigner.signature_id == signatureId){
                oldEmailAddress = eachSigner.signer_email_Address;
                sigReq.signature_id = eachSigner.signature_id;
                sigReq.email_address = newEmailAddress;
            }
        }
        HelloSign.ServiceObjects.SignatureRequestResponse response = sigReq.updateRequest();
        
        // Object type: HelloSign.ServiceObjects.SignatureRequest
        //System.debug(response.signature_request);
        
        // Object type: List<HelloSign.ServiceObjects.Warning>
        //System.debug(response.warnings);
        return response;
    }*/
    
    //Method to cancel signing request. Use standard OOB flow method
    /*public static String cancelSigningRequest(String sigReqId){
        String sigReqUUId = [
            SELECT HelloSign__Signature_Request_ID__c
            FROM HelloSign__HelloSign_Signature_Request__c
            WHERE Id = :sigReqId].HelloSign__Signature_Request_ID__c;
        
        // Returns the 200 status code
        String statusCode;
        if(!Test.isRunningTest()) statusCode = new HelloSign.SignatureRequestService(sigReqUUId).cancel();
        return statusCode;
    }*/
    
    //Generic method to convert SF datetime to unix datetime, needed by some methods in HelloSign
    //any timing from hellosign comes in unix format.
    public static DateTime convertUnixDateTime(long unixTime){
        //Below code supports for both 10 and 13 digit unix time conversion. Mostly will be 10 digit
        if(unixTime == null){
            return null;
        }else if(unixTime < 9999999999L){// check if 10 digit
            return Datetime.newInstance(unixTime * 1000L);
        }else{
            return Datetime.newInstance(unixTime);
        }
    }
}