/*
Date created: 27/10/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1039
*/
global class DTO_MoreTyme
{    
    global class CreationRequest
    {
        public Merchant merchant;
        public MoreTymeSetting setting;

        global CreationRequest(Account merchant, MerchantId__c merchantNumber, AccountContactRelation authorized, AccountContactRelation financial, Datetime openingDate, String settlementType, Double fee, Decimal rate, List<Account> branches, Bank_Account__c bankAccount)
        {
            this.merchant = new Merchant(merchant, merchantNumber, authorized, financial, settlementType, fee, rate, branches, bankAccount);
            String notificationEmail = authorized != null ? authorized.Contact.Email: null;
            this.setting = new MoreTymeSetting(openingDate, notificationEmail);
        }

        global CreationRequest(Account merchant, MerchantId__c merchantNumber, AccountContactRelation authorized, AccountContactRelation financial, Datetime openingDate, String settlementType, Double fee, Decimal rate, List<Store> branches, Bank_Account__c bankAccount)
        {
            this.merchant = new Merchant(merchant, merchantNumber, authorized, financial, settlementType, fee, rate, branches, bankAccount);
            String notificationEmail = authorized != null ? authorized.Contact.Email: null;
            this.setting = new MoreTymeSetting(openingDate, notificationEmail);
        }
    }

    global class UpdateRequest
    {
        public Merchant merchant;
        public MoreTymeSetting setting;
        public String referenceId;

        global UpdateRequest(Account merchant, MerchantId__c merchantNumber, AccountContactRelation authorized, AccountContactRelation financial, Datetime openingDate, String settlementType, Double fee, Decimal rate, List<Store> branches, String refId, Bank_Account__c bankAccount)
        {
            this.referenceId = refId;
            this.merchant = new Merchant(merchant, merchantNumber, authorized, financial, settlementType, fee, rate, branches, bankAccount);
            String notificationEmail = authorized != null ? authorized.Contact.Email: null;
            this.setting = new MoreTymeSetting(openingDate, notificationEmail);
        }
    }

    global class Merchant
    {
        public String fullName;
        public String type;
        public String displayName;
        public String websiteURL;
        public String email;
        public String vatNumber;
        public String registrationNumber;
        public String physicalAddress;
        public String bankAccountNumber;
        public String bankName;
        public String accountName;
        public String settlementFrequency;
        public String settlementDay;
        public String invoiceFrequency;
        public Integer invoiceDay;
        public String fileDeliveryMethod;
        public String authorizedContactName;
        public String authorizedContactPhone;
        public String authorizedContactEmail;
        public String authorizedFinancialContact;
        public String authorizedFinancialContactEmail;
        public String settleType;
        public Double commissionRate;
        public Double transactionFee;
        public Store[] stores;
                
        global Merchant(Account merchant, MerchantId__c merchantNumber, AccountContactRelation authorized, AccountContactRelation financial, String settlementType, Double fee, Decimal rate, List<Account> branches, Bank_Account__c bankAccount)
        {
            this.fullName = merchant.Name;
            this.websiteURL = merchant.Website;            
            this.vatNumber = merchant.VAT_Number__c;
            this.registrationNumber = merchant.RegistrationNumber__c;
            this.physicalAddress = UTIL_System.addressConversion(merchant, Account.ShippingAddress.getDescribe().getLocalName());
            this.type = 'OUTLET';
            this.bankAccountNumber = bankAccount.AccountNumber__c;
            this.bankName = bankAccount.Bank__c;
            this.accountName = bankAccount.Name;
            this.settlementFrequency = 'Daily';
            this.settlementDay = al.StringUtils.EMPTY;
            this.invoiceFrequency = 'monthly';
            this.invoiceDay = null;
            this.fileDeliveryMethod = 'Email';

            if(authorized != null)
            {
                this.authorizedContactName = authorized.Contact.Name;
                this.authorizedContactPhone = authorized.Contact.MobilePhone;
                this.authorizedContactEmail = authorized.Contact.Email;
                this.email = authorized.Contact.Email;
            }
            
            if(financial != null)
            {
                this.authorizedFinancialContact = financial.Contact.Name;
                this.authorizedFinancialContactEmail = financial.Contact.Email;
            }
            
            this.settleType = settlementType;
            this.displayName = merchant.TradingName__c;
            this.commissionRate = 4.3;
            this.transactionFee = fee;

            Store[] allStores = new Store[]{};

            for(Account branch :branches)
            {
                if(branch.AccountContactRelations.size() > 0)
                {                    
                    allStores.add(new Store(branch, branch.AccountContactRelations[0], branch.MerchantIds__r[0].Name));
                }
                else
                {
                    allStores.add(new Store(branch, null, branch.MerchantIds__r[0].Name));
                }                
            }

            this.stores = allStores;
        }

        global Merchant(Account merchant, MerchantId__c merchantNumber, AccountContactRelation authorized, AccountContactRelation financial, String settlementType, Double fee, Decimal rate, List<Store> branches, Bank_Account__c bankAccount)
        {
            this.fullName = merchant.Name;
            this.websiteURL = merchant.Website;
            
            this.vatNumber = merchant.VAT_Number__c;
            this.registrationNumber = merchant.RegistrationNumber__c;
            this.physicalAddress = UTIL_System.addressConversion(merchant, Account.ShippingAddress.getDescribe().getLocalName());
            this.type = 'OUTLET';
            this.bankAccountNumber = bankAccount.AccountNumber__c;
            this.bankName = bankAccount.Bank__c;
            this.accountName = bankAccount.Name;
            this.settlementFrequency = 'Daily';
            this.settlementDay = al.StringUtils.EMPTY;
            this.invoiceFrequency = 'monthly';
            this.invoiceDay = null;
            this.fileDeliveryMethod = 'Email';

            if(authorized != null)
            {
                this.authorizedContactName = authorized.Contact.Name;
                this.authorizedContactPhone = authorized.Contact.MobilePhone;
                this.authorizedContactEmail = authorized.Contact.Email;
                this.email = authorized.Contact.Email;
            }
            
            if(financial != null)
            {
                this.authorizedFinancialContact = financial.Contact.Name;
                this.authorizedFinancialContactEmail = financial.Contact.Email;
            }
            
            this.settleType = settlementType;
            this.displayName = merchant.TradingName__c;
            this.commissionRate = 4.3;
            this.transactionFee = fee;
            this.stores = branches;
        }
    }

    global class Store
    {
        public String externalMerchantId;
        public String name;
        public String address;
        public String suburb;
        public String city;
        public String province;
        public String contactName;
        public String contactPhone;
        public String contactEmail;
        public String status;

        public Store(Account childAccount, AccountContactRelation contactPerson, String merchantNumber)
        {
            this.externalMerchantId = merchantNumber;
            this.name = childAccount.Name;
            this.address = childAccount.ShippingStreet;
            this.suburb = childAccount.ShippingSuburb__c;
            this.city = childAccount.ShippingCity;
            this.province = childAccount.ShippingState;

            if(contactPerson != null)
            {
                this.contactName = contactPerson.Contact.Name;
                this.contactPhone = contactPerson.Contact.MobilePhone;
                this.contactEmail = contactPerson.Contact.Email;
            }
        }
    }

    global class MoreTymeSetting
    {
        public Datetime publishDate;
        public String notificationEmail;

        global MoreTymeSetting(Datetime openingDate, String notificationEmail)
        {
            this.publishDate = openingDate;
            this.notificationEmail = notificationEmail;
        }
    }   
}