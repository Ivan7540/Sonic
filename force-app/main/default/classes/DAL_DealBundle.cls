/**
 * Created by ViktorijaR on 1/13/2022.
 */

public with sharing class DAL_DealBundle
{
	public static List<BundleConfig__mdt> getBundleProductOptions(Boolean isStandalone)
	{
		return
		[
				SELECT Id,
						Product__c,
						toLabel(Product__c) productName,
						Device__c
				FROM BundleConfig__mdt
				WHERE Is_Active__c = TRUE
		];
	}

	public static List<BundleConfig__mdt> getBundleDeviceOptions(String productName)
	{
		return
		[
				SELECT Id,
						Product__c,
						toLabel(Product__c) productLabel,
						Device__c,
						toLabel(Device__c) deviceLabel,
						ContractTerm__c,
						toLabel(ContractTerm__c) termLabel
				FROM BundleConfig__mdt
				WHERE Product__c = :productName
				AND
				Is_Active__c = TRUE
		];
	}

	public static List<BundleConfig__mdt> getBundleContractTermOptions(String productName, String deviceName)
	{
		return
		[
				SELECT Id,
						Product__c,
						toLabel(Product__c) productLabel,
						Device__c,
						toLabel(Device__c) deviceLabel,
						ContractTerm__c,
						toLabel(ContractTerm__c) termLabel,
						AdditionalFields__c
				FROM BundleConfig__mdt
				WHERE Product__c = :productName
				AND
				Device__c = :deviceName
				AND
				Is_Active__c = TRUE
		];
	}

	public static List<BundleConfig__mdt> getBundleConfigs(String productName, String deviceName, String contractTerm)
	{
		return
		[
				SELECT Id,
						StaticResourceName__c,
						Third_Party__c,
						Sale_Type__c,
						AdditionalFields__c
				FROM BundleConfig__mdt
				WHERE Product__c = :productName
				AND
				Device__c = :deviceName
				AND
				ContractTerm__c = :contractTerm
		];
	}

	public static List<OptionItem__mdt> getBundleOptionalItems(String metadataId)
	{
		return
		[
				SELECT Id,
						Bundle_Option__c,
						Bundle_Option__r.Label,
						Bundle_Option__r.Product_Code__c
				FROM OptionItem__mdt
				WHERE Bundle_Config__c = :metadataId
		];
	}

	public static List<BundleOption__mdt> getBundleAllVAS()
	{
		return
		[
				SELECT Id,
						Label,
						DeveloperName,
						ParentService__c,
						Order__c
				FROM BundleOption__mdt
				WHERE IsActive__c = TRUE
				ORDER BY Order__c ASC
		];
	}

	public static List<OptionItem__mdt> getBundleOptionItems(String metadataId)
	{
		return
		[
				SELECT Id,
						Bundle_Option__c,
						Bundle_Option__r.DeveloperName,
						DefaultValue__c,
						IsDisabled__c
				FROM OptionItem__mdt
				WHERE Bundle_Config__c = :metadataId
				AND
				IsActive__c = TRUE
		];
	}

	public static List<BundleRate__mdt> getBundleRates(Set<Id> metadataIds)
	{
		return
		[
				SELECT Id,
						DefaultCardSplit__c,
						DefaultRatePercentage__c,
						DefaultTransactionFee__c,
						Product_Code__c
				FROM BundleRate__mdt
				WHERE BundleOption__c IN :metadataIds
		];
	}

	public static List<BundleOption__mdt> getbundleConfigurationFields(Set<String> servicesSelected)
	{
		return
		[
				SELECT Id,
						ConfigurationFields__c
				FROM BundleOption__mdt
				WHERE Id IN :servicesSelected
		];
	}

}