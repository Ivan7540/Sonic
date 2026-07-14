@isTest
public class SendBankEmailForMerchant_Test {
    @isTest
    static void testEmailSend(){
        List<Deal__c> deals = TestDataFactory.createDeals(1);
        List<Account> accounts = TestDataFactory.createTestAccounts(1, 1, null);
        TestDataFactory.createContentDocument(deals[0].Id, 'Draft Contract');
        TestDataFactory.createContentDocument(deals[0].Id, 'Signed Contract');
        TestDataFactory.createContentDocument(deals[0].Id, 'Proof of Business Address');
        Deal__c dealToUpdate = new Deal__c();
        dealToUpdate.Account__c = accounts[0].Id;
        dealToUpdate.Id = deals[0].Id;
        List<ContentDocument> docs = [Select Id, Title From ContentDocument];
        String concatIds = docs[0].id + ',' + docs[1].Id;
        update dealToUpdate;
        
        Test.startTest();
        SendBankEmailForMerchantNumber.requestInput thisInput = new SendBankEmailForMerchantNumber.requestInput();
        thisInput.dealId = deals[0].Id;
        thisInput.concatenatedContentDocumentIds = concatIds;
        thisInput.emailBody = 'Sent from Sureswipe';
        SendBankEmailForMerchantNumber.sendEmailToBank(new List<SendBankEmailForMerchantNumber.requestInput>{thisInput});
        Test.stopTest();
    }
}