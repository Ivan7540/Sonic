/**
 * Created by ViktorijaR on 1/18/2022.
 */

@IsTest
private class TEST_FLOW_DealWizardRate
{
	private static FLOW_DealWizardRate.DealRequest dRequest;
	private static String dealId;
	private static Integer debit;
	private static Integer credit;
	private static Deal_Line__c bundleLineNew;
	private static String productName;
	private static String deviceName;
	private static String contractTerm;
	private static Integer quantity;
	private static String bundleId;
	private static String metadataId;

	static void setup()
	{
		productName = 'Classic';
		deviceName = 'SS_SP_630';
		contractTerm = '24Month';
		quantity = 1;
		metadataId = 'm0H3L0000008QWsUAM';
		bundleId = '';

	}

	@IsTest
	static void testupdateRateLines()
	{
		setup();

		List<Deal__c> deal = TestDataFactory.createDeals(1);
		dealId = deal[0].Id;

		TestDataFactory.createTestOnceOffProduct('SS_DOMESTIC_DEBIT_CARD_FEES');
		TestDataFactory.createTestOnceOffProduct('SS_DOMESTIC_CREDIT_CARD_FEES');
		TestDataFactory.createTestOnceOffProduct('SS_INTERNATIONAL_DEBIT_CARD_FEES');
		TestDataFactory.createTestOnceOffProduct('SS_INTERNATIONAL_CREDIT_CARD_FEES');
		Product2 product = TestDataFactory.createTestOnceOffProduct('SS_SP_630');

		Deal_Line__c dealLine = new Deal_Line__c(
					Deal__c = dealId,
					Name = 'Classic SS_SP_630',
					Product__c = 'Classic',
					Device__c = 'SS_SP_630',
					ContractTerm__c = '24Month',
					Quantity__c = 1,
					Rate__c=product.Id,
					LineType__c='VAS'
		);
		insert dealLine; 

		bundleLineNew = DealProductController.createBundleLine(productName, deviceName, contractTerm, quantity, dealId, bundleId, metadataId);
		bundleId = bundleLineNew.Id;

		List<DealProductController.DeviceLineInformation> deviceInfo = DealProductController.queryDeviceLines(bundleId, metadataId);
		for (DealProductController.DeviceLineInformation aInfo : deviceInfo)
		{
			for (DealProductController.ServiceConfig aConfig : aInfo.serviceList)
			{
				if(aConfig.apiName == 'Acquiring')
				{
					aConfig.value = true;
				}
			}
		}

		String deviceInfoString = JSON.serialize(deviceInfo);
		DealProductController.createVasLines(deviceInfoString, bundleId);

		dRequest = new FLOW_DealWizardRate.DealRequest();
		dRequest.dealId = dealId;
		dRequest.debit = debit;
		dRequest.credit = credit;

		Test.startTest();
		FLOW_DealWizardRate.updateRateLines(new List<FLOW_DealWizardRate.DealRequest>{dRequest});
		Test.stopTest();
	}
}