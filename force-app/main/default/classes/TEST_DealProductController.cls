/**
 * Created by ViktorijaR on 1/17/2022.
 */

@IsTest
public with sharing class TEST_DealProductController
{
	private static String productName;
	private static String deviceName;
	private static String contractTerm;
	private static Integer quantity;
	private static String dealId;
	private static String bundleId;
	private static String metadataId;
	private static Deal_Line__c bundleLineNew;
	private static Deal_Line__c bundleLineEdit;

	static void setup()
	{
		productName = 'Classic';
		deviceName = 'SS_SP_630';
		contractTerm = '24Month';
		quantity = 1;
		metadataId = 'm0H3L0000008QWsUAM';
		bundleId = '';

		List<Deal__c> deal = TestDataFactory.createDeals(1);
		dealId = deal[0].Id;

		TestDataFactory.createTestOnceOffProduct(deviceName);
		bundleLineNew = DealProductController.createBundleLine(productName, deviceName, contractTerm, quantity, dealId, bundleId, metadataId);
		bundleId = bundleLineNew.Id;
		bundleLineEdit = DealProductController.createBundleLine(productName, deviceName, contractTerm, quantity, dealId, bundleId, metadataId);
		bundleLineEdit = DealProductController.createBundleLine(productName, deviceName, contractTerm, quantity, dealId, bundleId, metadataId);
		bundleLineEdit = DealProductController.createBundleLine(productName, 'SS_A50', contractTerm, quantity, dealId, bundleId, metadataId);

	}

	@IsTest
	static void testGetProductOptions()
	{
		Test.startTest();
		Map<String, String> productOption = DealProductController.getProductOptions();
		Test.stopTest();
		System.assertNotEquals(0, productOption.keySet().size());
	}

	@IsTest
	static void testGetDeviceOptions()
	{
		setup();
		Test.startTest();
		Map<String, String> deviceOption = DealProductController.getDeviceOptions(productName);
		Test.stopTest();
		System.assertNotEquals(0, deviceOption.keySet().size());
	}

	@IsTest
	static void getContractTermOptions()
	{
		setup();
		Test.startTest();
		List<DealProductController.BundleConfiguration> contractTermOption = DealProductController.getContractTermOptions(productName, deviceName);
		Test.stopTest();
		System.assertNotEquals(0, contractTermOption.size());
	}

	@IsTest
	static void testCreateBundleLine()
	{
		setup();

		System.assertNotEquals(null, bundleLineNew);
		System.assertNotEquals(null, bundleLineEdit);
	}

	@IsTest
	static void testGetAllVAS()
	{
		setup();
		Test.startTest();
		List<DealProductController.ServiceConfig> allVas = DealProductController.getAllVAS();
		Test.stopTest();
		System.assertNotEquals(0, allVas.size());

	}

	@IsTest
	static void testGetDeviceServiceConfig()
	{
		setup();
		Test.startTest();
		List<DealProductController.ServiceConfig> serviceCofigEmpty = DealProductController.getDeviceServiceConfig('');
		List<DealProductController.ServiceConfig> serviceCofig = DealProductController.getDeviceServiceConfig(metadataId);
		Test.stopTest();
		System.assertNotEquals(0, serviceCofig.size());

	}

	@IsTest
	static void testCreateVasLines()
	{
		setup();

		List<DealProductController.DeviceLineInformation> deviceInfo = DealProductController.queryDeviceLines(bundleId, metadataId);
		String deviceInfoString = JSON.serialize(deviceInfo);

		Test.startTest();

		String fieldsForUpdate = DealProductController.createVasLines(deviceInfoString, bundleId);
		Test.stopTest();
		System.assertNotEquals(null, fieldsForUpdate);

	}

}