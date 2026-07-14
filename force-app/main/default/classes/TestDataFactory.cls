public class TestDataFactory {

   public static List<Account> createTestAccounts(Integer numAccts, Integer numContactsPerAcct, String Region){
        
        List <Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++){
            Account a = new Account(Name='TestAccount' + i,
                                    Status__c = 'Active',
                                    Industry = 'Fashion',
                                    Type = 'Prospect',
                                    BusinessType__c = 'Sole Proprietor',
                                    SBQQ__PreserveBundle__c = true,
                                    SBQQ__RenewalModel__c = 'Contract Based',
                                    DebtorCode__c = 'DC056' + i,
                                    RegistrationNumber__c = '1616/51/2255',
                                    TradingName__c = DAL_BaseObject.generateRandomName(),
                                    ShippingStreet = '123 5th Rd',
                                    ShippingSuburb__c = 'Wilgeheuwel',
                                    ShippingState = 'Gauteng',
                                    ShippingCity = 'Pretoria',
                                    ShippingPostalCode = '1032');
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons = new List<Contact>();
        for(Integer j=0;j<numAccts;j++){
            Account acct = accts[j];
            for(Integer k = numContactsPerAcct * j; k < numContactsPerAcct * (j + 1); k++){
                cons.add(New Contact(FirstName = 'Test' + k,
                                     LastName = 'Test' + k,
                                     Email = DAL_BaseObject.generateRandomEmail(),
                                     Phone = DAL_BaseObject.generateRandomNumber(),
                                     MobilePhone = DAL_BaseObject.generateRandomNumber(),
                                     AccountId = acct.Id));
            }
        }
        insert cons;
       return accts;
    }

    public static List<Account> createWarehouses(Integer numAccts)
    {
        List <Account> warehouses = new List<Account>();

        for(Integer i = 0; i < numAccts; i++)
        {
            Account a = new Account(
                Name='Warehouse' + i,
                Status__c = 'Active',
                Industry = 'Fashion',
                Type = 'Warehouse',
                BusinessType__c = 'Sole Proprietor',
                SBQQ__PreserveBundle__c = true,
                SBQQ__RenewalModel__c = 'Contract Based'
                                    );
            warehouses.add(a);
        }

        DAL_BaseObject.insertDBObjects(warehouses);
        return warehouses;
    }
    
    public static Lead createLead(String leadSource) 
    {
        Lead lead = new Lead(
            FirstName = DAL_BaseObject.generateRandomName(),
            LastName = DAL_BaseObject.generateRandomName(),
            Phone = DAL_BaseObject.generateRandomNumber(),
            Email = DAL_BaseObject.generateRandomEmail(),
            Company = DAL_BaseObject.generateRandomName(),
            LeadSource = leadSource,
            Status = DAL_Lead.STATUS_NEW
            );
        DAL_BaseObject.InsertDBObject(lead);    
        return lead;
    }
    
    public static AccountContactRelation createAccountContactRelation(Id accountId, Id contactId)
    {
        AccountContactRelation relation = new AccountContactRelation();
        relation.AccountId = accountId;
        relation.ContactId = contactId;
        relation.Relationship_Strength__c = 'Primary';
        relation.Roles = 'Director';
        return relation;
    }

    public static AssetProvider__c createAssetPro(String service) 
    {
        AssetProvider__c asspro = new AssetProvider__c(
            Name = DAL_BaseObject.generateRandomName(),
            Service__c = service);
        DAL_BaseObject.InsertDBObject(asspro);    
        return asspro;
    }

    public static AssetProvider__c createAssetPro(String service, Id accountId, Id assetId, Id merchantId)
    {
        AssetProvider__c asspro = new AssetProvider__c(
            Name = DAL_BaseObject.generateRandomName(),
            Service__c = service,
            Account__c = accountId,
            Asset__c = assetId,
            MerchantId__c = merchantId
            );            
        return asspro;
    }

    public static Bank_Account__c createBank(Id accountId)
    {
        Bank_Account__c bank = new Bank_Account__c();
        bank.Account__c = accountId;
        bank.Bank__c = 'ABSA';
        bank.BranchCode__c = DAL_BaseObject.generateRandomNumber();
        bank.AccountNumber__c = DAL_BaseObject.generateRandomNumber();
        return bank;
    }

    public static Product2 createTestSubscriptionProduct()
    {
        Product2 rateBundle = new Product2();
        rateBundle.Name = 'Rate Bundle';
        rateBundle.ProductCode = 'SS_RATE_BUNDLE';
        rateBundle.IsActive = true;
        rateBundle.SBQQ__HidePriceInSearchResults__c = true;
        rateBundle.SBQQ__SortOrder__c = 10;
        rateBundle.SBQQ__BlockPricingField__c = 'Quantity';
        rateBundle.BusinessUnit__c = 'Sureswipe';
        rateBundle.CurrencyIsoCode = 'ZAR';
        rateBundle.SBQQ__AssetAmendmentBehavior__c = 'Default';
        rateBundle.SBQQ__AssetConversion__c = 'One per unit';
        rateBundle.SBQQ__DefaultQuantity__c = 1.00000;
        rateBundle.SBQQ__OptionSelectionMethod__c = 'Click';
        rateBundle.SBQQ__PricingMethod__c = 'List';
        rateBundle.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        rateBundle.SBQQ__SubscriptionBase__c = 'Net';
        rateBundle.SBQQ__SubscriptionType__c = 'Renewable';
        rateBundle.SerialNumberRequired__c = true;

        DAL_BaseObject.InsertDBObject(rateBundle);
        return rateBundle;
    }

    public static Product2 createTestOnceOffProduct()
    {
        return createTestOnceOffProduct(DAL_Product.calloutFeeProductCodes[0]);       
    }

    public static Product2 createTestOnceOffProduct(String productCode)
    {
        Product2 callOut = new Product2();
        callOut.Name = 'Callout Fee';
        callOut.ProductCode = productCode;
        callOut.IsActive = true;
        callOut.SBQQ__HidePriceInSearchResults__c = false;
        callOut.SBQQ__BlockPricingField__c = 'Quantity';
        callOut.BusinessUnit__c = 'Sureswipe';
        callOut.CurrencyIsoCode = 'ZAR';
        callOut.SBQQ__AssetAmendmentBehavior__c = 'Default';
        callOut.SBQQ__QuantityEditable__c = true;
        callOut.SBQQ__DefaultQuantity__c = 1.00000;
        callOut.SBQQ__OptionSelectionMethod__c = 'Click';
        callOut.SBQQ__PricingMethod__c = 'List';
        callOut.SBQQ__SubscriptionPricing__c = null;
        callOut.SBQQ__AssetConversion__c = null;
        callOut.SBQQ__ChargeType__c = 'One-Time';
        callOut.QuantityUnitOfMeasure = 'Each';
        callOut.SBQQ__SubscriptionBase__c = 'List';
        callOut.SBQQ__SubscriptionType__c = 'Renewable';
        callOut.SerialNumberRequired__c = true;

        DAL_BaseObject.InsertDBObject(callOut);
        return callOut;
    }

    public static Pricebook2 createTestPricebook()
    {
        Pricebook2 book = new Pricebook2();
        book.Name = 'Sureswipe Price Book';
        book.IsActive = true;

        DAL_BaseObject.InsertDBObject(book);
        return book;
    }

    public static PricebookEntry addProductToPricebook(Id productId, Id pricebookId)
    {
        PricebookEntry entry = new PricebookEntry();
        entry.IsActive = true;
        entry.Product2Id = productId;
        entry.Pricebook2Id = pricebookId;
        entry.UnitPrice = 100.00;
        DAL_BaseObject.InsertDBObject(entry);
        return entry;
    }

    public static List<Asset> createAssets(Id accountId, Integer numAsset)
    {
        List<Asset> newAssets = noInsertAssets(accountId, numAsset);
        DAL_BaseObject.InsertDBObjects(newAssets);
        return newAssets;
    }

    public static List<Asset> noInsertAssets(Id accountId, Integer numAsset)
    {
        List<Asset> newAssets = new List<Asset>();

        for(Integer i=0; i<numAsset; i++)
        {
            newAssets.add(new Asset(AccountId = accountId, Name = DAL_BaseObject.generateRandomName()));
        }

        return newAssets;
    }

    public static List<Stock__c> createStock(Integer numStock, Id warehouseId, Id productId)
    {
        List<Stock__c> stockList = new List<Stock__c>();
        
        for(Integer i = 0; i < numStock; i++)
        {
            Stock__c newStock = new Stock__c();
            newStock.Account__c = warehouseId;
            newStock.Product__c = productId;
            newStock.Serial_Number__c = DAL_BaseObject.generateRandomName();
            newStock.Status__c = 'In Stock';
            stockList.add(newStock);
        }
        
        DAL_BaseObject.InsertDBObjects(stockList);
        return stockList;
    }
    
    public static WorkOrder__c createWorkOrder(Id accountId, Id contactId, Id caseId, Id orderId)
    {
        WorkOrder__c newOrder = new WorkOrder__c();
        newOrder.Account__c = accountId;
        newOrder.Contact__c = contactId;
        newOrder.Case__c = caseId;
        newOrder.Order__c = orderId;
        DAL_BaseObject.InsertDBObject(newOrder);
        return newOrder;
    }

    public static WorkOrder__c createWorkOrder(Id accountId, Id contactId, Id caseId, Id orderId, String type)
    {
        WorkOrder__c newOrder = new WorkOrder__c();
        newOrder.Account__c = accountId;
        newOrder.Contact__c = contactId;
        newOrder.Case__c = caseId;
        newOrder.Order__c = orderId;
        newOrder.Type__c = type;
        DAL_BaseObject.InsertDBObject(newOrder);
        return newOrder;
    }

    public static WorkOrderLineItem__c createWorkOrderLine(Id workOrderId, Id assetId, Id stockId, Id workLineId)
    {
        WorkOrderLineItem__c newLine = new WorkOrderLineItem__c();
        newLine.WorkOrder__c = workOrderId;
        newLine.Asset__c = assetId;
        newLine.Stock__c = stockId;
        newLine.ReplacedItem__c = workLineId;
        return newLine;
    }

    public static Case createCase(Id accountId)
    {
        Case newCase = new Case();
        newCase.AccountId = accountId;
        return newCase;
    }
    
    // create opportunities. One opportunity per account
    public static List<Opportunity> createOpportunities(List<Account> accounts, Id pricebookId){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Account eachAccount : accounts){
            Opportunity newOpp = new Opportunity(AccountId = eachAccount.Id,
                                                 Name='ComputerMaintenance1K',
                                                 CloseDate = System.today().addMonths(12),
                                                 StageName = 'Qualified',
                                                 Pricebook2Id = pricebookId);
            opportunities.add(newOpp);
        }
        insert opportunities;
        return opportunities;
    }

    // create opportunities. One opportunity per account
    public static List<Opportunity> createOpportunities(List<Account> accounts)
    {
        return createOpportunities(accounts, Test.getStandardPricebookId());
    }

    public static void addProductsToOpportunities(List<Opportunity> opportunities, List<PricebookEntry> products)
    {
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();

        for(Opportunity opp :opportunities)
        {
            for(PricebookEntry entry :products)
            {
                OpportunityLineItem item = new OpportunityLineItem();
                item.OpportunityId = opp.Id;
                item.PricebookEntryId = entry.Id;
                item.Quantity = 1;
                item.UnitPrice = 10.0;
                lineItems.add(item);
            }
        }

        insert lineItems;
    }
    
    // create Quotes for Opportunities with products
    public static List<SBQQ__Quote__c> createQuotes(List<Opportunity> opportunities, Boolean orderByGroup){
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        for(Opportunity eachOpty : opportunities){
            SBQQ__Quote__c eachQuote = createQuoteWoInsert(eachOpty.Id, System.today(), 12, orderByGroup, true);
            quotes.add(eachQuote);
        }
        
        insert quotes;
        return quotes;
    }

    public static SBQQ__Quote__c createQuoteWoInsert(Id oppId, Date startDate, Integer term, Boolean orderByGroup, Boolean isPrimary)
    {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__StartDate__c = startDate;
        quote.SBQQ__SubscriptionTerm__c = term;
        quote.SBQQ__Primary__c = isPrimary;
        quote.sBQQ__Ordered__c = false;
        quote.SBQQ__OrderByQuoteLineGroup__c = orderByGroup;

        return quote;
    }
    
    public static void addProductToQuote(List<SBQQ__Quote__c> quotes, List<Id> productIds, Id pricebookEntryId,
                                         String currencyCode, boolean skipCalculate)
    {
        for(SBQQ__Quote__c eachQuote : quotes){
            QuoteModel thisQuoteModel = CPQ_APIWrapper.getQuoteModel(eachQuote.Id);
            //Calculation to be skipped as it makes API call
            QuoteModel updatedQuoteModel = CPQ_ApiWrapper.addProductsToQuote(thisQuoteModel, productIds, pricebookEntryId,
                                                                             currencyCode, skipCalculate);
            for(QuoteLineModel currentLineItem : updatedQuoteModel.lineItems){
                //Default the net price and unit price to 0 so that Order creation does not fail
                currentLineItem.record.SBQQ__NetPrice__c = 0;
                currentLineItem.record.SBQQ__ListPrice__c = 0;                
            }
            CPQ_ApiWrapper.saveQuote(updatedQuoteModel);
        }
    }

    public static List<Order> createOrdersForQuote(List<SBQQ__Quote__c> quotes){        
        List<Id> quoteIds = new List<Id>();
        for(SBQQ__Quote__c  eachQuote : quotes){
            eachQuote.SBQQ__Ordered__c = true;
            quoteIds.add(eachQuote.Id);
        }
        update quotes;

        List<Order> createdOrders = [Select Id,
                                     SBQQ__Contracted__c,
                                     Status,
                                     (
                                         select Id, SBQQ__Activated__c
                                         from OrderItems
                                     )
                                     From Order
                                     Where SBQQ__Quote__c in :quoteIds];
        
        List<OrderItem> updates = new List<OrderItem>();
        for(Order ord : createdOrders)
        {
            for(OrderItem item : ord.OrderItems)
            {
                item.SBQQ__Activated__c = true;
                updates.add(item);
            }
        }
        update updates;
        return createdOrders;
    }

    public static List<Order> createOrders(List<Account> accounts, Id pricebookId)
    {
        List<Order> result = new List<Order>();

        for(Account eachAccount: accounts)
        {
            Order newOrder = new Order();
            newOrder.AccountId = eachAccount.Id;
            newOrder.EffectiveDate = System.today(); 
            newOrder.Status = 'Draft';
            newOrder.Pricebook2Id = pricebookId;
            result.add(newOrder);
        }

        insert result;
        return result;
    }

    public static List<OrderItem> createOnceOffOrderItems(List<Order> orders, Id pricebookEntryId, Id productId)
    {
        List<OrderItem> result = new List<OrderItem>();

        for(Order ord: orders)
        {
            OrderItem item = new OrderItem();
            item.PricebookEntryId = pricebookEntryId;
            item.OrderId = ord.Id;
            item.UnitPrice = 100;
            item.Quantity = 1;
            item.Product2Id = productId;
            item.ServiceDate = System.today();
            result.add(item);
        }

        insert result;
        return result;
    }
    
    public static List<Contract> contractOrders(List<Order> orders){
        List<Id> orderIds = new List<Id>();
        for(Order eachOrder : orders){
            eachOrder.Status = 'Activated';//TO-DO Add to DAL
            eachOrder.SBQQ__Contracted__c = true;
            orderIds.add(eachOrder.Id);
        }
        update orders;
        return [Select Id From Contract where SBQQ__Order__c in :orderIds];
    }

    public static Contract createContract(Id accountId, Integer term, Date startDate) 
    {
        Contract contract = new Contract();
        contract.AccountId = accountId;
        contract.SBQQ__PreserveBundleStructureUponRenewals__c = true;
        contract.ContractTerm = term;
        contract.StartDate = startDate;
        
        return contract;
    }

    public static Contract insertContract(Id accountId, Integer term, Date startDate)
    {
        Contract contract = createContract(accountId, term, startDate);
        insert contract;
        return contract;
    }

    public static SBQQ__Subscription__c createSubscription(Id accountId, Id contractId, Id productId, Decimal quantity, Decimal netPrice, Date startDate, Date endDate) 
    {
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Contract__c = contractId;
        subs.SBQQ__Product__c = productId;
        subs.SBQQ__Quantity__c = quantity; 
        subs.SBQQ__Account__c = accountId;
        subs.SBQQ__NetPrice__c = netPrice * quantity;
        subs.SBQQ__SubscriptionEndDate__c = endDate;
        subs.SBQQ__SubscriptionStartDate__c = startDate;
        insert subs;
        return subs;
    }

    public static SBQQ__Subscription__c createRevisedSubscription(Id accountId, Id contractId, Id productId, Decimal quantity, Decimal netPrice, Date startDate, Date endDate, Id revisedSubscriptionId) 
    {
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Contract__c = contractId;
        subs.SBQQ__Product__c = productId;
        subs.SBQQ__Quantity__c = quantity; 
        subs.SBQQ__Account__c = accountId;
        subs.SBQQ__NetPrice__c = netPrice < 0 && quantity < 0 ? - (netPrice * quantity) : netPrice * quantity;
        subs.SBQQ__SubscriptionEndDate__c = endDate;
        subs.SBQQ__SubscriptionStartDate__c = startDate;
        subs.SBQQ__RevisedSubscription__c = revisedSubscriptionId;
        insert subs;
        return subs;
    }

    public static List<Rebate__c> createRebates(Integer numRebates, Id subscriptionId)
    {
        List<Rebate__c> rebates = new List<Rebate__c>();

        for(Integer i = 0; i < numRebates; i++)
        {
            Rebate__c reb = new Rebate__c();
            reb.Subscription__c = subscriptionId;
            reb.RebatePercent__c = 0.1;
            reb.Quantity__c = 1;

            rebates.add(reb);
        }

        return rebates;
    }

    public static List<MerchantId__c> noInsertMerchantIds(Id accountId, Integer recordsNumber)
    {
        List<MerchantId__c> merchants = new List<MerchantId__c>();

        for(Integer i = 0; i < recordsNumber; i++)
        {
            MerchantId__c newRec = new MerchantId__c();
            newRec.Name = DAL_BaseObject.generateRandomName();
            newRec.Account__c = accountId;
            merchants.add(newRec);
        }

        return merchants;
    }

    public static List<MerchantId__c> createMerchantIds(Id accountId, Integer recordsNumber)
    {
        List<MerchantId__c> merchants = noInsertMerchantIds(accountId, recordsNumber);
        DAL_BaseObject.InsertDBObjects(merchants);
        return merchants;
    }

    public static List<Deal__c> createDeals(Integer numDeals){
        List<Deal__c> deals = new List<Deal__c>();
        
        for(Integer i = 0; i < numDeals; i++){
            Deal__c newDeal = new Deal__c();
            newDeal.Name='TestDeal' + String.valueOf(i);
            deals.add(newDeal);
        }
        DAL_BaseObject.InsertDBObjects(deals);
        return deals;
    }

    public static List<Transaction__c> createTransactions(Id accountId, Integer numTransactions)
    {
        List<Transaction__c> transactions = new List<Transaction__c>();

        for(Integer i = 0; i < numTransactions; i++)
        {
            Transaction__c newRec = new Transaction__c();
            newRec.Account__c = accountId;
            newRec.Total_Swipe_Foreign_Credit__c = 1000;
            newRec.Total_Swipe_Foreign_Debit__c = 2000;
            newRec.Total_Swipe_Local_Credit__c = 3000;
            newRec.Total_Swipe_Local_Debit__c = 4000;
            newRec.Period__c = System.today().toStartOfMonth();
            transactions.add(newRec);
        }

        DAL_BaseObject.InsertDBObjects(transactions);
        return transactions;
    }

    public static void createContentDocument(Id parentId)
    {
        ContentVersion version = new ContentVersion();
        version.Title = 'Test';
        version.ContentLocation = 'S';
        version.PathOnClient = 'Test.jpg';
        version.VersionData = Blob.valueOf('Test Data');
        version.FirstPublishLocationId  = parentId;             
        
        DAL_BaseObject.InsertDBObject(version);
    }

    public static void createContentDocument(Id parentId, String tag)
    {
        ContentVersion version = new ContentVersion();
        version.Title = 'Test';
        version.ContentLocation = 'S';
        version.PathOnClient = 'Test.jpg';
        version.VersionData = Blob.valueOf('Test Data');
        version.DocumentType_fileupload__c = tag;
        version.FirstPublishLocationId  = parentId;             
        
        DAL_BaseObject.InsertDBObject(version);
    }
    
    public static List<ContentDocument> getAllDocuments()
    {
        return
        [
            SELECT  Id, 
                    Title, 
                    LatestPublishedVersionId,
                    LatestPublishedVersion.DocumentType_fileupload__c,
                    LatestPublishedVersion.VersionData,
                    LatestPublishedVersion.PathOnClient,
                    LatestPublishedVersion.ReasonForChange,
                    LatestPublishedVersion.VersionNumber                  
            FROM ContentDocument
        ];
    }

    public static ContentDocumentLink linkDocumentToRecord(Id documentId, Id recordId)
    {
        ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.ShareType = 'V'; 
        newLink.LinkedEntityId = recordId;
        newLink.ContentDocumentId = documentId;
        newLink.Visibility = 'AllUsers';
        return newLink;
    }

    public static ContentDocumentLink linkDocumentToRecord(Id documentId, Id recordId, Boolean performInsert)
    {
        ContentDocumentLink newLink = linkDocumentToRecord(documentId, recordId);
        
        if(performInsert)
        {
            DAL_BaseObject.InsertDBObject(newLink);
        }

        return newLink;
    }

    public static List<Deal_Line__c> createTestDealLines(Integer numDealLines, Id parentDealId, Id parentLine)
    {
        List <Deal_Line__c> dealLines = new List<Deal_Line__c>();

        for (Integer i = 0; i < numDealLines; i++)
        {
            Deal_Line__c d = new Deal_Line__c(
                    Deal__c = parentDealId,
                    ParentLine__c = parentLine,
                    Name = 'Classic SS_SP_630' + i,
                    Product__c = 'Classic',
                    Device__c = 'SS_SP_630',
                    ContractTerm__c = '24Month',
                    Quantity__c = i
            );
            dealLines.add(d);
        }
        insert dealLines;

        return dealLines;
    }
}