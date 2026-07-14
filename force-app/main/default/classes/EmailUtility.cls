/****************************************		
 Created By : Kumar
 Date : 15/03/2022
 Description: The below method sends email and log as an activity. 
 If the Lead is converted, email will be sent to the lead and an email activity will be created under the Deal and Lead object.
 If the Lead is not converted, email will be sent to the lead and a task will be created under the Lead object only.
****************************************/
public without sharing class EmailUtility {
    public class requestParam{
        @InvocableVariable public String recordId;
        @InvocableVariable public String targetObjectId;
        @InvocableVariable public String templateDeveloperName;
    }
    @InvocableMethod(label='Send Email and Log Activity' description='Send Email and Log Activity')
    public static void SendEmailAndLogActivity(List<requestParam> inputs){
        
        Id recordId;
        String targetObjectId;
        String templateDeveloperName;
        String leadId;
        String convertedContactId;
        
        For(EmailUtility.requestParam input:inputs){
            recordId = Id.valueOf(input.recordId);
            targetObjectId = input.targetObjectId;
            templateDeveloperName = input.templateDeveloperName;
        }        
        
        EmailTemplate emailTemplate = [Select Id, DeveloperName from EmailTemplate where DeveloperName =: templateDeveloperName];
        
        if(String.isBlank(targetObjectId) && recordId.getSObjectType().getDescribe().getName() == 'Deal__c'){
            List<Deal__c> dealList = [Select Id,Lead__c,Lead__r.ConvertedContactId  From Deal__c Where Id =: recordId];
            For(Deal__c aDeal:dealList){
                leadId = aDeal.Lead__c;
                convertedContactId = aDeal.Lead__r.ConvertedContactId;
            } 
        }      
        
        Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
        email.setTemplateId(emailTemplate.Id);
        email.setTargetObjectId(String.isBlank(targetObjectId)?(String.isBlank(convertedContactId)?leadId:convertedContactId):targetObjectId);
        
        if(String.isNotBlank(recordId) && String.isNotBlank(convertedContactId)){
        	email.setWhatId(recordId);    
        }        
        
        for(OrgWideEmailAddress owd:[SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Sureswipe'])
        {
            email.setOrgWideEmailAddressId(owd.Id);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        if (results[0].success) 
        {            
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }
    
}