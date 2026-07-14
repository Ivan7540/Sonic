public class DAL_Account
{
	@TestVisible
	private static final String NAME_TEST_COMPANY = 'Test Company';

	public static final String STATUS_ACTIVE = 'Active';
	public static final String STATUS_INACTIVE = 'Inactive';
	public static final String STATUS_SUSPENDED = 'Suspended';

	public static final String REASON_INACTIVE_UNPAID_DEBIT_ORDER = 'Unpaid debit order';

	public static final String INDUSTRY_FASHION = 'Fashion';

	public static final String TYPE_PROSPECT = 'Prospect';

	public static final String BANK_MBL = 'MBL';

	public static final String FIELD_BASIC_SURESWIPE_EFT = 'Basic_SureSwipe_EFT__c';
	public static final String FIELD_COMMISSION_MONTH_EFT = 'Commission_Month__c';
	public static final String FIELD_SURESWIPE_MOVE = 'SureSwipe_Move__c';
	public static final String FIELD_COMMISSION_MONTH_MOVE = 'Move_Commission_Month__c';
	//Add for Portable Lite ASIS-821
	public static final String FIELD_BASIC_SURESWIPE_PORTABLE_LITE = 'Basic_SureSwipe_Portable_Lite__c';
	public static final String FIELD_COMMISSION_MONTH_PORTABLE_LITE = 'Portable_Lite_Commission_Month__c';
	public static final String FIELD_SURESWIPE_GIFT_CARDS = 'SureSwipe_Gift_Cards__c';
	public static final String FIELD_SURESWIPE_LOYALTY = 'SureSwipe_Loyalty__c';
	public static final String FIELD_INTEGRATED_MERCHANT_VIA_OTHER = 'Integrated_Merchant_Via_Other__c';
	public static final String FIELD_INTEGRATED_MERCHANT_VIA_MBL = 'Integrated_Merchant_Via_MBL__c';
	public static final String FIELD_COMMISSION_MONTH_INTEGRATED = 'IPOS_Commission_Month__c';
	public static final String FIELD_MOVE_INSTALL_DATE = 'Move_Install_Date__c';
	//Add for Portable Lite ASIS-821
	public static final String FIELD_PORTABLE_LITE_INSTALL_DATE = 'Portable_Lite_Install_Date__c';
	public static final String FIELD_GIFT_PROGRAM_INSTALLATION_DATE = 'Gift_Program_Installation_Date__c';
	public static final String FIELD_LOYALTY_PROGRAM_INSTALLATION_DATE = 'Loyalty_Program_Installation_Date__c';
	public static final String FIELD_DATE_INSTALLED = 'Date_Installed__c';
	public static final String FIELD_INTEGRATED_INSTALL_DATE = 'Integrated_Install_Date__c';
	public static final String FIELD_MOVE_ACTUAL_MTD_CREDIT_CARD_SWIPE_VALUE = 'MTD_Swipe_Margin__c';
	public static final String FIELD_MOVE_ACTUAL_MTD_DEBIT_CARD_SWIPE_VALUE = 'MOVE_Actual_MTD_Debit_Card_Swipe_Value__c';
	public static final String FIELD_MOVE_TOTAL_MTD_SWIPE_VALUE = 'MOVE_Total_MTD_Swipe_Value__c';
	public static final String FIELD_MOVE_MTD_SWIPE_MARGIN = 'MOVE_MTD_Swipe_Margin__c';
	public static final String FIELD_ACTUAL_MTD_CREDIT_CARD_SWIPE_VALUE = 'Actual_MTD_Credit_Card_Swipe_Value__c';
	public static final String FIELD_ACTUAL_MTD_DEBIT_CARD_SWIPE_VALUE = 'Actual_MTD_Debit_Card_Swipe_Value__c';
	public static final String FIELD_TOTAL_MTD_SWIPE_MARGIN = 'Total_MTD_Swipe_Value__c';
	public static final String FIELD_MTD_SWIPE_MARGIN = 'MTD_Swipe_Margin__c';
	public static final String FIELD_VAS_BILLING_STRUCTURE = 'VAS_Billing_Structure__c';

	public static final String REGION_GAUTENG = 'Gauteng';
	public static final String REGION_WESTERN_CAPE = 'Western Cape';
	public static final String REGION_KZN = 'KZN';
	public static final String REGION_LIMPOPO = 'KZN';

	public static List<Account> getAll()
	{
		return
		[
				SELECT Id,
						Name
				FROM Account
		];
	}
	public static List<Account> forSwitchpayJSON(List<Id> switchpayId)
	{
		return
		[
				SELECT
						Id,
						Name,
						DebtorCode__c,
						RegistrationNumber__c,
						TradingName__c,
				(Select Id,Name,Phone,Email from Contacts limit 1),
				(Select id,Bank__c,BranchCode__c,AccountNumber__c from Bank_Accounts__r),
				(Select id,TerminalNumber__c,Switch_Pay_Status__c,Switch_Pay_Reference_Number__c,Switch_Pay_Message__c,Service__c from AssetProviders__r)
				FROM
						Account
				WHERE
						Id IN (SELECT Account__c FROM AssetProvider__c WHERE Id IN:switchPayId AND Service__c = 'Switch Pay')
		];
	}

	public static List<Account> fordebtorCodeJSON(List<Id> oppId)
	{
		List<Account> results = new List<Account>();
		List<Account> returnAccounts =
		[
				SELECT
						Id,
						Name,
						RegistrationNumber__c,
						BillingStreet,
						BillingCity,
						BillingPostalCode,
						ShippingStreet,
						ShippingCity,
						ShippingPostalCode,
						Phone,
				(SELECT Id from Opportunities),
				(SELECT AccountId,Contact.Title,Contact.LastName,Contact.FirstName,Contact.MobilePhone,Contact.Email,Relationship_Strength__c,Roles from AccountContactRelations where Relationship_Strength__c = 'Primary' AND (Roles INCLUDES('Decision Maker') OR Roles INCLUDES('Decision Maker', 'Director') OR Roles INCLUDES('Director')) ORDER BY CreatedDate ASC)
				FROM Account
				WHERE Id IN (SELECT AccountId from Opportunity WHERE Id IN:oppId)

		];
		Set<Id> withoutContact = new Set<Id>();
		for (Account acc : returnAccounts)
		{
			if (acc.AccountContactRelations.isEmpty())
			{
				withoutContact.add(acc.Id);
			}
			else
			{
				results.add(acc);
			}
		}

		List<Account> withoutPrimary =
		[
				SELECT
						Id,
						Name,
						RegistrationNumber__c,
						BillingStreet,
						BillingCity,
						BillingPostalCode,
						ShippingStreet,
						ShippingCity,
						ShippingPostalCode,
						Phone,
				(SELECT Id from Opportunities),
				(SELECT AccountId,Contact.Title,Contact.LastName,Contact.FirstName,Contact.MobilePhone,Contact.Email,Relationship_Strength__c,Roles from AccountContactRelations ORDER BY CreatedDate ASC LIMIT 1)
				FROM Account
				WHERE Id IN :withoutContact
		];

		results.addAll(withoutPrimary);
		return results;
	}


	@testVisible
	private static Account newItem()
	{
		return newItem(NAME_TEST_COMPANY);
	}

	@testVisible
	private static Account newItem(String accountName)
	{
		Account account = new Account(
				Name = accountName
		);
		return account;
	}

	@testVisible
	private static Account insertItem()
	{
		Account account = newItem();
		DAL_BaseObject.insertDbObject(account);
		return account;
	}
}