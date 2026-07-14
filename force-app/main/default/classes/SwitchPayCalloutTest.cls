/*
Date created: 21/05/2021
Developer: Ajit Gopu
JIRA number: PS-57
*/
@isTest(SeeAllData = false)
public class SwitchPayCalloutTest
{
    private static String REF = 'ab93-fd52-bb94-25e3';

    @TestSetup
    static void setup()
    {        
        List<Account> testAccounts = TestDataFactory.createTestAccounts(5, 1, 'GAU');
        Account noParentAccount = testAccounts[0];
        setPrimaryRelation(noParentAccount.Id);
        Account unregisteredParent = testAccounts[1];
        setPrimaryRelation(unregisteredParent.Id);
        Account unregisteredBranch = testAccounts[2];
        setPrimaryRelation(unregisteredBranch.Id);
        unregisteredBranch.ParentId = unregisteredParent.Id;
        Account registeredParent = testAccounts[3];
        registeredParent.MoreTymeReference__c = REF;
        setPrimaryRelation(registeredParent.Id);
        Account newBranch = testAccounts[4];
        newBranch.ParentId = registeredParent.Id;
        setPrimaryRelation(newBranch.Id);
        DAL_BaseObject.UpdateDBObjects(testAccounts);

        List<Opportunity> testOpportunities = TestDataFactory.createOpportunities(testAccounts);

        for(Opportunity testOpportunity :testOpportunities)
        {
            testOpportunity.Type = 'New Business';
        }

        DAL_BaseObject.UpdateDBObjects(testOpportunities);

        Product2 testProduct1 = TestDataFactory.createTestOnceOffProduct(new List<String>(SwitchPayCallout.codesMap.keySet())[0]);
        Product2 testProduct2 = TestDataFactory.createTestOnceOffProduct(new List<String>(SwitchPayCallout.codesMap.keySet())[1]);
        Product2 testProduct3 = TestDataFactory.createTestOnceOffProduct(new List<String>(SwitchPayCallout.codesMap.keySet())[2]);
        PricebookEntry testEntry1 = TestDataFactory.addProductToPricebook(testProduct1.Id, Test.getStandardPricebookId());
        PricebookEntry testEntry2 = TestDataFactory.addProductToPricebook(testProduct2.Id, Test.getStandardPricebookId());
        PricebookEntry testEntry3 = TestDataFactory.addProductToPricebook(testProduct3.Id, Test.getStandardPricebookId());
        List<Opportunity> grossOpportunities = new List<Opportunity>{testOpportunities.remove(0)};
        TestDataFactory.addProductsToOpportunities(testOpportunities, new List<PricebookEntry>{testEntry1, testEntry2});
        TestDataFactory.addProductsToOpportunities(grossOpportunities, new List<PricebookEntry>{testEntry1, testEntry3});
        testOpportunities.addAll(grossOpportunities);

        List<SBQQ__Quote__c> quotes = TestDataFactory.createQuotes(testOpportunities, false);
        List<Order> orders = TestDataFactory.createOrdersForQuote(quotes);
        List<OrderItem> orderProds = getOrderProducts(orders);

        Map<Id, List<OrderItem>> orderProdMap = new Map<Id, List<OrderItem>>();

        for(OrderItem oi :orderProds)
        {
            if(orderProdMap.containsKey(oi.Order.AccountId))
            {
                orderProdMap.get(oi.Order.AccountId).add(oi);
            }
            else
            {
                orderProdMap.put(oi.Order.AccountId, new List<OrderItem>{oi});
            }
        }
        
        Bank_Account__c noParentBank = TestDataFactory.createBank(noParentAccount.Id);
        Bank_Account__c unregisteredParentBank = TestDataFactory.createBank(unregisteredParent.Id);
        Bank_Account__c registeredParentBank = TestDataFactory.createBank(registeredParent.Id);
        DAL_BaseObject.InsertDBObjects(new List<Bank_Account__c> {noParentBank, unregisteredParentBank, registeredParentBank});

        MerchantId__c noParentMid = TestDataFactory.noInsertMerchantIds(noParentAccount.Id, 1)[0];
        noParentMid.SettlementAccount__c = noParentBank.Id;
        noParentMid.Type__c = SwitchPayCallout.MASTERPASS_TYPE;

        MerchantId__c noParentMid2 = TestDataFactory.noInsertMerchantIds(noParentAccount.Id, 1)[0];
        noParentMid2.SettlementAccount__c = noParentBank.Id;
        noParentMid2.Type__c = SwitchPayCallout.EFT_TYPE;

        MerchantId__c registeredParentMid = TestDataFactory.noInsertMerchantIds(newBranch.Id, 1)[0];
        registeredParentMid.SettlementAccount__c = registeredParentBank.Id;
        registeredParentMid.Type__c = SwitchPayCallout.MASTERPASS_TYPE;

        MerchantId__c registeredParentMid2 = TestDataFactory.noInsertMerchantIds(newBranch.Id, 1)[0];
        registeredParentMid2.SettlementAccount__c = registeredParentBank.Id;
        registeredParentMid2.Type__c = SwitchPayCallout.EFT_TYPE;

        MerchantId__c unregisteredParentMid = TestDataFactory.noInsertMerchantIds(unregisteredBranch.Id, 1)[0];
        unregisteredParentMid.SettlementAccount__c = unregisteredParentBank.Id;
        unregisteredParentMid.Type__c = SwitchPayCallout.MASTERPASS_TYPE;

        MerchantId__c unregisteredParentMid2 = TestDataFactory.noInsertMerchantIds(unregisteredBranch.Id, 1)[0];
        unregisteredParentMid2.SettlementAccount__c = unregisteredParentBank.Id;
        unregisteredParentMid2.Type__c = SwitchPayCallout.EFT_TYPE;

        DAL_BaseObject.InsertDBObjects(new List<MerchantId__c>{noParentMid, registeredParentMid, unregisteredParentMid, noParentMid2, registeredParentMid2, unregisteredParentMid2});

        Asset noParentAsset = TestDataFactory.noInsertAssets(noParentAccount.Id, 1)[0];
        noParentAsset.SBQQ__OrderProduct__c = orderProdMap.get(noParentAccount.Id)[0].Id;

        Asset parentAsset = TestDataFactory.noInsertAssets(unregisteredBranch.Id, 1)[0];
        parentAsset.SBQQ__OrderProduct__c = orderProdMap.get(unregisteredBranch.Id)[0].Id;

        Asset branchAsset = TestDataFactory.noInsertAssets(newBranch.Id, 1)[0];
        branchAsset.SBQQ__OrderProduct__c = orderProdMap.get(newBranch.Id)[0].Id;

        DAL_BaseObject.InsertDBObjects(new List<Asset>{noParentAsset, parentAsset, branchAsset});

        AssetProvider__c provider1 = TestDataFactory.createAssetPro('MasterPass', noParentAccount.Id, noParentAsset.Id, noParentMid.Id);
        AssetProvider__c provider4 = TestDataFactory.createAssetPro('MasterPass', noParentAccount.Id, noParentAsset.Id, noParentMid2.Id);
        AssetProvider__c provider2 = TestDataFactory.createAssetPro('MasterPass', unregisteredBranch.Id, parentAsset.Id, unregisteredParentMid.Id);
        AssetProvider__c provider5 = TestDataFactory.createAssetPro('MasterPass', unregisteredBranch.Id, parentAsset.Id, unregisteredParentMid2.Id);
        AssetProvider__c provider3 = TestDataFactory.createAssetPro('MasterPass', newBranch.Id, branchAsset.Id, registeredParentMid.Id);
        AssetProvider__c provider6 = TestDataFactory.createAssetPro('MasterPass', newBranch.Id, branchAsset.Id, registeredParentMid2.Id);
        DAL_BaseObject.InsertDBObjects(new List<AssetProvider__c>{provider1, provider2, provider3, provider4, provider5, provider6});        
    }

