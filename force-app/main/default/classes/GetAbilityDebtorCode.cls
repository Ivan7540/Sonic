/*
Date created: 07/06/2021
Developer: Ajit Gopu
JIRA number: PS-517
*/
public class GetAbilityDebtorCode {
    
    //Set default values for record
    Public Static Integer busStreetCountryNo = 1;
    Public Static Integer busStreetStateNo = 0;
    Public Static Integer busPostalCountryNo = 0;
    Public Static Integer busPostalStateNo = 0;
    Public Static Integer busTypeNo = 0;
    Public Static Integer personStreetCountryNo = 0;
    Public Static Integer personStreetStateNo = 0;
    Public Static Integer personPostalCountryNo = 0;
    Public Static Integer personPostalStateNo = 0;
    Public Static Integer languageNo = 1;
    Public Static String drSalesTaxNo;
    
    //Get username, password and endpoint from custom setting
    public static serviceFacade__c access = serviceFacade__c.getInstance();
    
    
    //Response List
    public class response {
        public String accountId;	
        public String response;	
    }
    
    //Change JSON Object to List
    public static response parse(String responseJSON) {
        return (response) System.JSON.deserialize(responseJSON, response.class);
    }
    
    public static HttpRequest getInfoFromServiceFacade (String endpoint, String username, String password, String message) {
        system.debug('getInfoFromServiceFacade Endpoint: ' + endpoint);
        system.debug('getInfoFromServiceFacade Username: ' + username);
        system.debug('getInfoFromServiceFacade Password: ' + password);
        system.debug('getInfoFromServiceFacade Message: ' + message);
        //Instantiate a new HTTp request, specify the method (PUT) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('PUT');
        req.setTimeout(120000);
        
        // Specify the required user name and password to access the endpoint
        // As well as the header, header information and body
        String headerValue = String.valueOf(password);
        String authorizationHeader = headerValue;
        req.setHeader('x-auth', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        req.setBody(message);
        
        return req;
    }
    
    public static HttpResponse responseFromServiceFacade(HttpRequest request) {
        //Instantiate a new http object
        Http h = new Http();
        
        // Send the request, and return a response
        HttpResponse res = h.send(request);
        return res;
    }
	 public static String generateJSONNew (
        
        String contractId,
        String businessName,
        String regNo,
        String busStreetAddr1,
        String busStreetCountryNo,
        String busStreetCityName,
        String busStreetStateNo,
        String busStreetPostCodeNo,
        String busPostalAddr1,
        String busPostalCountryNo,
        String busPostalCityName,
        String busPostalStateNo,
        String busPostalPostCodeNo,
        String busTelNo,
        String busTypeNo,
        String title,
        String surname,
        String christianName,
        String personStreetCountryNo,
        String personStreetStateNo,
        String personPostalCountryNo,
        String personPostalStateNo,
        String personWorkTelNo,
        String languageNo,
        String cellNo,
        String email,
        String aceCode,
        String areCode
        
    ) {
        
        //Generate the JSON Object
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('contractId', contractId);
        if(businessName != null) {
            gen.writeStringField('businessName', businessName);
        }
        if(regNo != null) {
            gen.writeStringField('regNo', regNo);
        }
        if(busStreetAddr1 != null) {
            gen.writeStringField('busStreetAddr1', busStreetAddr1);
        }
        if(busStreetCountryNo != null) {
            gen.writeNumberField('busStreetCountryNo',integer.valueof(busStreetCountryNo));
        }
        if(busStreetCityName != null) {
            gen.writeStringField('busStreetCityName', busStreetCityName);
        }
        if(busStreetStateNo != null) {
            gen.writeNumberField('busStreetStateNo',integer.valueof(busStreetStateNo) );
        }
        if(busStreetPostCodeNo != null) {
            gen.writeStringField('busStreetPostCodeNo', busStreetPostCodeNo);
        }
        if(busPostalAddr1 != null) {
            gen.writeStringField('busPostalAddr1', busPostalAddr1);
        }
        if(busPostalCountryNo != null) {
            gen.writeNumberField('busPostalCountryNo',integer.valueof(busPostalCountryNo) );
        }
        if(busPostalCityName != null) {
            gen.writeStringField('busPostalCityName', busPostalCityName);
        }
        if(busPostalStateNo != null) {
            gen.writeNumberField('busPostalStateNo',integer.valueof(busPostalStateNo) );
        }
        if(busPostalPostCodeNo != null) {
            gen.writeStringField('busPostalPostCodeNo', busPostalPostCodeNo);
        }
        if(busTelNo != null) {
            gen.writeStringField('busTelNo', busTelNo);
        }
        if(busTypeNo != null) {
            gen.writeNumberField('busTypeNo',integer.valueof(busTypeNo) );
        }
        if(title != null) {
            gen.writeStringField('title', String.valueof(title));
        }
        if(surname != null) {
            gen.writeStringField('surname', surname);
        }
        if(christianName != null) {
            gen.writeStringField('christianName', christianName);
        }
        if(personStreetCountryNo != null) {
            gen.writeNumberField('personStreetCountryNo',integer.valueof(personStreetCountryNo) );
        }
        if(personStreetStateNo != null) {
            gen.writeNumberField('personStreetStateNo',integer.valueof(personStreetStateNo) );
        }
        if(personPostalCountryNo != null) {
            gen.writeNumberField('personPostalCountryNo',integer.valueof(personPostalCountryNo) );
        }
        if(personPostalStateNo != null) {
            gen.writeNumberField('personPostalStateNo',integer.valueof(personPostalStateNo) );
        }
        if(personWorkTelNo != null) {
            gen.writeStringField('personWorkTelNo', personWorkTelNo);
        }
        if(languageNo != null) {
            gen.writeNumberField('languageNo',integer.valueof(languageNo) );
        }
        if(cellNo != null) {
            gen.writeStringField('cellNo', cellNo);
        }
        if(email != null) {
            gen.writeStringField('email', email);
        }
        if(aceCode != null) {
            gen.writeStringField('aceCode', aceCode);
        }
        if(areCode != null) {
            gen.writeStringField('areCode', areCode);
        }
        
        String message = gen.getAsString();
        return message;
    }
    
    //Send mail on error with message and status
    public static void mail (String message, String status, String statusCode) {
        if(access.emailalerts__c) {
            System.debug('There was an error calling the Service Facade : HTTP Request -> getAbilityDebtorCode : Method -> getDebtorIds');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {access.email__c};
                mail.setToAddresses(toAddresses);
            mail.setSubject('getAbilityDebtorCode: Error calling the Service Facade');
            mail.setHTMLBody('<p><b>Message:</b> ' + message + '</p>' +
                             '<p><b>Status:</b> ' + status + '</p>' + 
                             '<p><b>Status Code:</b> ' + statusCode + '</p>');
            //SWW:2020-05-26:: put condition so it does not fail on sandbox
            if(!test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    @future (callout=true)
    public static void updateAccount(List<Id> oppId)
    {	
        system.debug('updateAccount oppId = '+oppId);
        if(oppId.size() > 0){
            Map<Id,Account> debtorCodeList = new Map<Id,Account>(DAL_Account.fordebtorCodeJSON(oppId));
            system.debug('updateAccount debtorCodeList = '+debtorCodeList);
            if(debtorCodeList.size() > 0){
                //for(Account acc: debtorCodeList.values()){
                for(Id c: debtorCodeList.keyset()){
                    String message;
                    message =generateJSONNew(debtorCodeList.get(c).Id,debtorCodeList.get(c).Name,debtorCodeList.get(c).RegistrationNumber__c,debtorCodeList.get(c).BillingStreet,
                                                 '1',debtorCodeList.get(c).BillingCity,'0',debtorCodeList.get(c).BillingPostalCode,debtorCodeList.get(c).ShippingStreet,'0',debtorCodeList.get(c).ShippingCity,'0',debtorCodeList.get(c).ShippingPostalCode,debtorCodeList.get(c).Phone,'0','Mr.',debtorCodeList.get(c).AccountContactRelations[0].Contact.LastName,debtorCodeList.get(c).AccountContactRelations[0].Contact.FirstName,'0','0','0','0',debtorCodeList.get(c).AccountContactRelations[0].Contact.MobilePhone,'1',debtorCodeList.get(c).AccountContactRelations[0].Contact.MobilePhone,debtorCodeList.get(c).AccountContactRelations[0].Contact.Email,'SS','SS');                              
                    system.debug('updateAccount message = '+message);
                    HttpRequest req = getInfoFromServiceFacade(access.endpoint__c, access.username__c, access.password__c, message);
                    HttpResponse res = responseFromServiceFacade(req);
                    system.debug(res.toString());
                    system.debug('STATUS: ' + res.getStatus());
                    system.debug('STATUS: ' + res.getStatusCode());
                    String responseJSON = '[' + res.getBody() + ']';
                    System.debug('responseJSON: ' + responseJSON);
                    //Update Accounts
                    if(res.getStatusCode() == 200) {
                        List<response> deserializedResponse = (List<response>)System.JSON.deserialize(responseJSON, List<response>.class);
                        for(response s : deserializedResponse) {
                            if(s.response != null) {
                                debtorCodeList.get(c).DebtorCode__c= s.response;
                            }
                        }
                    }
                    
                    //Handle Response errors
                    if(res.getStatusCode() != 200) {
                        mail(message, String.valueOf(res.getStatus()), String.valueOf(res.getStatusCode()));
                    }
                }
                update debtorCodeList.values();
            }
            
         }
    }
}