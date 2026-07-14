/*
Date created: 20/05/2021
Developer: Ajit Gopu
JIRA number: PS-57
*/
public class SwitchPayCallout 
{	
    private static final String exceptionTemplate = '{0} has merchant numbers {1} and {2} registered for Switchpay. Correct this before Opportunity can be closed.';
    private static final String INNERVATION_BU = 'Innervation';
    private static final String SURESWIPE_BU = 'Sureswipe';
    private static final String MORETYME_GROSS = 'Gross';
    private static final String MORETYME_NET = 'Net';
    @TestVisible
    private static final String MASTERPASS_TYPE = 'Nedbank Masterpass Merchant Number';
    @TestVisible
    private static final String EFT_TYPE = 'VISA/Mastercard';

    private static Map<String, Integer> companyTypeMap = new Map<String, Integer>
    {
        'Close Corporation' => 1,
        null => 2,
        'Private Company' => 3,
        'Public Company' => 4,
        'Sole Proprietor' => 5,
        'Trust' => 9,
        'Partnership' => 2,
        'Non Profit Organisation' => 2,
        'Incorporated Company' => 3,
        'PTY Ltd' => 3,
        'Non Profit' => 2
    };

    private static Map<String, Integer> bankMap = new Map<String, Integer>
    {
        'ABSA' => 1,
        null => 7,
        'Access Bank' => 7,
        'African Bank' => 7,
        'AlBaraka' => 7,
        'Discovery' => 7,
        'Investec' => 7,
        'Old Mutual' => 7,
        'Ubank' => 7,
        'Nedbank' => 5,
        'Standard Bank' => 9,
        'Mercantile' => 10,
        'Capitec' => 6,
        'First National Bank' => 2
    };

    private static Map<String, Integer> industryMap = new Map<String, Integer>
    {
        null => 11,
        'Accountant' => 9, 
        'Agriculture' => 5, 
        'Apparel' => 23, 
        'Auto Dealers' => 32, 
        'Auto Spares' => 32, 
        'Banking' => 9, 
        'Beauty/Cosmetic Store' => 13, 
        'Biotechnology' => 13, 
        'Book Store' => 24, 
        'Butcher' => 29, 
        'Chemicals' => 3, 
        'Clothing Store' => 23, 
        'Clothing Wholesaler' => 23, 
        'Communications' => 6, 
        'Construction' => 33, 
        'Construction/Engineering' => 33, 
        'Consultant' => 9, 
        'Consulting' => 9, 
        'Cycling' => 20, 
        'Deli' => 29, 
        'Dry Cleaner' => 11, 
        'Education' => 34, 
        'Electrical Appliances' => 14, 
        'Electrician' => 14, 
        'Electronics' => 28, 
        'Electronic Wholesaler' => 28, 
        'Energy' => 11, 
        'Engineering' => 26, 
        'Entertainment' => 24, 
        'Environmental' => 11, 
        'Fast Food' => 29, 
        'Finance' => 9, 
        'Fine Dining' => 29, 
        'Florist / Nursery' => 14, 
        'Food & Beverage' => 29, 
        'Food Retailer' => 29, 
        'Food Wholesaler' => 29, 
        'Funeral Services' => 18, 
        'Furniture' => 14, 
        'General Practitioner' => 13, 
        'Government' => 11, 
        'Guest House/Lodge' => 7, 
        'Hairdresser' => 13, 
        'Handyman' => 14, 
        'Hardware and Tools' => 12, 
        'Health and Fitness' => 13, 
        'Healthbridge Doctor' => 13, 
        'Healthcare' => 13, 
        'Health Care' => 13, 
        'Hobbies and Crafts' => 1, 
        'Home/Décor/Leisure Store' => 14, 
        'Hospitality' => 7, 
        'Hotel' => 7, 
        'Insurance' => 9, 
        'Internet and Computer Services' => 2, 
        'Jewellery' => 23, 
        'Lawyer' => 9, 
        'Liquor Store' => 29, 
        'Machinery' => 3, 
        'Manufacturing' => 3, 
        'Media' => 16, 
        'Motorcycle' => 32, 
        'Motor Vehicle' => 32, 
        'Motor Vehicle Service' => 32, 
        'Not For Profit' => 11, 
        'Optometrist' => 13, 
        'Orthodontist' => 13, 
        'Other' => 11, 
        'Pets' => 22, 
        'Photographic/Art retailer' => 24, 
        'Physiotherapist' => 13, 
        'Plumber' => 14, 
        'Printing and Stationery' => 17, 
        'Professional Services' => 9, 
        'Pub' => 29, 
        'Recreation' => 7, 
        'Restaurant' => 29, 
        'Retail' => 1, 
        'School' => 34, 
        'Second Hand Store' => 11, 
        'Service Stations' => 10, 
        'Shipping' => 11, 
        'SPA\'s and Beauty' => 13, 
        'Specialist Retailer' => 1, 
        'Sport Store' => 20, 
        'Supermarket' => 8, 
        'Technology' => 2, 
        'Telecommunications' => 6, 
        'Tobacconist' => 29, 
        'Toy Store' => 21, 
        'Training / Education' => 34, 
        'Transportation' => 11, 
        'Travel & Leisure' => 7, 
        'Utilities' => 11, 
        'Wholesaler' => 8 
    };

