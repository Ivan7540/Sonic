@isTest
public class PhysicalSiteInspectionControllerTest {
    public static testMethod void testPhysicalSiteInspectionController(){
        String jsonString = '{"companyTradingName":"Sureswipe","ssEmployeeName":"Connor Huglin","undersignerName":"Connor","undersignerEmplNo":"SS123","siteAddress": "123 ABC Dr", "tradingNameConfirmation": "Sureswipe"}';

        List<Deal__c> deals = TestDataFactory.createDeals(1);
        
        PhysicalSiteInspectionController.PhysicalSiteInspectionWrapper inspectionData = (PhysicalSiteInspectionController.PhysicalSiteInspectionWrapper)JSON.deserialize(jsonString, PhysicalSiteInspectionController.PhysicalSiteInspectionWrapper.class);
        inspectionData.dealId = deals[0].Id;
        inspectionData.dateSiteVisited = Date.today();
        
        deals[0].PhysicalSiteInspectionJSON__c = jsonString;
        update deals;
        
        Test.startTest();
            PageReference pageRef = Page.PhysicalSiteInspectionPDF;
            pageRef.getParameters().put('id', deals[0].Id);
            pageRef.getParameters().put('JSONString', jsonString);
            Test.setCurrentPage(pageRef);
            PhysicalSiteInspectionController thisController = new PhysicalSiteInspectionController();
        	thisController.getSFUsername();
            PhysicalSiteInspectionController.saveJSONData(new List<PhysicalSiteInspectionController.PhysicalSiteInspectionWrapper>{inspectionData});
        Test.stopTest();
    }
}