    @isTest 
    static void simpleCallout()
    {
        Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('Flowgear_SwitchPay');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        // The static response for the response is set due to MultiStaticResourceCalloutMock requiring one.
        // Flowgear endpoint will not currently return any response
        multimock.setStaticResource(credentials.Endpoint__c, 'jsonresponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);

        Account testAccount = getAccount(false, null);
        Asset testAsset = getAsset(testAccount.Id);

        Test.startTest();

        SwitchPayCallout.flowgearMerchantCreation(testAsset.Id);

        Test.stopTest();
    }

    @isTest 
    static void parentCallout()
    {
        Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('Flowgear_SwitchPay');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        // The static response for the response is set due to MultiStaticResourceCalloutMock requiring one.
        // Flowgear endpoint will not currently return any response
        multimock.setStaticResource(credentials.Endpoint__c, 'jsonresponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);

        Account testAccount = getAccount(true, null);
        Asset testAsset = getAsset(testAccount.Id);

        Test.startTest();

        SwitchPayCallout.flowgearMerchantCreation(testAsset.Id);

        Test.stopTest();
    }

    @isTest 
    static void branchCallout()
    {
        Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('Flowgear_SwitchPay');
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        // The static response for the response is set due to MultiStaticResourceCalloutMock requiring one.
        // Flowgear endpoint will not currently return any response
        multimock.setStaticResource(credentials.Endpoint__c, 'jsonresponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);

        Account testAccount = getAccount(true, REF);
        Asset testAsset = getAsset(testAccount.Id);

        Test.startTest();

        SwitchPayCallout.flowgearMerchantCreation(testAsset.Id);

        Test.stopTest();
    }

    private static Account getAccount(Boolean parent, String reference)
    {
        if(!parent)
        {
            return
            [
                SELECT  Id
                FROM Account
                WHERE ParentId = null
                LIMIT 1
            ]; 
        }
        else
        {
            return
            [
                SELECT  Id,
                        Parent.MoreTymeReference__c
                FROM Account
                WHERE ParentId != null
                AND Parent.MoreTymeReference__c = :reference
                LIMIT 1
            ];
        }
    }

    private static Opportunity getOpportunity()
    {
        return
        [
            SELECT  Id
            FROM Opportunity
            LIMIT 1
        ];
    }

    private static Asset getAsset(Id accountId)
    {
        return
        [
            SELECT  Id
            FROM Asset
            WHERE AccountId = :accountId
            LIMIT 1
        ];
    }

    private static List<AccountContactRelation> getRelations(Id accountId)
    {
        return 
		[
            SELECT  AccountId,
                    ContactId, 
                    Contact.Name, 
                    Contact.Phone, 
                    Contact.MobilePhone,
                    Contact.Email 
            FROM AccountContactRelation 
            WHERE AccountId = :accountId
        ];
    }

    private static List<OrderItem> getOrderProducts(List<Order> orders)
    {
        return
        [
            SELECT  Id,
                    Order.AccountId
            FROM OrderItem
            WHERE OrderId IN :orders
        ];
    }

    private static List<Bank_Account__c> getBankAccounts(Id accountId)
    {
        return
        [
            SELECT  Id, 
                    Account__c
            FROM Bank_Account__c
            WHERE Account__c = :accountId
        ];
    }

    private static void setPrimaryRelation(Id accountId)
    {
        AccountContactRelation testRelation = getRelations(accountId)[0];
        testRelation.Relationship_Strength__c  = 'Primary';
        testRelation.Roles = 'Director';
        DAL_BaseObject.UpdateDBObject(testRelation);
    }
}