/**
 * Created by ViktorijaR on 1/18/2022.
 */

public with sharing class FLOW_DealWizardRate
{
	@InvocableMethod(label='Update Rate Lines' category='Deal' Callout=true)
	public static void updateRateLines(List<DealRequest> requests)
	{
		for (DealRequest drequest : requests)
		{
			Set<String> productCodeList = new Set<String> {'SS_DOMESTIC_DEBIT_CARD_FEES', 'SS_DOMESTIC_CREDIT_CARD_FEES', 'SS_INTERNATIONAL_DEBIT_CARD_FEES', 'SS_INTERNATIONAL_CREDIT_CARD_FEES'};
			Set<Id> metadataIds = new Set<Id>();
			List<Deal_Line__c> vasLines = DAL_DealLine.getVasLines(drequest.dealId);
			for (Deal_Line__c aLine : vasLines)
			{
				metadataIds.add(aLine.MetadataId__c);
			}
			List<BundleRate__mdt> bundleRates = DAL_DealBundle.getBundleRates(metadataIds);
			Map<String, BundleRate__mdt> productCodeMap = new Map<String, BundleRate__mdt>();
			for (BundleRate__mdt bundleRate : bundleRates)
			{
				productCodeMap.put(bundleRate.Product_Code__c, bundleRate);
			}
			List<Product2> products = DAL_Product.getProducts(productCodeMap);
			Map<String, Product2> productMap = new Map<String, Product2>();
			for (Product2 aProduct : products)
			{
				productMap.put(aProduct.ProductCode, aProduct);
			}

			List<Deal_Line__c> linesToDelete = new List<Deal_Line__c>();
			List<Deal_Line__c> linesToInsert = new List<Deal_Line__c>();
			List<Deal_Line__c> existingDealLines = DAL_DealLine.getExistingDealLines(drequest.dealId);

			Map<String, Deal_Line__c> dealLineProductCodeMap = new Map<String, Deal_Line__c>();
			for (Deal_Line__c aLine : existingDealLines)
			{
				dealLineProductCodeMap.put(aLine.ProductCode__c, aLine);
			}

			for (Deal_Line__c aLine : existingDealLines)
			{
				if (!(productCodeMap.containsKey(aLine.ProductCode__c)))
				{
					linesToDelete.add(aLine);
				}
			}
			for (String productCode : productCodeMap.keySet())
			{
				if (dealLineProductCodeMap.containsKey(productCode))
				{
					continue;
				}
				BundleRate__mdt bundleRate = productCodeMap.get(productCode);
				Deal_Line__c newRateLine = new Deal_Line__c();
				newRateLine.Rate__c = productMap.get(productCode).Id;
				newRateLine.Name = productMap.get(productCode).Name;
				newRateLine.Rate_Percentage__c = bundleRate.DefaultRatePercentage__c;
				newRateLine.CardSplit__c = bundleRate.DefaultCardSplit__c;
				newRateLine.TransactionFee__c = bundleRate.DefaultTransactionFee__c;
				newRateLine.Deal__c = drequest.dealId;
				if (bundleRate.Product_Code__c == 'SS_DOMESTIC_DEBIT_CARD_FEES' && drequest.debit != null)
				{
					newRateLine.Rate_Percentage__c = drequest.debit;
				}

				if (bundleRate.Product_Code__c == 'SS_DOMESTIC_CREDIT_CARD_FEES' && drequest.credit != null)
				{
					newRateLine.Rate_Percentage__c = drequest.credit;
				}

				linesToInsert.add(newRateLine);
			}
			if (linesToDelete.size() > 0)
			{
				delete linesToDelete;
			}
			if (linesToInsert.size() > 0)
			{
				insert linesToInsert;
			}
		}
	}

	public class DealRequest
	{
		@InvocableVariable(label='Deal Id' description='' required=true)
		public Id dealId;

		@InvocableVariable(label='Debit' description='')
		public Decimal debit;

		@InvocableVariable(label='Credit' description='')
		public Decimal credit;
	}

}