/*
Date created: 26/01/2022
Developer: Ivan Vrtacnik
JIRA number: PS-1456
*/
@isTest(SeeAllData = false)
public class DocumentRequirementsResourceTest 
{
    @isTest
    static void testGet()
    {
        Deal__c testDeal = TestDataFactory.createDeals(1)[0];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.params.put('id', testDeal.Id);
        req.params.put('businessType', 'Sole Proprietor');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        List<LCC_DocumentRequirementController.documentRequirement> results = DocumentRequirementsResource.getDocuments();
        
        Test.stopTest();
    }
}