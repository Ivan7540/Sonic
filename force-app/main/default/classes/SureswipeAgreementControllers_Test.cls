@IsTest(SeeAllData=true)
public class SureswipeAgreementControllers_Test {
    @IsTest
    static void testPricingSection(){
        List<Account> testAccounts = TestDataFactory.createTestAccounts(1, 1, '');
        List<AccountContactRelation> contactRelations = [Select Id,
                                                         Roles
                                                         From AccountContactRelation
                                                         Where AccountId = :testAccounts[0].Id];
        for(AccountContactRelation eachRelation : contactRelations){
            eachRelation.Roles = 'Director';
        }
        update contactRelations;
        
        List<Opportunity> testOpties = TestDataFactory.createOpportunities(testAccounts);
        List<SBQQ__Quote__c> testQuotes = TestDataFactory.createQuotes(testOpties, true);
        CPQ_CreateQuoteModel.createCPQQuoteModel(testQuotes[0].Id, 'QM_RateBundle', null);
        CPQ_CreateQuoteModel.createCPQQuoteModel(testQuotes[0].Id, 'QM_WelcomeBox', null);
//        CPQ_CreateQuoteModel.createCPQQuoteModel(testQuotes[0].Id, 'QM_LiteSS_BT5024MonthBluetoothAndroid', new Map<String, Integer>{'SS_BT50_RENTAL' => 3});
//        CPQ_CreateQuoteModel.createCPQQuoteModel(testQuotes[0].Id, 'QM_QM_ClassicSS_SP_630MonthToMonthMasterpassSwitchPay', null);
        Test.startTest();
        PageReference pageRef = Page.SureswipeQuotePricingSection;
        pageRef.getParameters().put('qid', testQuotes[0].Id);
        Test.setCurrentPage(pageRef);
        SureswipeQuotePricingSectionController thisController = new SureswipeQuotePricingSectionController();
        thisController.getDomesticCreditCardRate();
        thisController.getDomesticDebitCardRate();
        thisController.getInternationalCreditCardRate();
        thisController.getInternationalDebitCardRate();
        thisController.getPaperRollDeliveryFee();
        thisController.getQuote();
        thisController.getReactivationFee();
        thisController.getSwipeValue();
        thisController.getUnpaidDebitOrderFee();
        
        SignatureController.getContacts(new List<Id>{testAccounts[0].Id});
        
        SignatureController sigController = new SignatureController();
        sigController.getClientSignatories();
        sigController.getCompanySignatories();
        sigController.getInitialSignatories();
        sigController.getQuote();
        SureswipeAmendmentPricingController amController = new SureswipeAmendmentPricingController();
        Test.stopTest();
    }
}