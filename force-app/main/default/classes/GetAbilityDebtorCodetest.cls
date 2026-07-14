/*
Date created: 07/06/2021
Developer: Ajit Gopu
JIRA number: PS-517
*/
@isTest(SeeAllData=true)
public class GetAbilityDebtorCodetest {

    @isTest
    Static void testgenerateJSONNew()
    {
        String message=GetAbilityDebtorCode.generateJSONNew('0012500001RrXWQAA3','FOURTEEN STAR PTY LTD','2021/497029/07','Shop 98- Cnr Edendale Main Road and Mount Partridge Road Edendale','1','Pietermaritzburg','0','03217','Shop 98 Cnr Edendale Main Road and Mount Partri  Edendale','0','EDENDALE','0','03217','0338800115','0','Mr.','Gopu','Ajit','0','0','0','0','0338800115','1','0338800115','ajit@sureswipe.co.za','SS','SS');
        Map<String, Object> res = (Map<String, Object>)json.deserializeUntyped(message);
        String merchantReference=(String)res.get('contractId');
        String expectedValue='0012500001RrXWQAA3';
        System.assertEquals(expectedValue, merchantReference);
    }
    @isTest
    Static void testHttpRequest()
    {	
        StaticResourceCalloutMock mock =new StaticResourceCalloutMock();
        mock.setStaticResource('getAbilityCodeResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HttpRequest req= new HttpRequest();
        HttpResponse res=GetAbilityDebtorCode.responseFromServiceFacade(req);
        Test.stopTest();
    }
    @isTest
    Static void testHttpResponse()
    {
       	String message=GetAbilityDebtorCode.generateJSONNew('0012500001RrXWQAA3','FOURTEEN STAR PTY LTD','2021/497029/07','Shop 98- Cnr Edendale Main Road and Mount Partridge Road Edendale','1','Pietermaritzburg','0','03217','Shop 98 Cnr Edendale Main Road and Mount Partri  Edendale','0','EDENDALE','0','03217','0338800115','0','Mr.','Gopu','Ajit','0','0','0','0','0338800115','1','0338800115','ajit@sureswipe.co.za','SS','SS');
        String username='sureswipe';
        String password='sureswipe';
        String endpoint='https://api.sureswipe.co.za/admin-services/rest/v1/clientzone/admin/debtors';
        StaticResourceCalloutMock mock =new StaticResourceCalloutMock();
        mock.setStaticResource('getAbilityCodeRequest');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        GetAbilityDebtorCode.getInfoFromServiceFacade(endpoint, username, password, message);
        Test.stopTest();
    }
    @isTest
    static void testupdateAccount()
    {   
        String username='sureswipe';
        String password='sureswipe';
        String endpoint='https://api.sureswipe.co.za/admin-services/rest/v1/clientzone/admin/debtors';
        Id a='0062500000Oh9IRAAZ';
        List<Id> oppId=new List<id>();
        oppId.add(a);
        Test.startTest();
        GetAbilityDebtorCode.updateAccount(oppId);
        Test.stopTest();
        if(oppId.size() > 0){
            Map<Id,Account> debtorCodeList = new Map<Id,Account>(DAL_Account.fordebtorCodeJSON(oppId));
            if(debtorCodeList.size() > 0){
                for(Id c: debtorCodeList.keyset()){
                    String message;
                    message =GetAbilityDebtorCode.generateJSONNew(debtorCodeList.get(c).Id,debtorCodeList.get(c).Name,debtorCodeList.get(c).RegistrationNumber__c,debtorCodeList.get(c).BillingStreet,
                                                 '1',debtorCodeList.get(c).BillingCity,'0',debtorCodeList.get(c).BillingPostalCode,debtorCodeList.get(c).ShippingStreet,'0',debtorCodeList.get(c).ShippingCity,'0',debtorCodeList.get(c).ShippingPostalCode,debtorCodeList.get(c).Phone,'0','Mr.',debtorCodeList.get(c).AccountContactRelations[0].Contact.LastName,debtorCodeList.get(c).AccountContactRelations[0].Contact.FirstName,'0','0','0','0',debtorCodeList.get(c).AccountContactRelations[0].Contact.MobilePhone,'1',debtorCodeList.get(c).AccountContactRelations[0].Contact.MobilePhone,debtorCodeList.get(c).AccountContactRelations[0].Contact.Email,'SS','SS');                              
                    HttpRequest req = GetAbilityDebtorCode.getInfoFromServiceFacade(endpoint, username, password, message);
                    HttpResponse res = GetAbilityDebtorCode.responseFromServiceFacade(req);
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
                        GetAbilityDebtorCode.mail(message, String.valueOf(res.getStatus()), String.valueOf(res.getStatusCode()));
                    }
                }
                update debtorCodeList.values();
            }
            
            
      }
        
    }
    @testVisible
    private static response parse(String responseJSON) {
        return (response) System.JSON.deserialize(responseJSON, response.class);
    }
    @testVisible
    private class response {
        public String accountId;	
        public String response;	
    }
    @isTest
    static void testmail()
    {
       	String message='GetAbilityDebtorCode call Service Failed';
        String status='Not Able to Get the Debtor Code';
        String statusCode='400';
        Test.startTest();
        GetAbilityDebtorCode.mail(message, status, statusCode);
        Test.stopTest();
    }
    @isTest
    static void testparse(){
        String responseJSON='{"contractId": "0012500001RrXWQAA3", "response": "FOU060"}';
        Test.startTest();
        GetAbilityDebtorCode.parse(responseJSON);
        Test.stopTest();
    }
    @isTest
    static void testInvocable()
    {
        Id a='0062500000Oh9IRAAZ';
        List<Id> oppId=new List<id>();
        oppId.add(a);
        Test.startTest();
        GetAbilityDebtorCodeInvocable.getAbilityDebtorCode(oppId);
        Test.stopTest();
    }
    
}