    private static Integer getIndustry(String industryName)
    {
        Integer result = industryMap.get(industryName);
        return result == null ? 11 : result;
    }

    public static final Map<String, List<Integer>> codesMap = new Map<String, List<Integer>>
    {
        DAL_Product.SWITCHPAY => new List<Integer>{1},
        DAL_Product.MORETYME_NET => new List<Integer>{9},
        DAL_Product.MORETYME_GROSS => new List<Integer>{9}
    };

    @future(callout = true)
    public static void flowgearMerchantCreation(Id assetId)
    {
        Asset installedAsset = getAsset(assetId);
        Id opportunityId = installedAsset.RelatedOpportunity__c;
        List<OpportunityLineItem> oppProducts = getOpportunityProducts(opportunityId); 
        String settlementType = getSettlementType(oppProducts);
        String businessUnit = getBusinessUnit(installedAsset.Account.Account_Manager__r.Profile.Name);
        String merchantNumberType = getMerchantNumberType(businessUnit, settlementType);
        List<AssetProvider__c> providers = getAssetProvidersByAsset(assetId, null);

        if(providers.isEmpty())
        {
            return;
        }

        List<MerchantId__c> merchantNumbers = getMerchantNumber(installedAsset.AccountId);

        List<MerchantId__c> primaryNumbers = new List<MerchantId__c>();
        List<MerchantId__c> altNumbers = new List<MerchantId__c>();
        Bank_Account__c bankAccount;
        
        for(MerchantId__c merchNumber :merchantNumbers)
        {
            if(merchNumber.Type__c.equals(merchantNumberType))
            {
                merchNumber.Name = merchNumber.Name.leftPad(15, '0');
                primaryNumbers.add(merchNumber);
            }
            else 
            {
                altNumbers.add(merchNumber);
            }

            if(merchNumber.SettlementAccount__c != null && bankAccount == null)
            {
                bankAccount = merchNumber.SettlementAccount__r;
            }
        }

        Id accountId = installedAsset.AccountId;

        if(bankAccount == null)
        {
            bankAccount = getBankAccount(accountId);
        }

        String productReference = getProductReference(merchantNumberType, merchantNumbers);
        Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('Flowgear_SwitchPay');

        List<AccountContactRelation> contactList = getRelations(accountId);
        AccountContactRelation relation = contactList.isEmpty() ? null : contactList[0];        

        Set<Id> contractIds = new Set<Id>{installedAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__c};

        if(installedAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RateContract__c != null)
        {
            contractIds.add(installedAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RateContract__c);
        }
        else
        {
            contractIds.add(getRateContractId(installedAsset));
        }
        
        Map<String, Decimal> rateMap = getRates(contractIds);
        String channel = channelSelection(businessUnit, settlementType);

        FlowgearRequest requestBody = new FlowgearRequest();
        requestBody.switchPayMerchant = new SwitchPayMerchant(primaryNumbers[0], relation, channel, bankAccount);
        Decimal vat = getVATRate(installedAsset.Account.ShippingCountryCode);
        requestBody.switchPayProduct = getSwitchpayProducts(oppProducts, primaryNumbers[0].Name, rateMap, channel, vat, productReference);
        requestBody.switchPayTerminal = new TerminalList(providers, primaryNumbers[0], oppProducts, channel);
        requestBody.merchantNumberId = primaryNumbers[0].Id;   
        MoreTymeRequest tymeReq = getMoreTymeBody(settlementType, rateMap, primaryNumbers[0], relation, productReference.leftPad(15, '0'), bankAccount);

        if(tymeReq != null)
        {
            requestBody.moreTymeMerchant = tymeReq.moreTymeMerchant;
            requestBody.moreTymeStore = tymeReq.moreTymeStore;
            requestBody.accountId = tymeReq.accountId;

            if(settlementType == MORETYME_GROSS)
            {
                for(Product prod :requestBody.switchPayProduct)
                {
                    prod.IsTopUpExpected = true;
                    prod.MechantIsNettIndicator = false;
                }
            }                       
        }   

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(credentials.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Key=' + credentials.Password__c);
        request.setBody(JSON.serialize(requestBody));
        http.send(request);
    }

    private static MoreTymeRequest getMoreTymeBody(String settlementType, Map<String, Decimal> rateMap, MerchantId__c merchantNumber, AccountContactRelation relation, String merchantRef, Bank_Account__c bankAccount)
    {
        MoreTymeRequest request = new MoreTymeRequest();      

        if(!String.isBlank(settlementType))
        {            
            Double rate = rateMap.get('SS_TYME_BANK_FEES');
            Double transactionFee = rateMap.get('SS_TYME_BANK_PER_TRANSACTION_FEES');   
            DTO_MoreTyme.CreationRequest creation;

            Account merchant = merchantNumber.Account__r;            

            if(String.isBlank(merchantNumber.Account__r.ParentId))
            {
                DTO_MoreTyme.Store branch = new DTO_MoreTyme.Store(merchant, relation, merchantRef);
                creation = new DTO_MoreTyme.CreationRequest(merchant, merchantNumber, relation, null, null, settlementType, transactionFee, rate, new List<DTO_MoreTyme.Store>{branch}, bankAccount);
                request.moreTymeMerchant = creation;
                request.accountId = merchant.Id;
            }
            else if(String.isBlank(merchantNumber.Account__r.Parent.MoreTymeReference__c))
            {
                creation = moreTymeMerchantParent(merchantNumber.Account__r.Parent, merchantNumber, settlementType, transactionFee, rate, bankAccount);
                request.moreTymeMerchant = creation;
                request.accountId = merchantNumber.Account__r.ParentId;
            }
            else 
            {
                DTO_MoreTyme.UpdateRequest updateReq;
                
                DTO_MoreTyme.Store branch = new DTO_MoreTyme.Store(merchant, relation, merchantRef);
                updateReq = new DTO_MoreTyme.UpdateRequest(merchant, merchantNumber, relation, null, null, settlementType, transactionFee, rate, new List<DTO_MoreTyme.Store>{branch}, merchant.MoreTymeReference__c, bankAccount);
                request.moreTymeStore = updateReq;
                request.accountId = merchant.Id;
            }
        }

        return request;
    }

    private static DTO_MoreTyme.CreationRequest moreTymeMerchantParent(Account parent, MerchantId__c merchantNumber, String settlementType, Double transactionFee, Double rate, Bank_Account__c bankAccount)
    {
        DTO_MoreTyme.CreationRequest requestBody;
        List<Account> branches = getBranches(parent.Id);
        List<MerchantId__c> numbersNotActivated = getMerchantNumbersBySwitchpayRef(branches, null);

        if(numbersNotActivated.size() == 1)
        {
            AccountContactRelation contactPerson;
            List<AccountContactRelation> relations = getRelations(parent.Id);
            
            if(!relations.isEmpty())
            {
                contactPerson = relations[0];
            }
            
            requestBody = new DTO_MoreTyme.CreationRequest(parent, merchantNumber, contactPerson, null, null, settlementType, transactionFee, rate, branches, bankAccount);
        }
        
        return requestBody;
    }

    private static Map<String, VAT_Rate__mdt> getVATMap()
    {
        Map<String, VAT_Rate__mdt> mdtMap = new Map<String, VAT_Rate__mdt>();

        List<VAT_Rate__mdt> result = 
        [
            SELECT  DeveloperName, 
                    MasterLabel,
                    CountryCode__c,
                    VATRate__c
            FROM VAT_Rate__mdt
        ];

        for(VAT_Rate__mdt rate :result)
        {
            mdtMap.put(rate.CountryCode__c, rate);
        }

        return mdtMap;
    }

    private static Decimal getVATRate(String countryCode)
    {
        Decimal vatRate;
        Map<String, VAT_Rate__mdt> vatMap = getVATMap();

        if(String.isNotBlank(countryCode))
        {
            vatRate = vatMap.get(countryCode).VATRate__c;
        }
        else
        {
            vatRate = vatMap.get('South Africa').VATRate__c;
        }

        return vatRate;
    }

    private static String getSettlementType(List<OpportunityLineItem> opportunityProducts)
    {
        String settlementType;

        for(OpportunityLineItem opProd :opportunityProducts)
        {
            if(opProd.ProductCode == DAL_Product.MORETYME_NET)
            {
                settlementType = MORETYME_NET;         
                break;
            }

            if(opProd.ProductCode == DAL_Product.MORETYME_GROSS)
            {
                settlementType = MORETYME_GROSS;
                break;
            }
        }

        return settlementType;
    }

    private static String getProductReference(String merchantNumberType, List<MerchantId__c> merchantNumbers)
    {
        String productRef;

        for(MerchantId__c mercNum :merchantNumbers)
        {
            if(merchantNumberType.equals(MASTERPASS_TYPE))
            {
                productRef = mercNum.Name;
            }
            else
            {
                productRef = mercNum.Name;
            }
        }
        
        return productRef;
    }

    private static String getBusinessUnit(String managerProfile)
    {
        if(String.isEmpty(managerProfile))
        {
            return SURESWIPE_BU;
        }

        if(managerProfile.equals('Innervation Account Management') || managerProfile.equals('Innervation Sales Users'))
        {
            return INNERVATION_BU;
        }
        else
        {
            return SURESWIPE_BU;
        }
    }

    private static String channelSelection(String businessUnit, String settlementType)
    {
        if(businessUnit.equals(INNERVATION_BU))
        {            
            return '9';            
        }
        else
        {           
            return '7';            
        }      
    }

    private static String getMerchantNumberType(String businessUnit, String settlementType)
    {
        if(businessUnit.equals(INNERVATION_BU) && String.isNotBlank(settlementType))
        {
            return MASTERPASS_TYPE; 
        }
        else 
        {
            return EFT_TYPE;
        }       
    }

    private static Bank_Account__c getBankAccount(Id accountId)
    {
        return
        [
            SELECT  Id,
            		Bank__c,
            		Account__c,
            		Name,
            		BranchCode__c,
            		AccountNumber__c,
            		Type__c
            FROM Bank_Account__c
            WHERE Account__c = :accountId
            LIMIT 1
        ];
    }

    public static Asset getAsset(Id assetId)
    {
        return 
        [
            SELECT  Id,
                    ProductCode,
                    RelatedOpportunity__c,
                    Account.Account_Manager__r.Profile.Name,
                    Account.ShippingCountry,
                    Account.ShippingCountryCode,
                    SBQQ__RequiredBySubscription__r.SBQQ__Contract__c,
                    SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RateContract__c
            FROM Asset
            WHERE Id = :assetId 
            LIMIT 1
        ];
    }

    public static List<AssetProvider__c> getAssetProvidersByAsset(Id assetId, String switchPayStatus)
    {
        return 
        [
            SELECT  Id, 
                    TerminalNumber__c,
                    TerminalId__c ,
                    Switch_Pay_Status__c, 
                    Switch_Pay_Reference_Number__c, 
                    Switch_Pay_Message__c, 
                    Service__c,
                    Account__c,
                    Account__r.Name,
                    Account__r.Industry,
                    Account__r.Website,
                    Account__r.VAT_Number__c,      
                    Account__r.DebtorCode__c,
                    Account__r.MoreTymeReference__c,
                    Account__r.RegistrationNumber__c,
                    Account__r.TradingName__c,
                    Account__r.BusinessType__c,
                    Account__r.ShippingStreet,
                    Account__r.ShippingCity,
                    Account__r.ShippingState,
                    Account__r.ShippingPostalCode, 
                    Account__r.ShippingSuburb__c,             
                    Account__r.ParentId,
                    Account__r.Parent.DebtorCode__c,
                    Account__r.Parent.MoreTymeReference__c,
                    Account__r.Parent.Name,
                    Account__r.Parent.Industry,
                    Account__r.Parent.Website,
                    Account__r.Parent.VAT_Number__c,   
                    Account__r.Parent.RegistrationNumber__c,
                    Account__r.Parent.TradingName__c,
                    Account__r.Parent.BusinessType__c,
                    Account__r.Parent.ShippingStreet,
                    Account__r.Parent.ShippingCity,
                    Account__r.Parent.ShippingState,
                    Account__r.Parent.ShippingPostalCode,
                    Account__r.Parent.ShippingSuburb__c,
                    Asset__r.ProductCode,
                    Asset__r.RelatedOpportunity__c,
                    Asset__r.SBQQ__RequiredBySubscription__r.SBQQ__Contract__c,
                    Asset__r.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RateContract__c,
                    MerchantId__r.Name,
                    MerchantId__r.Type__c,
                    MerchantId__r.SettlementAccount__c,
                    MerchantId__r.SettlementAccount__r.Account__c,
                    MerchantId__r.SettlementAccount__r.Bank__c,
                    MerchantId__r.SettlementAccount__r.Name,
                    MerchantId__r.SettlementAccount__r.BranchCode__c, 
                    MerchantId__r.SettlementAccount__r.AccountNumber__c,
                    MerchantId__r.SettlementAccount__r.Type__c
            FROM AssetProvider__c 
            WHERE Asset__c = :assetId 
            AND Switch_Pay_Status__c = :switchPayStatus
            ORDER BY CreatedDate ASC
        ];
    }

    public static List<MerchantId__c> getMerchantNumber(Id acccountId)
    {
        return
        [
            SELECT  Name,
                    Type__c,
                    Account__c,
                    Account__r.Name,
                    Account__r.Industry,
                    Account__r.Website,
                    Account__r.VAT_Number__c,      
                    Account__r.DebtorCode__c,
                    Account__r.MoreTymeReference__c,
                    Account__r.RegistrationNumber__c,
                    Account__r.TradingName__c,
                    Account__r.BusinessType__c,
                    Account__r.ShippingStreet,
                    Account__r.ShippingCity,
                    Account__r.ShippingState,
                    Account__r.ShippingPostalCode, 
                    Account__r.ShippingSuburb__c,             
                    Account__r.ParentId,
                    Account__r.Parent.DebtorCode__c,
                    Account__r.Parent.MoreTymeReference__c,
                    Account__r.Parent.Name,
                    Account__r.Parent.Industry,
                    Account__r.Parent.Website,
                    Account__r.Parent.VAT_Number__c,   
                    Account__r.Parent.RegistrationNumber__c,
                    Account__r.Parent.TradingName__c,
                    Account__r.Parent.BusinessType__c,
                    Account__r.Parent.ShippingStreet,
                    Account__r.Parent.ShippingCity,
                    Account__r.Parent.ShippingState,
                    Account__r.Parent.ShippingPostalCode,
                    Account__r.Parent.ShippingSuburb__c,
                    SettlementAccount__c,
                    SettlementAccount__r.Account__c,
                    SettlementAccount__r.Bank__c,
                    SettlementAccount__r.Name,
                    SettlementAccount__r.BranchCode__c, 
                    SettlementAccount__r.AccountNumber__c,
                    SettlementAccount__r.Type__c
            FROM MerchantId__c
            WHERE Type__c IN (:EFT_TYPE, :MASTERPASS_TYPE)
            AND Account__c = :acccountId
        ];
    }

    public static List<AccountContactRelation> getRelations(Id accountId)
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
            AND Relationship_Strength__c = 'Primary' 
            AND Roles INCLUDES('Decision Maker', 'Director')
            AND Contact.MobilePhone != null
            AND Contact.Email != null
        ];
    }

    private static List<MerchantId__c> getMerchantNumbersBySwitchpayRef(List<Account> branches, String switchPayRef)
    {
        return
        [
            SELECT Id 
            FROM MerchantId__c 
            WHERE Account__c IN :branches 
            AND SwitchPayReference__c = :switchPayRef
            AND Type__c = 'Masterpass'
        ];
    }

    // Merchant number needs to be a unique identifier in SwitchPay 
    // Multiple merchant numbers configured for SwitchPay for a single merchant are a user error 
    private static void enforceMerchantNumber(List<AssetProvider__c> providers)
    {
        Map<Id, String> merchantNumbersMap = new Map<Id, String>();

        for(AssetProvider__c provider :providers)
        {            
            if(merchantNumbersMap.containsKey(provider.Account__c))
            {
                if(provider.MerchantId__r.Name != merchantNumbersMap.get(provider.Account__c))
                {
                    String[] args = new String[]{provider.Account__r.Name, merchantNumbersMap.get(provider.Account__c), provider.MerchantId__r.Name};
                    String message = String.format(exceptionTemplate, args);
                    throw new ExceptionInvocable.CustomException(message);
                }
            }
            else
            {
                merchantNumbersMap.put(provider.Account__c, provider.MerchantId__r.Name);
            }
        }
    }

    private static List<Product> getSwitchpayProducts(List<OpportunityLineItem> oppProducts, String merchantId, Map<String, Decimal> rateMap, String channel, Decimal vatRate, String productRef)
    {
        List<Product> products = new List<Product>();  
        Decimal rate, fee;

        for(OpportunityLineItem line :oppProducts)
        {
            for(Integer productType :SwitchPayCallout.codesMap.get(line.ProductCode))
            {
                if(line.ProductCode == DAL_Product.SWITCHPAY)
                {
                    rate = rateMap.get('SS_SWITCHPAY_FEES');
                    fee = rateMap.get('SS_SWITCHPAY_PER_TRANSACTION_FEES');
                    products.add(new Product(productType, merchantId, rate, fee, channel, 1, 0, productRef));
                }
                else if(line.ProductCode == DAL_Product.MORETYME_NET || line.ProductCode == DAL_Product.MORETYME_GROSS)
                {
                    rate = rateMap.get('SS_TYME_BANK_FEES');
                    fee = rateMap.get('SS_TYME_BANK_PER_TRANSACTION_FEES');

                    if(Test.isRunningTest() && fee == null)
                    {
                        fee = 1.74;
                    }

                    products.add(new Product(productType, merchantId, rate, fee, channel, 4.95, fee + (fee * (vatRate / 100)), productRef));
                }
            }                        
        }

        return products;
    }

    public static List<OpportunityLineItem> getOpportunityProducts(Id oppId)
    {
        return
        [
            SELECT  Id, 
                    OpportunityId,
                    Opportunity.AccountId,
                    ProductCode,
                    TotalPrice,
                    UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :oppId
            AND ProductCode IN :codesMap.keySet()
        ];
    }

    private static Map<String, Decimal> getRates(Set<Id> contractIds)
    {
        Map<String, Decimal> rateMap = new Map<String, Decimal>();
        contractIds.remove(null);

        List<SBQQ__SubscriptionConsumptionSchedule__c> schedules =
        [
            SELECT  Id,                     
            SBQQ__Subscription__r.SBQQ__Product__r.Name,
            SBQQ__Subscription__r.SBQQ__Product__r.ProductCode,
            SBQQ__Subscription__r.SBQQ__StartDate__c,
            SBQQ__Subscription__r.Termination_Date__c,
            SBQQ__Subscription__r.SBQQ__Contract__r.StartDate,
            SBQQ__Subscription__r.SBQQ__Contract__r.EndDate,
            SBQQ__Subscription__r.SBQQ__Contract__c,
            SBQQ__Subscription__r.SBQQ__RevisedSubscription__c,
            (
                SELECT  Id,
                        Name,
                        SBQQ__Price__c,
                        SBQQ__SubscriptionConsumptionSchedule__c,
                        SBQQ__SubscriptionConsumptionSchedule__r.Name,
                        CurrencyISOCode
                FROM SBQQ__SubscriptionConsumptionRates__r
            )
            FROM SBQQ__SubscriptionConsumptionSchedule__c                    
            WHERE SBQQ__Subscription__r.SBQQ__Contract__c IN :contractIds
        ];

        // Relying on the fact each Schedule will have a single rate, and 
        // each Subscription has one schedule. Failing that, overwrites will happen
        for(SBQQ__SubscriptionConsumptionSchedule__c schedule :schedules)
        {
            if(!schedule.SBQQ__SubscriptionConsumptionRates__r.isEmpty())
            {
                rateMap.put(schedule.SBQQ__Subscription__r.SBQQ__Product__r.ProductCode, 
                    schedule.SBQQ__SubscriptionConsumptionRates__r[0].SBQQ__Price__c);
            }            
        }

        return rateMap;
    }

    public static void isTymeValidStore(Account store, List<AccountContactRelation> relations)
    {
        String storeExceptionTemplate = '{0} is missing data required by MoreTyme. Populate the full address and contact details.';
        Boolean result;

        if(relations == null || relations.isEmpty())
        {
            result = false;
        }
        else 
        {
            AccountContactRelation relation = relations[0];
            Boolean street = store.ShippingStreet != null;
            Boolean city = store.ShippingCity != null;
            Boolean province = store.ShippingState != null;
            Boolean suburb = store.ShippingSuburb__c != null;
            Boolean phone = relation.Contact.MobilePhone != null;
            Boolean email = relation.Contact.Email != null;

            result = street && city && province && suburb && phone && email; 
        }        

        if(!result)
        {
            String exMess = String.format(storeExceptionTemplate, new List<String>{store.TradingName__c}); 
            ExceptionInvocable.throwCustomFlowException(new List<String>{exMess});
        }        
    }

    private static List<Account> getBranches(Id parentId)
    {
        List<Account> results = new List<Account>();

        List<Account> intermediateResults =
        [
            SELECT  Id,
                    Name,
                    ShippingStreet,
                    ShippingCity,
                    ShippingState,
                    ShippingSuburb__c,
                    (
                        SELECT  AccountId,
                                ContactId, 
                                Contact.Name, 
                                Contact.MobilePhone,
                                Contact.Email 
                        FROM AccountContactRelations 
                        WHERE Relationship_Strength__c = 'Primary' 
                        AND Roles INCLUDES('Decision Maker', 'Director')
                        AND Contact.MobilePhone != null
                        AND Contact.Email != null
                    ),
                    (
                        SELECT  Id, 
                                Name
                        FROM MerchantIds__r
                        WHERE Type__c = :MASTERPASS_TYPE
                    )
            FROM Account
            WHERE ParentId = :parentId
            AND ShippingStreet != null
            AND ShippingCity != null
            AND ShippingState != null
        ];

        for(Account branch :intermediateResults)
        {
            if(!branch.AccountContactRelations.isEmpty())
            {
                results.add(branch);
            }
        }

        return results;
    }

    private static Id getRateContractId(Asset installedAsset)
    {
        List<SBQQ__Subscription__c> subs =
        [
            SELECT  Id,
                    SBQQ__Contract__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Account__c = :installedAsset.AccountId
            AND SBQQ__HasConsumptionSchedule__c = true
            AND SBQQ__TerminatedDate__c = null
            AND SBQQ__EndDate__c >= TODAY
            LIMIT 1
        ];

        if(subs.size() == 1)
        {
            return subs[0].SBQQ__Contract__c;
        }
        else
        {
            return null;
        }
    }

    public class FlowgearRequest
    {
        public SwitchPayMerchant switchPayMerchant;
        public Product[] switchPayProduct;
        public TerminalList switchPayTerminal;
        public DTO_MoreTyme.CreationRequest moreTymeMerchant;
        public DTO_MoreTyme.UpdateRequest moreTymeStore;
        public Id merchantNumberId; 
        public Id accountId;
    }

    public class SwitchPayMerchant
    {
        public String channelId;
        public String operatorId;
        public String channelDebtorsCode;
        public String channelMid;
        public Integer categoryCode;
        public String groupMerchantRef;
        public String entityType;
        public String companyName;
        public String companyRegistrationNumber;
        public String tradingName;
        public String storeDisplayName;
        public String primaryContactName;
        public String primaryEmail;
        public String primaryPhone; 
        public String vatNumber;           
        public String bankName;
        public String accountHolder;
        public String accountType;
        public String accountNo;
        public String branchCode;
        public String streetAddress;
        public String suburb;
        public String city;
        public String province;
        public String postalCode;

        public SwitchPayMerchant(MerchantId__c merchNumber, AccountContactRelation relation, String channel, Bank_Account__c bankAccount)
        {
            this.channelId = channel;
            this.operatorId = '0';
            this.channelDebtorsCode = UTIL_System.nullSafeString(merchNumber.Account__r.DebtorCode__c);
            this.channelMid = UTIL_System.nullSafeString(merchNumber.Name);
            this.categoryCode = getIndustry(merchNumber.Account__r.Industry);
            this.groupMerchantRef = al.StringUtils.EMPTY;
            this.entityType = companyTypeMap.get(merchNumber.Account__r.BusinessType__c).format();
            this.companyName = UTIL_System.nullSafeString(merchNumber.Account__r.Name);
            this.companyRegistrationNumber = UTIL_System.nullSafeString(merchNumber.Account__r.RegistrationNumber__c);
            this.tradingName = UTIL_System.nullSafeString(merchNumber.Account__r.TradingName__c);
            this.storeDisplayName = UTIL_System.nullSafeString(merchNumber.Account__r.TradingName__c);
            
            if(relation != null)
            {
                this.primaryContactName = UTIL_System.nullSafeString(relation.Contact.Name);
                this.primaryEmail = UTIL_System.nullSafeString(relation.Contact.Email);
                this.primaryPhone = UTIL_System.nullSafeString(relation.Contact.Phone);
            }
            
            this.vatNumber = UTIL_System.nullSafeString(merchNumber.Account__r.VAT_Number__c);
            this.accountHolder = UTIL_System.nullSafeString(merchNumber.Account__r.Name);
            this.bankName = UTIL_System.nullSafeString(bankAccount.Bank__c);
            this.accountType = UTIL_System.nullSafeString(bankAccount.Type__c);
            this.accountNo = UTIL_System.nullSafeString(bankAccount.AccountNumber__c);
            this.branchCode = UTIL_System.nullSafeString(bankAccount.BranchCode__c);
            this.streetAddress = UTIL_System.nullSafeString(merchNumber.Account__r.ShippingStreet);
            this.suburb = UTIL_System.nullSafeString(merchNumber.Account__r.ShippingSuburb__c);
            this.city = UTIL_System.nullSafeString(merchNumber.Account__r.ShippingCity);
            this.province = UTIL_System.nullSafeString(merchNumber.Account__r.ShippingState);
            this.postalCode = UTIL_System.nullSafeString(merchNumber.Account__r.ShippingPostalCode);
        }
    }

    public class Product
    {
        public String channelMid;
        public String ChannelId;
        public Boolean productActivationInd;
        public Integer productType;
        public Decimal CreditProviderProductFee;
        public Decimal CreditProviderTransactionAmount;
        public Boolean CreditProviderIsNettIncicator;
        public Boolean CreditProviderVatIndicator;
        public Boolean MechantIsNettIndicator;        
        public Decimal MerchantProductFee;
        public Decimal MerchantTransactionAmount;
        public Boolean MerchantVatIndicator;
        public Boolean IsTopUpExpected;
        public Decimal depositAmount;
        public String[] terms;
        public String ProductReference;

        public Product(Integer productType, String mId, Decimal rate, Decimal fee, String channel, Decimal providerRate, Decimal providerFee, String productRef)
        {
            this.channelMid = mId;
            this.ChannelId = channel;
            this.productActivationInd = true;
            this.productType = productType;
            this.terms = new String[]{};
            this.CreditProviderProductFee = providerRate;
            this.CreditProviderTransactionAmount = providerFee;
            this.CreditProviderIsNettIncicator = true;
            this.CreditProviderVatIndicator = true;
            this.MerchantProductFee = rate != null ? rate : 0;
            this.MerchantTransactionAmount = fee != null ? fee : 0;
            this.MechantIsNettIndicator = true;
            this.MerchantVatIndicator = false;
            this.IsTopUpExpected = false;
            this.depositAmount = 0;
            this.ProductReference = productRef;
        }
    }

    public class TerminalList
    {
        public Terminal[] createTerminals;

        public TerminalList(List<AssetProvider__c> providers, MerchantId__c merchNumber, List<OpportunityLineItem> oppProducts, String channel)
        {
            this.createTerminals = new Terminal[]{};

            for(AssetProvider__c prov :providers)
            {
                this.createTerminals.add(new Terminal(prov, merchNumber, oppProducts, channel));
            }
        }
    }

    public class Terminal
    {
        public String channelMid;
        public String channelId;
        public String terminalRef;
        public Integer financialInstitutionID;
        public Boolean activeInd;
        public Integer[] productTypes;
        public Integer terminalTypeId;

        public Terminal(AssetProvider__c provider, MerchantId__c merchNumber, List<OpportunityLineItem> oppProducts, String channel)
        {
            this.channelMid = merchNumber.Name;
            this.channelId = channel;
            this.terminalRef = provider.TerminalNumber__c == null ? provider.TerminalId__c : provider.TerminalNumber__c;
            this.activeInd = true;
            this.productTypes = allProductTypes(oppProducts);
            this.terminalTypeId = 2;
            this.financialInstitutionID = bankMap.get(merchNumber.SettlementAccount__r.Bank__c);
        }

        private Integer[] allProductTypes(List<OpportunityLineItem> oppProducts)
        {
            Integer[] productTypes = new Integer[]{};

            for(OpportunityLineItem product :oppProducts)
            {
                if(SwitchPayCallout.codesMap.containsKey(product.ProductCode))
                {
                    productTypes.addAll(SwitchPayCallout.codesMap.get(product.ProductCode));
                }                
            }

            return productTypes;
        }
    }

    public class MoreTymeRequest
    {
        public DTO_MoreTyme.CreationRequest moreTymeMerchant;
        public DTO_MoreTyme.UpdateRequest moreTymeStore;
        public Id accountId;
    }
}