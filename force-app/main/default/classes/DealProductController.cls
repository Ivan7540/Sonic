/**
 * Created by JurgitaG on 12/1/2021.
 */

public without sharing class DealProductController
{
	@AuraEnabled
	public static Map<String, String> getProductOptions()
	{
		Map<String, String> productValueMap = new Map<String, String>();
		Boolean isStandalone = FALSE;
		List<BundleConfig__mdt> fieldResult = DAL_DealBundle.getBundleProductOptions(isStandalone);

		for (BundleConfig__mdt picklistEntry : fieldResult)
		{
			productValueMap.put(picklistEntry.Product__c, picklistEntry.get('productName').toString());
		}

		return productValueMap;
	}

	//get available picklist values
	@AuraEnabled
	public static Map<String, String> getDeviceOptions(String productName)
	{
		System.debug(productName);
		Map<String, String> deviceValueMap = new Map<String, String>();
		List<BundleConfig__mdt> bundleConfigs = DAL_DealBundle.getBundleDeviceOptions(productName);
		System.debug(bundleConfigs);
		for (BundleConfig__mdt bundleConfig : bundleConfigs)
		{
			deviceValueMap.put(bundleConfig.Device__c, bundleConfig.get('deviceLabel').toString());
		}
		System.debug(deviceValueMap);
		return deviceValueMap;
	}

	@AuraEnabled
	public static List<BundleConfiguration> getContractTermOptions(String productName, String deviceName)
	{
		List<BundleConfiguration> contractTermValueMap = new List<BundleConfiguration>();
		List<BundleConfig__mdt> bundleConfigs = DAL_DealBundle.getBundleContractTermOptions(productName, deviceName);
		for (BundleConfig__mdt bundleConfig : bundleConfigs)
		{
			contractTermValueMap.add(formatBundleConfiguration(bundleConfig, bundleConfig.ContractTerm__c, bundleConfig.get('termLabel').toString()));
		}
		System.debug(contractTermValueMap);

		return contractTermValueMap;
	}

	@AuraEnabled
	public static Deal_Line__c createBundleLine(String productName, String deviceName, String contractTerm, Integer quantity, String dealId, String bundleId, String metadataId)
	{
		System.debug(metadataId);

		List<BundleConfig__mdt> bundleConfigs = DAL_DealBundle.getBundleConfigs(productName, deviceName, contractTerm);
		BundleConfig__mdt aConfig = bundleConfigs.get(0);
		Deal_Line__c aLine = new Deal_Line__c(
				Name = productName,
				Product__c = productName,
				Device__c = deviceName,
				ContractTerm__c = contractTerm,
				Quantity__c = quantity,
				MetadataId__c = aConfig.Id,
				StaticResourceName__c = aConfig.StaticResourceName__c,
				Deal__c = dealId
		);

		if (UTIL_System.isValidSalesforceId(bundleId, Deal_Line__c.class))
		{
			Deal_Line__c bundleLine = [SELECT Id, Device__c, Product__c, ContractTerm__c, Quantity__c FROM Deal_Line__c WHERE Id = :bundleId LIMIT 1][0];
			if (bundleLine.Device__c != deviceName || bundleLine.Product__c != productName || bundleLine.ContractTerm__c != contractTerm)
			{
				delete [SELECT Id FROM Deal_Line__c WHERE ParentLine__c = :bundleId];
				updateDeviceLines(dealId, bundleId, deviceName, quantity, productName);
				System.debug('setup change');
			}
			else if (quantity > bundleLine.Quantity__c)
			{
				System.debug('quantity bigger');

				updateDeviceLines(dealId, bundleId, deviceName, quantity - Integer.valueOf(bundleLine.Quantity__c), productName);
			}
			else if (quantity < bundleLine.Quantity__c)
			{
				System.debug('quantity less');

				Integer linesToDelete = Integer.valueOf(bundleLine.Quantity__c) - quantity;
				delete [SELECT Id, CreatedDate FROM Deal_Line__c WHERE ParentLine__c = :bundleId ORDER BY CreatedDate ASC LIMIT :linesToDelete];
			}


			aLine.Id = bundleId;
			update aLine;
			Set<String> additionalFields = new Set<String>();
			if (String.isNotEmpty(aConfig.AdditionalFields__c))
			{
				additionalFields.addAll(aConfig.AdditionalFields__c.split(','));
			}
			resetAdditionalFields(bundleId, additionalFields);
		}
		else
		{
			insert aLine;
			bundleId = aLine.Id;
			updateDeviceLines(dealId, bundleId, deviceName, quantity, productName);
		}
		//Delete Device Lines

		//Update deal
		Deal__c deal = new Deal__c();
		deal.Id = dealId;
		deal.ThirdParty__c = bundleConfigs.get(0).Third_Party__c;
		deal.Sale_Type__c = bundleConfigs.get(0).Sale_Type__c;
		update deal;
		return aLine;
	}
	public static void resetFields(String bundleId, Set<String> fieldsToReset)
	{
		Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Deal_Line__c.fields.getMap();

		Deal_Line__c aLine = new Deal_Line__c();
		aLine.Id = bundleId;
		for (String aField : fieldsToReset)
		{
			Schema.SObjectField field = fieldMap.get(aField);
			Schema.DisplayType fieldType = field.getDescribe().getType();
			if (fieldType == Schema.DisplayType.BOOLEAN)
			{
				aLine.put(aField, false);
			}
			else
			{
				aLine.put(aField, null);
			}
		}
		update aLine;
	}
	public static void resetAdditionalFields(String bundleId, Set<String> fieldsSet)
	{
		//select all metadata where additional fields is present and it is
		List<BundleConfig__mdt> bundleConfigs = [SELECT Id, AdditionalFields__c FROM BundleConfig__mdt];
		Set<String> fieldsToReset = new Set<String>();
		for (BundleConfig__mdt aConfig : bundleConfigs)
		{
			if (String.isEmpty(aConfig.AdditionalFields__c))
			{
				continue;
			}
			for (String aField : aConfig.AdditionalFields__c.split(','))
			{
				if (!fieldsSet.contains(aField))
				{
					fieldsToReset.add(aField);
				}
			}
		}
		if (fieldsToReset.isEmpty())
		{
			return;
		}
		resetFields(bundleId, fieldsToReset);
	}
	public static void resetConfigurationFields(String bundleId, Set<String> fieldsSet)
	{
		List<BundleOption__mdt> bundleConfigs = [SELECT Id, ConfigurationFields__c FROM BundleOption__mdt];
		Set<String> fieldsToReset = new Set<String>();
		for (BundleOption__mdt aConfig : bundleConfigs)
		{
			if (String.isEmpty(aConfig.ConfigurationFields__c))
			{
				continue;
			}
			for (String aField : aConfig.ConfigurationFields__c.split(','))
			{
				if (!fieldsSet.contains(aField))
				{
					fieldsToReset.add(aField);
				}
			}
		}
		if (fieldsToReset.isEmpty())
		{
			return;
		}
		resetFields(bundleId, fieldsToReset);
	}
	public static void updateDeviceLines(String dealId, String bundleId, String deviceName, Integer quantity, String productName)
	{
		List<Product2> products = [SELECT Id FROM Product2 WHERE ProductCode = :deviceName];
		String relatedProductId = null;
		if (products.size() > 0)
		{
			relatedProductId = products.get(0).Id;
		}
		List<Deal_Line__c> deviceLines = new List<Deal_Line__c>();
		for (Integer i = 0; i < quantity; i++)
		{
			deviceLines.add(new Deal_Line__c(
					Name = productName + ' ' + deviceName,
					RelatedProduct__c = relatedProductId,
					Device__c = deviceName,
					ParentLine__c = bundleId,
					Quantity__c = 1,
					Deal__c = dealId
			));
		}
		insert deviceLines;
	}

	@AuraEnabled
	public static List<DeviceLineInformation> queryDeviceLines(Id bundleId, Id metadataId)
	{
		List<ServiceConfig> serviceConfigs = getDeviceServiceConfig(metadataId);
		List<Deal_Line__c>deviceLines = DAL_DealLine.getBundleDeviceLines(bundleId);

		List<DeviceLineInformation> deviceLineInformations = new List<DealProductController.DeviceLineInformation>();
		for (Deal_Line__c aLine : deviceLines)
		{
			DeviceLineInformation aInformation = new DeviceLineInformation();
			aInformation.lineId = aLine.Id;
			aInformation.label = aLine.Device__c;
			aInformation.dealId = aLine.Deal__c;
			aInformation.serviceList = cloneAll(serviceConfigs);
//			aInformation.serviceList.addAll(serviceConfigs);
			System.debug(aLine.Child_Lines__r);
			System.debug(serviceConfigs);
			if (aLine.Child_Lines__r.size() > 0)
			{
				for (ServiceConfig aConfig : aInformation.serviceList)
				{
					for (Deal_Line__c achildLine : aLine.Child_Lines__r)
					{
						System.debug(aConfig);
						System.debug(achildLine);
						if (achildLine.MetadataId__c == aConfig.metadataId)
						{
							aConfig.defaultValue = true;
							aConfig.value = true;
						}
					}
				}
			}
			deviceLineInformations.add(aInformation);
		}
		return deviceLineInformations;
	}

	private static BundleConfiguration formatBundleConfiguration(BundleConfig__mdt bundleConfig, String value, String label)
	{
		BundleConfiguration config = new BundleConfiguration();
		config.metadataId = bundleConfig.Id;
		config.product = bundleConfig.Product__c;
		config.productLabel = bundleConfig.get('productLabel').toString();
		config.device = bundleConfig.Device__c;
		config.deviceLabel = bundleConfig.get('deviceLabel').toString();
		config.contractTerm = bundleConfig.ContractTerm__c;
		config.contractTermLabel = bundleConfig.get('termLabel').toString();
		config.value = value;
		config.label = label;
		config.additionalFields = bundleConfig.AdditionalFields__c;
		return config;
	}

	public class BundleConfiguration
	{
		@AuraEnabled public String product;
		@AuraEnabled public String productLabel;
		@AuraEnabled public String device;
		@AuraEnabled public String deviceLabel;
		@AuraEnabled public String contractTerm;
		@AuraEnabled public String contractTermLabel;
		@AuraEnabled public String metadataId;
		@AuraEnabled public Boolean isStandalone;
		@AuraEnabled public String value;
		@AuraEnabled public String label;
		@AuraEnabled public String additionalFields;
	}
	//class which stores VAS configs
	public class ServiceConfig
	{
		@AuraEnabled public String name;
		@AuraEnabled public String metadataId;
		@AuraEnabled public String apiName;
		@AuraEnabled public String parentApiName;
		@AuraEnabled public Boolean defaultValue;
		@AuraEnabled public Boolean isDisabled;
		@AuraEnabled public Boolean value;

		public ServiceConfig cloneConfig()
		{
			ServiceConfig theClone = new ServiceConfig();
			theClone.name = this.name;
			theClone.metadataId = this.metadataId;
			theClone.apiName = this.apiName;
			theClone.parentApiName = this.parentApiName;
			theClone.defaultValue = this.defaultValue;
			theClone.isDisabled = this.isDisabled;
			theClone.value = this.value;
			return theClone;
		}


	}
	public static List<ServiceConfig> cloneAll(List<ServiceConfig> serviceConfigs)
	{
		List<ServiceConfig> clonedList = new List<DealProductController.ServiceConfig>();
		for (ServiceConfig aConfig : serviceConfigs)
		{
			clonedList.add(aConfig.cloneConfig());
		}
		return clonedList;
	}

	public class DeviceLineInformation
	{
		@AuraEnabled public String dealId;
		@AuraEnabled public String productName;
		@AuraEnabled public String lineId;
		@AuraEnabled public String label;
		@AuraEnabled public String value;
		@AuraEnabled public String key;
		@AuraEnabled public List<ServiceConfig> serviceList;

	}

	@AuraEnabled public static List<ServiceConfig> getAllVAS()
	{
		List<ServiceConfig> serviceList = new List<DealProductController.ServiceConfig>();
		List<BundleOption__mdt> bundleOptions = DAL_DealBundle.getBundleAllVAS();
		for (BundleOption__mdt bundleOption : bundleOptions)
		{
			ServiceConfig aConfig = new ServiceConfig();
			aConfig.name = bundleOption.Label;
			aConfig.metadataId = bundleOption.Id;
			aConfig.apiName = bundleOption.DeveloperName;
			aConfig.parentApiName = bundleOption.ParentService__c;
			serviceList.add(aConfig);
		}
		return serviceList;
	}

	@AuraEnabled
	public static List<ServiceConfig> getDeviceServiceConfig(String metadataId)
	{
		DeviceServiceConfig deviceConfig = new DeviceServiceConfig();
		deviceConfig.metadataId = metadataId;
		List<ServiceConfig> allServices = getAllVAS();
		List<OptionItem__mdt> optionItems = DAL_DealBundle.getBundleOptionItems(metadataId);
		Map<Id, OptionItem__mdt> availableOptionMap = new Map<Id, OptionItem__mdt>();
		for (OptionItem__mdt optionItem : optionItems)
		{
			availableOptionMap.put(optionItem.Bundle_Option__c, optionItem);
		}
		for (ServiceConfig service : allServices)
		{

			if (availableOptionMap.containsKey(service.metadataId))
			{
				service.isDisabled = availableOptionMap.get(service.metadataId).IsDisabled__c;
				service.defaultValue = availableOptionMap.get(service.metadataId).DefaultValue__c;
			}
			else
			{
				service.isDisabled = true;
				service.defaultValue = false;
			}
			service.value = service.defaultValue;
		}
//		deviceConfig.serviceConfigs = allServices;
		return allServices;
	}
	@AuraEnabled
	public static String createVasLines(String deviceInfoString, String bundleId)
	{
		List<DeviceLineInformation> deviceInfos = parseDeviceLineInformations(deviceInfoString);
		String dealId = '';
		List<Deal_Line__c> vasToCreate = new List<Deal_Line__c>();
		Set<String> servicesSelected = new Set<String>();
		delete [SELECT Id FROM Deal_Line__c WHERE ParentLine__r.ParentLine__c = :bundleId];

		for (DeviceLineInformation aInfo : deviceInfos)
		{
			dealId = aInfo.dealId;
			for (ServiceConfig aConfig : aInfo.serviceList)
			{
				if (aConfig.value == true)
				{
					servicesSelected.add(aConfig.metadataId);
					vasToCreate.add(new Deal_Line__c(
							Deal__c = aInfo.dealId,
							ParentLine__c = aInfo.lineId,
							Name = aConfig.name,
							MetadataId__c = aConfig.metadataId,
							LineType__c = 'VAS'
					));
				}
			}
		}
		List<BundleOption__mdt> bundleOptions = DAL_DealBundle.getbundleConfigurationFields(servicesSelected);
		Set<String> fieldsForUpdate = new Set<String>();
		for (BundleOption__mdt aOption : bundleOptions)
		{
			if (String.isNotEmpty(aOption.ConfigurationFields__c))
			{
				fieldsForUpdate.addAll(aOption.ConfigurationFields__c.split(','));
			}
		}
		insert vasToCreate;
		resetConfigurationFields(bundleId, fieldsForUpdate);
		return String.join(new List<String>(fieldsForUpdate), ',');
	}
	public class RebateItem
	{
		@AuraEnabled public String itemLabel;
		@AuraEnabled public String itemName;//productCode
		@AuraEnabled public Integer maxQuantity;
		@AuraEnabled public Integer quantity;
		@AuraEnabled public Integer numberOfMonths;
		@AuraEnabled public Decimal rebateDiscount;
		@AuraEnabled public Decimal rebateAmount;
		@AuraEnabled public Decimal discount;
		@AuraEnabled public Decimal discountAmount;
		@AuraEnabled public String rebateReason;
		@AuraEnabled public String rebateMotivation;
		@AuraEnabled public Boolean disableQuantity;
		@AuraEnabled public Boolean disableNumberOfMonths;
		@AuraEnabled public Boolean disableRebateDiscount;
		@AuraEnabled public Boolean disableRebateAmount;
		@AuraEnabled public Boolean disableDiscount;
		@AuraEnabled public Boolean disableDiscountAmount;
	}
	@AuraEnabled
	public static List<RebateItem> getOptionsForRebate(String bundleId, String metadataId)
	{
		//get Device lines for rebate;
		Deal_Line__c bundleLine = [SELECT Id, Device__c, Quantity__c, Product__c, ProductCode__c, ContractTerm__c FROM Deal_Line__c WHERE Id = :bundleId LIMIT 1];
		List<RebateItem> rebateItems = new List<DealProductController.RebateItem>();


		List<Deal_Line__c> vasLines = [SELECT Id, MetadataId__c FROM Deal_Line__c WHERE ParentLine__r.ParentLine__c = :bundleId];
		Set<String> vasMetadataIds = new Set<String>();
		Set<String> productCodes = new Set<String>();
		String deviceCode = bundleLine.Device__c;

		if (bundleLine.ContractTerm__c!='None')
		{
			deviceCode = DAL_Product.getRentalProductCode(bundleLine.Device__c);
		} else {
			deviceCode=CPQ_APIDealQuote.PRODUCT_SP_630_PURCHASE;
		}
		productCodes.add(deviceCode);
		BundleConfig__mdt bundleConfig = [SELECT Id, RebatableProducts__c FROM BundleConfig__mdt WHERE Id = :metadataId];

		for (Deal_Line__c vasLine : vasLines)
		{
			vasMetadataIds.add(vasLine.MetadataId__c);
		}
		List<BundleOption__mdt> bundleOptions = [SELECT Id, RebatableProducts__c FROM BundleOption__mdt WHERE Id IN:vasMetadataIds];
		if (String.isnotEmpty(bundleConfig.RebatableProducts__c))
		{
			for (String aProduct : bundleConfig.RebatableProducts__c.split(','))
			{
				if (!productCodes.contains(aProduct))
				{
					productCodes.add(aProduct);
				}
			}
		}
		for (BundleOption__mdt aConfig : bundleOptions)
		{
			if (String.isEmpty(aConfig.RebatableProducts__c))
			{
				continue;
			}
			for (String aField : aConfig.RebatableProducts__c.split(','))
			{
				if (!productCodes.contains(aField))
				{
					productCodes.add(aField);
				}
			}
		}
		List<Product2> product2s = [SELECT Id, IsSubscriptionProduct__c, ProductCode, Name FROM Product2 WHERE ProductCode IN :productCodes];
		for (Product2 aProduct : product2s){

			Boolean isDeviceRental = (aProduct.ProductCode == deviceCode) &&(bundleLine.ContractTerm__c !='None');
			Integer quantity = aProduct.ProductCode==deviceCode?Integer.valueOf(bundleLine.Quantity__c):1;
			rebateItems.add(buildRebateItem(aProduct, quantity, isDeviceRental));
		}

		return rebateItems;
	}
	private static RebateItem buildRebateItem(Product2 aProduct, Integer maxQuantity, Boolean isDeviceRental)
	{
		RebateItem newRebateItem = new RebateItem();
		newRebateItem.itemLabel = aProduct.Name;
		newRebateItem.itemName = aProduct.ProductCode;
		newRebateItem.maxQuantity = maxQuantity;
		newRebateItem.discount=null;
		newRebateItem.discountAmount = null;
		newRebateItem.rebateAmount = null;
		newRebateItem.rebateDiscount = null;
		newRebateItem.rebateReason = null;
		newRebateItem.rebateMotivation = null;
		if (aProduct.IsSubscriptionProduct__c)
		{
			newRebateItem.disableQuantity=false;
			newRebateItem.disableNumberOfMonths=false;
			newRebateItem.disableRebateDiscount=false;
			newRebateItem.disableRebateAmount=false;
			newRebateItem.disableDiscount=true;
			newRebateItem.disableDiscountAmount=true;
		}
		else
		{
			newRebateItem.quantity = maxQuantity;
			newRebateItem.disableQuantity=true;
			newRebateItem.disableNumberOfMonths=true;
			newRebateItem.disableRebateDiscount=true;
			newRebateItem.disableRebateAmount=true;
			newRebateItem.disableDiscount=false;
			newRebateItem.disableDiscountAmount=false;
		}
//		if (aProduct.ProductCode =='SS_INSTALL_TRAINING_FEE')
//		{
//			newRebateItem.quantity=1;
//			newRebateItem.maxQuantity=1;
//			newRebateItem.numberOfMonths=null;
//			newRebateItem.discount=100;
//			newRebateItem.discountAmount = 0;
//			newRebateItem.disableQuantity=true;
//			newRebateItem.disableNumberOfMonths=true;
//			newRebateItem.disableRebateDiscount=true;
//			newRebateItem.disableRebateAmount=true;
//			newRebateItem.disableDiscount=true;
//			newRebateItem.disableDiscountAmount=true;
//		}
		return newRebateItem;
	}
	@AuraEnabled
	public static void saveRebates(String rebateJSON, String bundleId){

		List<Deal_Line__c> dealLinesToCreate = new List<Deal_Line__c>();
		Deal_Line__c bundleLine = [SELECT Id, Deal__c FROM Deal_Line__c WHERE Id = :bundleId LIMIT 1];

		delete [SELECT Id FROM Deal_Line__c WHERE ParentLine__c=:bundleId AND RebateItem__c != NULL];

		List<RebateItem> rebateItems = parseRebateItems(rebateJSON);
		for (RebateItem rebateItem: rebateItems){
			Deal_Line__c aNewLine = new Deal_Line__c();
			aNewLine.Deal__c = bundleLine.Deal__c;
			aNewLine.ParentLine__c = bundleId;
			aNewLine.RebateItem__c = rebateItem.itemName;
			aNewLine.Name = 'Rebate / Discount';
			aNewLine.RebateMonths__c = rebateItem.numberOfMonths;
			aNewLine.RebatedQuantity__c = rebateItem.quantity;
			aNewLine.RebateDiscountAmount__c = rebateItem.rebateAmount;
			aNewLine.RebateDiscountPercentage__c = rebateItem.rebateDiscount;
			if (rebateItem.discount>0)
			{
				aNewLine.LineDiscount__c = rebateItem.discount;
			}
			if (rebateItem.discountAmount>0)
			{
				aNewLine.LineDiscountAmount__c = rebateItem.discountAmount;
			}
			aNewLine.RebateReason__c = rebateItem.rebateReason;
			aNewLine.RebateMotivation__c = rebateItem.rebateMotivation;
			dealLinesToCreate.add(aNewLine);
		}
		if (dealLinesToCreate.size()>0)
		{
			insert  dealLinesToCreate;
		}

		Deal_Line__c aLine = new Deal_Line__c();
		aLine.Id = bundleId;
		aLine.RebateJSON__c = rebateJSON;
		update aLine;
	}


	public static List<RebateItem> parseRebateItems(String json)
	{
		return (List<RebateItem>) System.JSON.deserialize(json, List<RebateItem>.class);
	}
	public static List<DeviceLineInformation> parseDeviceLineInformations(String json)
	{
		return (List<DeviceLineInformation>) System.JSON.deserialize(json, List<DeviceLineInformation>.class);
	}

	public class DeviceServiceConfig
	{
		@AuraEnabled public String name;
		@AuraEnabled public String metadataId;
		@AuraEnabled public List<ServiceConfig> serviceConfigs;

	}

}