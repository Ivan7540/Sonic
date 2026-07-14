global class HelloSignRequestParams {
    @AuraEnabled @InvocableVariable(description='ID of template')
    global String sfdcTemplateId;
    @AuraEnabled @InvocableVariable(description='ID of the source object such as account, contact, opportunity')
    global String originObjectId;
    @AuraEnabled @InvocableVariable(description='List must have the Roles and signers. Eg: ("BAM","Swapnil Walse", "swapnil.walse@tetrad.co.za")')
    global List<HelloSignSignerName> signerNames;
    @AuraEnabled @InvocableVariable(description='This record is created later in case you want to call sendWithTemplate() for a list of records')
    global Boolean sendImmediately;
    @AuraEnabled @InvocableVariable(description='The signature request will not be legally binding when set to true.')
    global Boolean isTestMode;
    @AuraEnabled @InvocableVariable(description='Title of the request, specify when not using template')
    global String reqTitle;
    @AuraEnabled @InvocableVariable(description='Subject of the request, specify when not using template')
    global String reqSubject;
    @AuraEnabled @InvocableVariable(description='Message of the request, specify when not using template')
    global String reqMessage;
    @AuraEnabled @InvocableVariable(description='SF ContentDocumentId of content that needs to be sent to client for signing, specify when not using template')
    global List<String> documentIds;
    @AuraEnabled @InvocableVariable(description='CC list of emails, specify when not using template')
    global List<String> ccEmail; 

}