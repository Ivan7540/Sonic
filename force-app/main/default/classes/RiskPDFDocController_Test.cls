@isTest
public class RiskPDFDocController_Test {
    @isTest
    static void testRiskPDFDoc(){
        String jsonString = '{"wasTranslatorPresent":false,"translatorContactNo":"","stockHeldElsewhere":false,"premisesFunctional":true,"ownerSpeaksEnglish":false,"merchantSellHighValueItems":false,"merchantOverEager":false,"googleSearch":false,"fakeIllegalItems":false,"explainPremisesFunctional":"","explainMOTO":"","explainMerchantOverEager":"","explainHighValueItems":"","explainGoogleSearch":"","explainFakeIllegalItems":"","explainAreaStigma":"","didStockInspection":null,"dealId":"a1j25000001DXhBAAW","BAMConfirmation":true,"areaStigma":false,"acceptMOTO":false}';
        List<Deal__c> deals = TestDataFactory.createDeals(1);
        RiskPDFDocController.RiskReportData riskData = (RiskPDFDocController.RiskReportData)JSON.deserialize(jsonString, RiskPDFDocController.RiskReportData.class);
        riskData.dealId = deals[0].Id;
        deals[0].RiskReportJSON__c = jsonString;
        update deals;
        Test.startTest();
        PageReference pageRef = Page.RiskPDFDoc;
        pageRef.getParameters().put('id', deals[0].Id);
        pageRef.getParameters().put('JSONString', jsonString);
        Test.setCurrentPage(pageRef);
        RiskPDFDocController thisController = new RiskPDFDocController();
        RiskPDFDocController.saveRiskJSON(new List<RiskPDFDocController.RiskReportData>{riskData});
        Test.stopTest();
    }
}