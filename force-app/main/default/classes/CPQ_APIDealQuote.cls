/**
 * Created by JurgitaG on 3/25/2021.
 */
@RestResource(urlMapping='/SonicCPQ/CreateQuote')
global class CPQ_APIDealQuote
{
	public static final String SUCCESS = 'success';
	public static final String MESSAGE = 'message';
	public static final String PAYLOAD = 'payload';

	public static final String RATE_STATIC_RESOURCE = 'QM_RateBundle';
	public static final String RATE_WITH_MASTERPASS_STATIC_RESOURCE = 'QM_RateBundleWithMasterpass';
	public static final String RATE_WITH_MASTERPASS_WITHOUT_AQ_STATIC_RESOURCE = 'QM_RateBundleWithMasterpassWithoutAcquiring';
	public static final String RATE_WITH_SWITCHPAY_STATIC_RESOURCE = 'QM_RateBundleWithSwitchpay';
	public static final String RATE_WITH_SWITCHPAY_WITHOUT_AQ_STATIC_RESOURCE = 'QM_RateBundleWithSwitchPayWithoutAcquiring';
	public static final String RATE_WITH_MORETYME_STATIC_RESOURCE = 'QM_RateBundleWithMoreTyme';
	public static final String RATE_WITH_MORETYME_WITHOUT_AQ_STATIC_RESOURCE = 'QM_RateBundleWithMoreTymeWithoutAcquiring';
	public static final String RATE_WITH_MORETYME_AND_SWITCHPAY_STATIC_RESOURCE = 'QM_RateBundleWithMoreTymeSwitchPay';
	public static final String RATE_WITH_MORETYME_AND_SWITCHPAY_WITHOUT_AQ_STATIC_RESOURCE = 'QM_RateBundleWithMoreTymeSwitchPayWithoutAcquiring';
	public static final String WELCOME_BOX_STATIC_RESOURCE = 'QM_WelcomeBox';
	public static final String WELCOME_BOX_W_BILLFOLDER_STATIC_RESOURCE = 'QM_WelcomeBoxWithBillFolder';

	public static final String SUBTYPE_ACQUIRING = 'Acquiring Only';
	public static final String SALETYPE_AMENDMENT = 'Amendment';

	public static final String PRODUCT_SURESWIPE_ACQUIRING = 'SureswipeAcquiring';
	public static final String PRODUCT_SP_630 = 'SS_SP_630';
	public static final String PRODUCT_SP_630_PURCHASE = 'SS_SP_630_OUTRIGHT_PURCHASE';
	public static final Set<String> HUMBLE_PRODUCTCODES = new Set<String> {'SS_HUMBLE_BT50', 'SS_HUMBLE_HI5'};
	public static final String PRODUCT_MORETYME = 'SS_TYME_BANK_RATE_BUNDLE';
	public static final String PRODUCT_SME_CLOUD = 'AD_';

	public static final String FEE_PRODUCT_CODE_END = '_PER_TRANSACTION_FEES';

	public static final String HUMBLE_TEMPLATE = 'Sureswipe Humble Addendum';
	public static final String QUOTE_TEMPLATE_SURESWIPE_ACQUIRING = 'Sureswipe Acquiring Addendum';
	public static final String MAIN_CONTRACT = 'Sureswipe Main Contract';
	public static final String MAIN_CONTRACT_ALL = 'Sureswipe Main Contract(All)';
	public static final String PURCHASE_CONTRACT = 'Sureswipe Outright Purchase Contract';
	public static final String PURCHASE_ADDENDUM = 'Sureswipe Outright Purchase Addendum';
	public static final String ASP_AGREEMENT = 'Sureswipe Main Contract inclu. ASP Agreement';
	public static final String SWITCHPAY_TAKEON_FORM = 'SwitchPay Take On Form';
	public static final String MORETYME_AGREEMENT = 'Sureswipe MoreTyme Agreement';
	public static final String SME_CLOUD_AGREEMENT = 'Adumo SME Contract';

	@HttpGet
	global static DTO_QuoteSummary getSummary()
	{
		RestRequest req = RestContext.request;
		String quoteId = req.params.get('id');
		DTO_QuoteSummary responseBody = LCC_QuoteSummary.getQuoteLines(quoteId);
		return responseBody;
	}

	@HttpPost
	global static DTO_Quote_Response createQuote()
	{
		Boolean hasSwitchPay = false;
		Boolean hasMasterpass = false;
		Boolean hasAcquiring = false;
		Boolean hasAmex= false;
		Boolean isSureswipeAcquiring = false;
		Boolean hasMoreTyme = false;
		Boolean hasGiftLoyalty = false;

		String body = RestContext.request.requestBody.toString();
		DTO_Quote aQuoteRequest = (DTO_Quote) System.JSON.deserialize(body, DTO_Quote.class);
		if (aQuoteRequest.saleType != SALETYPE_AMENDMENT && !Test.isRunningTest())
		{
			aQuoteRequest.products = DealQuoteUtil.getDealBundles(aQuoteRequest.dealId);
		}

		for (DTO_QuoteProduct aProduct : aQuoteRequest.products)
		{
			if (aProduct.product == PRODUCT_SURESWIPE_ACQUIRING)
			{
				isSureswipeAcquiring = true;
			}

			if (aProduct.masterpassQuantity > 0)
			{
				hasMasterpass = true;
			}

			if (aProduct.switchpayQuantity > 0)
			{
				hasSwitchPay = true;
			}
			if (aProduct.acquiringQuantity > 0)
			{
				hasAcquiring = true;
			}
			if (aProduct.giftQuantity > 0)
			{
				hasGiftLoyalty = true;
			}
			if (aProduct.amexQuantity > 0)
			{
				hasAmex = true;
			}

			if (aProduct.moreTymeGrossQuantity > 0 || aProduct.moreTymeNetQuantity > 0)
			{
				hasMoreTyme = true;
			}
		}

		String subtype = isSureswipeAcquiring ? SUBTYPE_ACQUIRING : null;
		Deal__c aDeal = getDealById(aQuoteRequest.dealId);
		if (aQuoteRequest.saleType != SALETYPE_AMENDMENT){
			aQuoteRequest.saleType = aDeal?.Sale_Type__c;
			aQuoteRequest.thirdParty = aDeal?.ThirdParty__c;
		}

		Opportunity aOpp = new Opportunity(Id = aQuoteRequest.Opportunity2,
				Type = aQuoteRequest.dealType,
				SaleType__c = aQuoteRequest.saleType,
				ThirdParty__c = aQuoteRequest.thirdParty,
				Sub_Type__c = subtype,
				Channel__c = aDeal?.Channel__c
		);
		update aOpp;

		Map<Id, SObject> contractedPriceMap = CPQ_CreateQuoteModel.getContractedPrices(aQuoteRequest.accountId, aQuoteRequest.masterContractId);

		SBQQ__Quote__c aQuote = new SBQQ__Quote__c();
		aQuote.SBQQ__Opportunity2__c = aQuoteRequest.Opportunity2;
		aQuote.SBQQ__Account__c = aQuoteRequest.accountId;
		aQuote.SBQQ__OrderBy__c = aQuoteRequest.OrderBy;
		aQuote.SBQQ__PriceBook__c = aQuoteRequest.PricebookId;
		aQuote.SBQQ__PricebookId__c = aQuoteRequest.PricebookId;
		aQuote.SBQQ__StartDate__c = aQuoteRequest.StartDate;
		aQuote.SBQQ__Status__c = aQuoteRequest.Status;
		aQuote.SBQQ__OrderByQuoteLineGroup__c = aQuoteRequest.OrderByQuoteLineGroup;
		aQuote.SBQQ__Primary__c = aQuoteRequest.Primary;
		aQuote.Sub_Type__c = subtype;
		aQuote.SBQQ__LineItemsGrouped__c = aQuoteRequest.LineItemsGrouped;
		aQuote.SBQQ__MasterContract__c = aQuoteRequest.masterContractId;
		aQuote.SaleType__c = aQuoteRequest.saleType;
		aQuote.ThirdParty__c = aQuoteRequest.thirdParty;
		aQuote.SBQQ__QuoteTemplateId__c = getTemplateId(aQuoteRequest);
		aQuote.Related_Case__c = aQuoteRequest.relatedCase;
		aQuote.HasGiftLoyalty__c = hasGiftLoyalty;
		aQuote.HasMasterpass__c = hasMasterpass;
		aQuote.HasMoreTyme__c = hasMoreTyme;
		aQuote.HasSwitchPay__c = hasSwitchPay;

		if (!contractedPriceMap.isEmpty())
		{
			aQuote.SBQQ__GenerateContractedPrice__c = 'Price';
		}

		if (aDeal != null)
		{
			aQuote.AcquiringBank__c = aDeal.AcquiringBank__c;
		}

		insert aQuote;

		List<Asset> welcomeAssets = getWelcomeAssets(aQuoteRequest.accountId);

		if (welcomeAssets.isEmpty() && aQuoteRequest.saleType != DAL_Deal.SALES_TYPE_OUTRIGHT && aQuoteRequest.saleType != SALETYPE_AMENDMENT && !isSureswipeAcquiring) //SWW:2021-06-25:: changes for amendment
		{
			CPQ_CreateQuoteModel.createCPQQuoteModel(aQuote.Id, WELCOME_BOX_STATIC_RESOURCE, new Map<String, Integer>());
		}

		List<Deal_Line__c> dealLines = new List<Deal_Line__c>();

		for (DTO_QuoteProduct aProduct : aQuoteRequest.products)
		{
			if (aProduct.product == PRODUCT_SURESWIPE_ACQUIRING)
			{
				continue;
			}
			Map<String, Integer> productQuantities = mapProductQuantities(aProduct, aQuoteRequest.saleType);
			aProduct.productId = CPQ_CreateQuoteModel.createCPQQuoteModel(aQuote.Id, aProduct.staticResourceName, productQuantities);

			if (!String.isBlank(aProduct.dealLineId))
			{
				//SWW:2021-06-25:: changes for amendment
				dealLines.add(new Deal_Line__c(Id = aProduct.dealLineId, BundleId__c = aProduct.productId));
			}
		}

		update dealLines;

		//SWW:2021-06-25:: changes for amendment
		if (aQuoteRequest.saleType != SALETYPE_AMENDMENT)
		{
			String rateStaticResource = selectRateResource(hasMasterpass, hasSwitchPay, hasMoreTyme, hasAcquiring);
			Map<String, Integer> deviceQty = new Map<String, Integer>();
			deviceQty.put(DAL_Product.amexCardFee, hasAmex?1:0);
			CPQ_CreateQuoteModel.createCPQQuoteModel(aQuote.Id, rateStaticResource, deviceQty);
		}

		DTO_Quote aQuoteResponse = new DTO_Quote();
		aQuoteResponse.quoteId = aQuote.Id;
		aQuoteResponse.products = aQuoteRequest.products;

		DTO_Quote_Response aResponse = new DTO_Quote_Response();
		aResponse.id = aQuote.Id;
		aResponse.success = true;
		aResponse.quoteInfo = aQuoteResponse;

		return aResponse;
	}

	@HttpPatch
	global static DTO_Quote_Response addRates()
	{
		String body = RestContext.request.requestBody.toString();
		DTO_Quote aQuoteRequest = (DTO_Quote) System.JSON.deserialize(body, DTO_Quote.class);
		Map<String, Decimal> productRateMap = new Map<String, Decimal>();
		List<SBQQ__QuoteLine__c> consumptionRates = getConsumptionRates(aQuoteRequest.quoteId);
		System.debug(aQuoteRequest.products);
		for (DTO_QuoteProduct aRate : aQuoteRequest.products)
		{
			System.debug(aRate);
			if (aRate.productCode.endsWith(FEE_PRODUCT_CODE_END))
			{
				productRateMap.put(aRate.productId, aRate.transactionFee);

			}
			else
			{
				productRateMap.put(aRate.productId, aRate.ratePercentage);
			}
		}

		for (SBQQ__QuoteLine__c consumptionRate : consumptionRates)
		{
			System.debug(consumptionRate.SBQQ__ProductCode__c);
			System.debug(consumptionRate.CustomUBPrice__c);
			if (productRateMap.containsKey(consumptionRate.SBQQ__Product__c))
			{
				System.debug(productRateMap.get(consumptionRate.SBQQ__Product__c));
				consumptionRate.CustomUBPrice__c = productRateMap.get(consumptionRate.SBQQ__Product__c);
			}
		}
//		Map<Id, List<DealProductController.RebateItem>> bundleRebateMap = DealQuoteUtil.getDealRebates(aQuoteRequest.dealId);
//		CPQ_APIDealRebate.updateQuoteWithRebates(aQuoteRequest.quoteId, bundleRebateMap);
		update consumptionRates;
		Map<Id, List<DealProductController.RebateItem>> bundleRebateMap = DealQuoteUtil.getDealRebates(aQuoteRequest.dealId);
		CPQ_APIDealRebate.updateQuoteWithRebates(aQuoteRequest.quoteId, bundleRebateMap);
		DTO_Quote_Response aResponse = new DTO_Quote_Response();
		aResponse.id = aQuoteRequest.quoteId;
		aResponse.success = true;
		aQuoteRequest.dateSubmitted = System.now();
		CPQ_APIWrapper.calculateQuote(aQuoteRequest.quoteId);
		aResponse.quoteInfo = aQuoteRequest;
		return aResponse;
	}

	private static Id getTemplateId(DTO_Quote aQuoteRequest)
	{
		String templateName = MAIN_CONTRACT_ALL;

		if (aQuoteRequest.saleType == DAL_Deal.SALES_TYPE_OUTRIGHT)
		{
			templateName = PURCHASE_CONTRACT;
		}

		for (DTO_QuoteProduct aProduct : aQuoteRequest.products)
		{
//			if (aProduct.masterpassQuantity > 0)
//			{
//				templateName = ASP_AGREEMENT;
//			}

			if (aProduct.product == PRODUCT_SURESWIPE_ACQUIRING)
			{
				templateName = QUOTE_TEMPLATE_SURESWIPE_ACQUIRING;
			}

			if (aProduct.device == PRODUCT_SP_630 && aQuoteRequest.saleType == DAL_Deal.SALES_TYPE_OUTRIGHT)
			{
				templateName = PURCHASE_ADDENDUM;
			}

			if (HUMBLE_PRODUCTCODES.contains(aProduct.device))
			{
				templateName = HUMBLE_TEMPLATE;
			}

//			if (aProduct.moreTymeNetQuantity > 0 || aProduct.moreTymeGrossQuantity > 0)
//			{
//				templateName = MORETYME_AGREEMENT;
//			}

			if (aProduct.paymentServer != null && aProduct.paymentServer.contains(PRODUCT_SME_CLOUD))
			{
				templateName = SME_CLOUD_AGREEMENT;
			}
		}

		return getTemplateByName(templateName)?.Id;
	}

	private static Map<String, Integer> mapProductQuantities(DTO_QuoteProduct aProduct, String saleType)
	{
		//Add product code mapping here, this decides which lines are duplicated
		String deviceProductCode = selectDeviceCode(aProduct, saleType);

		Map<String, Integer> productQuantities = new Map<String, Integer>();
		if (aProduct.device == null)
		{
			return productQuantities;
		}
		productQuantities.put(deviceProductCode, aProduct.quantity);
		productQuantities.put(DAL_Product.bluetoothPrinterRentalPC, aProduct.bluetoothPrinterQuantity);
		if (aProduct.paymentServer =='AD_SME_CLOUD__RENTAL')
		{
			productQuantities.put('AD_A920PRO_BASE', aProduct.includeDocking);
			productQuantities.put(DAL_Product.paperRollProductCode, aProduct.includePaperRolls);
			productQuantities.put(DAL_Product.PEDStandPC, aProduct.includePED);
		}

		productQuantities.put(DAL_Product.masterpassRentalPC, aProduct.masterpassQuantity);
		productQuantities.put(DAL_Product.switchpayRentalPC, aProduct.switchpayQuantity);
		productQuantities.put(DAL_Product.MORETYME_GROSS, aProduct.moreTymeGrossQuantity);
		productQuantities.put(DAL_Product.MORETYME_NET, aProduct.moreTymeNetQuantity);
		productQuantities.put('SS_LOYALTY_AND_GIFT_BUNDLE', aProduct.giftQuantity);
		productQuantities.put('SS_LOYALTY_AND_GIFT_3_BUNDLE', aProduct.giftQuantity);
		productQuantities.put('SS_CARD_ARTWORK_DESIGN_BESPOKE', aProduct.bespokeQuantity);
		productQuantities.put('SS_CARD_ARTWORK_DESIGN_STANDARD', aProduct.bespokeQuantity);
		productQuantities.put('SS_CARD_ARTWORK_DESIGN_CATALOGUE', aProduct.catalogueQuantity);
		productQuantities.put('SS_CARD_ARTWORK_DESIGN_MERCHANT', aProduct.catalogueQuantity);
		productQuantities.put('SS_GIFT', aProduct.giftDevicesQuantity);
		productQuantities.put('SS_LOYALTY', aProduct.loyaltyDevicesQuantity);
		productQuantities.put('SS_AMEX', aProduct.amexQuantity);
		Integer moretymeTotal = 0;
		if (aProduct.moreTymeGrossQuantity != null)
		{
			moretymeTotal += aProduct.moreTymeGrossQuantity;
		}
		if (aProduct.moreTymeNetQuantity != null)
		{
			moretymeTotal += aProduct.moreTymeNetQuantity;
		}
		productQuantities.put('SS_MORETYME', moretymeTotal);

		System.debug(productQuantities.values());
		if (!String.isEmpty(aProduct.paymentServer))
		{
			productQuantities.put(aProduct.paymentServer, aProduct.paymentServerQuantity);
		}
		if (aProduct.PEDQuantity>0)
		{
			productQuantities.put(DAL_Product.PEDStandPC, aProduct.PEDQuantity);
		}

		return productQuantities;
	}

	private static String selectDeviceCode(DTO_QuoteProduct aProduct, String saleType)
	{
		String deviceProductCode = aProduct.device;

		if (aProduct.contractTerm != DAL_DealLine.OUTRIGHT_PURCHASE_CONTRACT_TERM && saleType != SALETYPE_AMENDMENT)
		{
			deviceProductCode = DAL_Product.getRentalProductCode(deviceProductCode);
		}
		else if (deviceProductCode == PRODUCT_SP_630)
		{
			deviceProductCode = PRODUCT_SP_630_PURCHASE;
		}
		return deviceProductCode;
	}

	private static String selectRateResource(Boolean hasMasterpass, Boolean hasSwitchPay, Boolean hasMoreTyme, Boolean hasAcquiring)
	{
		if (hasMoreTyme && hasSwitchPay && hasAcquiring)
		{
			return RATE_WITH_MORETYME_AND_SWITCHPAY_STATIC_RESOURCE;
		}
		if (hasMoreTyme && hasSwitchPay && !hasAcquiring)
		{
			return RATE_WITH_MORETYME_WITHOUT_AQ_STATIC_RESOURCE;
		}
		if (hasMoreTyme && hasAcquiring)
		{
			return RATE_WITH_MORETYME_STATIC_RESOURCE;
		}
		if (hasMoreTyme && !hasAcquiring)
		{
			return RATE_WITH_MORETYME_AND_SWITCHPAY_WITHOUT_AQ_STATIC_RESOURCE;
		}

		if (hasMasterpass && hasAcquiring)
		{
			if (hasSwitchPay)
			{
				return RATE_WITH_SWITCHPAY_STATIC_RESOURCE;// gives both masterpass and switchpay
			}
			else
			{
				return RATE_WITH_MASTERPASS_STATIC_RESOURCE;
			}
		}
		if (hasMasterpass && !hasAcquiring)
		{
			if (hasSwitchPay)
			{
				return RATE_WITH_SWITCHPAY_WITHOUT_AQ_STATIC_RESOURCE;// gives both masterpass and switchpay
			}
			else
			{
				return RATE_WITH_MASTERPASS_WITHOUT_AQ_STATIC_RESOURCE;
			}
		}
		else
		{
			return RATE_STATIC_RESOURCE;
		}
	}

	private static Deal__c getDealById(Id dealId)
	{
		List<Deal__c> deals =
		[
				SELECT Id,
						AcquiringBank__c,
						Channel__c,
						Sale_Type__c,
						ThirdParty__c
				FROM Deal__c
				WHERE Id = :dealId
				LIMIT 1
		];
		if (deals.isEmpty())
		{
			return null;
		}
		return deals.get(0);
	}

	private static SBQQ__QuoteTemplate__c getTemplateByName(String tempName)
	{
		return
		[
				SELECT Id
				FROM SBQQ__QuoteTemplate__c
				WHERE Name = :tempName
		];
	}

	private static List<Asset> getWelcomeAssets(Id accountId)
	{
		if (accountId == null)
		{
			return new List<Asset>();
		}
		return
		[
				SELECT Id
				FROM Asset
				WHERE ProductCode = 'SS_WELCOME_BOX'
				AND AccountId = :accountId
		];
	}

	private static List<SBQQ__QuoteLine__c> getConsumptionRates(String quoteId)
	{
		return
		[
				SELECT Id, CustomUBPrice__c, SBQQ__Product__c, SBQQ__ProductCode__c
				FROM SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__c = :quoteId
				AND SBQQ__Product__r.ProductCode != 'SS_UNAUTHORISED_MOTO_FEE'
				AND SBQQ__Product__r.ProductCode != 'SS_FALLBACK_FEE'
				AND SBQQ__Product__r.Family = 'Swipe Rates'
		];
	}
}