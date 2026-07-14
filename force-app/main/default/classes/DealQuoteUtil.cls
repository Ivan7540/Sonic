/**
 * Created by JurgitaG on 12/20/2021.
 * PS-1366
 * Handles process of creating Quote and adding products to it
 * Used in Deal Wizard process
 */

public without sharing class DealQuoteUtil
{
	public static List<Deal_Line__c> findByDealId(Id dealId)
	{
		return
		[
				SELECT Id, ParentLine__c,
						Quantity__c,
						Device__c,
						RelatedProduct__c,
						StaticResourceName__c,
						ContractTerm__c,
						LineDiscount__c,
						DeviceType__c,
						PEDQuantity__c,
						PaymentServer__c,
						PaymentServerQuantity__c,
						GiftLoyaltyPaymentType__c,
						Product__c,
						SMEDeviceSupport__c,
						IncludeSIMCards__c,
						BluetoothPrinterQuantity__c,
						IncludeDockingStation__c,
						IncludePaperRolls__c,
						IncludePED__c,
				(SELECT Id FROM Child_Lines__r)
				FROM Deal_Line__c
				WHERE Deal__c = :dealId AND ParentLine__c = NULL AND Rate__c = NULL
		];
	}

	//get deal Bundles
	public static List<DTO_QuoteProduct> getDealBundles(Id dealId)
	{
		List<Deal_Line__c> allDealLines = findByDealId(dealId);
		System.debug(allDealLines);
		List<Deal_Line__c> vasLines = [SELECT
				Id,
				Name,
				ParentLine__c,
				ParentLine__r.ParentLine__c,
				ParentLine__r.ParentLine__r.MoretymeType__c,
				ParentLine__r.ParentLine__r.GiftLoyaltyPaymentType__c,
				ParentLine__r.ParentLine__r.CardDesignType__c
		FROM
				Deal_Line__c
		WHERE
		Deal__c = :dealId
		AND
		LineType__c = 'VAS'];
		Map<Id, DTO_QuoteProduct> aProductMap = new Map<Id, DTO_QuoteProduct>();
		for (Deal_Line__c aLine : allDealLines)
		{
			DTO_QuoteProduct aProduct = new DTO_QuoteProduct();

			aProduct.dealLineId = aLine.Id;
			aProduct.product = aLine.Product__c;
			aProduct.device = aLine.Device__c;
			aProduct.deviceType = aLine.DeviceType__c==null?'': aLine.DeviceType__c;
			aProduct.quantity = Integer.valueOf(aLine.Quantity__c);
			aProduct.contractTerm = aLine.ContractTerm__c;
			aProduct.paymentServer = aLine.PaymentServer__c==null?'': aLine.PaymentServer__c;
			aProduct.paymentServerQuantity = Integer.valueOf(aLine.PaymentServerQuantity__c);
			aProduct.masterpassQuantity = 0;
			aProduct.switchpayQuantity = 0;
			aProduct.moreTymeNetQuantity = 0;
			aProduct.moreTymeGrossQuantity = 0;
			aProduct.amexQuantity = 0;
			aProduct.giftDevicesQuantity = 0;
			aProduct.loyaltyDevicesQuantity = 0;
			aProduct.bespokeQuantity = 0;
			aProduct.catalogueQuantity = 0;
			aProduct.giftQuantity = 0;
			aProduct.acquiringQuantity = 0;
			aProduct.includeDocking = aLine.IncludeDockingStation__c ? Integer.valueOf(aLine.Quantity__c):0;
			aProduct.includePaperRolls = aLine.IncludePaperRolls__c ? Integer.valueOf(aLine.Quantity__c):0;
			aProduct.includePED = aLine.IncludePED__c ? Integer.valueOf(aLine.Quantity__c):0;
			aProduct.simCarsIncluded = aLine.IncludeSIMCards__c;
			aProduct.smeDeviceSupportIncluded = aLine.SMEDeviceSupport__c;
			aProduct.bluetoothPrinterQuantity = Integer.valueOf(aLine.BluetoothPrinterQuantity__c);

			aProduct.giftLoyaltyPaymentType = aLine.GiftLoyaltyPaymentType__c==null?'': aLine.GiftLoyaltyPaymentType__c;

			aProduct.PEDQuantity = Integer.valueOf(aLine.PEDQuantity__c);
			aProduct.staticResourceName = aLine.StaticResourceName__c + aProduct.giftLoyaltyPaymentType + aProduct.paymentServer + aProduct.deviceType;
			if (aProduct.PEDQuantity>0)
			{
				aProduct.staticResourceName+= 'PED';
			}
			if (String.isNotEmpty(aProduct.paymentServer) && aProduct.paymentServerQuantity ==null)
			{
				aProduct.paymentServerQuantity = 1;
			}
			aProduct.lineDiscount = aLine.LineDiscount__c;
			aProductMap.put(aLine.Id, aProduct);
			System.debug(aProduct.quantity);
		}
		for (Deal_Line__c aLine : vasLines)
		{
			if (aProductMap.containsKey(aLine?.ParentLine__r.ParentLine__c))
			{
				DTO_QuoteProduct aProduct = aProductMap.get(aLine.ParentLine__r.ParentLine__c);
				if (aLine.Name == 'Acquiring')
				{
					aProduct.acquiringQuantity++;
				}
				if (aLine.Name == 'Masterpass')
				{
					aProduct.masterpassQuantity++;
				}
				if (aLine.Name == 'Amex')
				{
					aProduct.amexQuantity++;
				}
				if (aLine.Name == 'SwitchPay')
				{
					aProduct.switchpayQuantity++;
				}
				if (aLine.Name == 'Gift')
				{
					aProduct.giftDevicesQuantity++;
					aProduct.giftQuantity =1;
				}
				if (aLine.Name == 'Loyalty')
				{
					aProduct.loyaltyDevicesQuantity++;
					aProduct.giftQuantity =1;
				}
				if ((aLine.Name == 'Gift' || aLine.Name == 'Loyalty') && aLine.ParentLine__r.ParentLine__r.CardDesignType__c == 'Bespoke')
				{
					aProduct.bespokeQuantity = 1;
				}
				if ((aLine.Name == 'Gift' || aLine.Name == 'Loyalty')  && aLine.ParentLine__r.ParentLine__r.CardDesignType__c == 'Catalogue')
				{
					aProduct.catalogueQuantity = 1;
				}
				if (aLine.Name == 'MoreTyme' && aLine.ParentLine__r.ParentLine__r.MoretymeType__c == 'Gross')
				{
					aProduct.moreTymeGrossQuantity++;
				}
				if (aLine.Name == 'MoreTyme' && aLine.ParentLine__r.ParentLine__r.MoretymeType__c == 'Nett')
				{
					aProduct.moreTymeNetQuantity++;
				}
			}


		}
		return aProductMap.values();
	}

	public static Map<Id, List<DealProductController.RebateItem>> getDealRebates(Id dealId){
		List<Deal_Line__c> bundleLines = [SELECT Id, RebateJSON__c, BundleId__c
		FROM Deal_Line__c
		WHERE Deal__c = :dealId AND ParentLine__c = NULL AND Rate__c = NULL];
		Map<Id, List<DealProductController.RebateItem>> bundleRebateMap= new Map<Id, List<DealProductController.RebateItem>>();
		for (Deal_Line__c aLine : bundleLines){
			if (String.isEmpty(aLine.RebateJSON__c))
			{
				continue;
			}
			 bundleRebateMap.put(aLine.BundleId__c, DealProductController.parseRebateItems(aLine.RebateJSON__c));
		}
		return bundleRebateMap;
	}



}