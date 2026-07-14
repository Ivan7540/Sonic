/**
 * Created by JurgitaG on 4/12/2021.
 */
@RestResource(urlMapping='/SonicCPQ/DealRebate')
global with sharing class CPQ_APIDealRebate
{

	public static final String PRODUCT_CODE_OUTRIGHT = 'SS_SP_630_OUTRIGHT_PURCHASE';
	public static final String REBATE_NOTE_TEMPLATE = Label.Rebate_Text_Template;
	@HttpPatch
	global static DTO_Quote_Response addRebate()
	{
		String body = RestContext.request.requestBody.toString();
		DTO_Quote aQuoteRequest = (DTO_Quote) System.JSON.deserialize(body, DTO_Quote.class);
		String quoteId = aQuoteRequest.quoteId;
		System.debug(aQuoteRequest);
		Map<Id, List<DealProductController.RebateItem>> bundleRebateMap = DealQuoteUtil.getDealRebates(aQuoteRequest.dealId);
		updateQuoteWithRebates(quoteId, bundleRebateMap);
//		aQuoteRequest.dateSubmitted = System.now();
//		CPQ_APIWrapper.calculateQuote(quoteId);

		DTO_Quote_Response aResponse = new DTO_Quote_Response();
		aResponse.id = quoteId;
		aResponse.success = true;
		aResponse.quoteInfo = aQuoteRequest;
		return aResponse;
	}

	public static void updateQuoteWithRebates(Id quoteId, Map<Id, List<DealProductController.RebateItem>> rebateItemMap)
	{
		Set<String> productCodes = new Set<String>();
		for (Id bundleId : rebateItemMap.keySet())
		{
			for (DealProductController.RebateItem rebateItem : rebateItemMap.get(bundleId))
			{
				productCodes.add(rebateItem.itemName);
			}
		}

		List<SBQQ__QuoteLine__c> linesToRebate =
		[
				SELECT
						Id,
						SBQQ__Product__c,
						SBQQ__RequiredBy__c,
						SBQQ__Product__r.ProductCode,
						SBQQ__Product__r.IsSubscriptionProduct__c,
						SBQQ__ProductName__c,
						SBQQ__Discount__c,
						SBQQ__ProductCode__c,
						SBQQ__Group__c
				FROM
						SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__c = :quoteId AND
				(SBQQ__ProductCode__c IN :productCodes OR SBQQ__RequiredBy__c = NULL )
		];
		Map<Id, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
		Map<Id, Id> groupBundleMap = new Map<Id, Id>();
		for (SBQQ__QuoteLine__c aQuoteLine : linesToRebate)
		{
			if (aQuoteLine.SBQQ__RequiredBy__c == null)
			{
				groupBundleMap.put(aQuoteLine.Id, aQuoteLine.SBQQ__Group__c);
				continue;
			}
			List<SBQQ__QuoteLine__c> childLines = quoteLineMap.get(aQuoteLine.SBQQ__Group__c);
			if (childLines == null)
			{
				childLines = new List<SBQQ__QuoteLine__c>();
				quoteLineMap.put(aQuoteLine.SBQQ__Group__c, childLines);
			}
			childLines.add(aQuoteLine);
		}
		System.debug(groupBundleMap);
		List<SBQQ__QuoteLine__c> linesForUpdate = new List<SBQQ__QuoteLine__c>();
		String rebateNotes = '';
		String installationCharges = '';
		for (Id bundleId : rebateItemMap.keySet())
		{
			System.debug(bundleId);
			Id groupId = groupBundleMap.get(bundleId);
			System.debug(groupId);
			if (!rebateItemMap.containsKey(bundleId))
			{
				continue;
			}
			List<DealProductController.RebateItem> rebateItems = rebateItemMap.get(bundleId);
			for (DealProductController.RebateItem rebateItem : rebateItems)
			{
				Integer quantityRebated = 0;
				if (!quoteLineMap.containsKey(groupId))
				{
					continue;
				}
				System.debug(rebateItem);
				System.debug(rebateItem.itemName);
				for (SBQQ__QuoteLine__c quoteLine : quoteLineMap.get(groupId))
				{
					System.debug(quoteLine);

					if (quantityRebated == rebateItem.quantity)
					{
						continue;
					}
					if (quoteLine.SBQQ__ProductCode__c == rebateItem.itemName)
					{
						SBQQ__QuoteLine__c aQuoteLine = new SBQQ__QuoteLine__c(Id = quoteLine.Id);
						if (quoteLine.SBQQ__Product__r.IsSubscriptionProduct__c)
						{
							aQuoteLine.RebatePercent__c = rebateItem.rebateDiscount;
							aQuoteLine.RebateAmount__c = rebateItem.rebateAmount;
							aQuoteLine.RebateQuantity__c = (rebateItem.quantity  == null ? 0 :1);
							aQuoteLine.RebateMonths__c = rebateItem.numberOfMonths;
						}
						else
						{
							if (rebateItem.discountAmount > 0)
							{
								aQuoteLine.SBQQ__AdditionalDiscountAmount__c = rebateItem.discountAmount;

							}
							if (rebateItem.discount > 0)
							{
								aQuoteLine.SBQQ__Discount__c = rebateItem.discount;

							}
						}
//                        if (rebateItem.rebateDiscount != null || rebateItem.rebateAmount != null || rebateItem.quantity != null || rebateItem.numberOfMonths != null) {
//                            String rebateLine = formatRebateLine(rebateItem.quantity, rebateItem.numberOfMonths, rebateItem.rebateDiscount, rebateItem.rebateAmount, aQuoteLine.SBQQ__ProductName__c);
//                            if (rebateNotes == '') {
//                                rebateNotes += rebateLine;
//                            } else {
//                                rebateNotes += '\n';
//                                rebateNotes += rebateLine;
//                            }
//
//                        }
						linesForUpdate.add(aQuoteLine);
                        quantityRebated++;

                    }

				}

			}
		}
		update linesForUpdate;
		SBQQ__Quote__c aQuote = new SBQQ__Quote__c(Id = quoteId);
		aQuote.SBQQ__Notes__c = rebateNotes;
		update aQuote;
	}

	public static String formatRebateLine(Integer quantity, Integer months, Decimal discount, Decimal amount, String productName)
	{
		String rebateLine = REBATE_NOTE_TEMPLATE;
		rebateLine = rebateLine.replace('{RebatedQuantity}', quantity == null ? '' : String.valueOf(quantity));
		rebateLine = rebateLine.replace('{Device}', productName);
		rebateLine = rebateLine.replace('{Discount}', (discount == null || discount == 0) ? '' : String.valueOf(discount) + '%') ;
		rebateLine = rebateLine.replace('{DiscountAmount}', (amount == null || amount == 0) ? '' : 'R' + String.valueOf(amount));
		rebateLine = rebateLine.replace('{RebateMonths}', months == null ? '' : String.valueOf(months));
		System.debug(rebateLine);
		return rebateLine;
	}

	@HttpPost
	global static DTO_Quote_Response calculateQuote()
	{
		String body = RestContext.request.requestBody.toString();
		System.debug(body);
		DTO_Quote aQuoteRequest = (DTO_Quote) System.JSON.deserialize(body, DTO_Quote.class);
		List<SBQQ__Quote__c> quoteInfos = [SELECT Id, SBQQ__LastCalculatedOn__c FROM SBQQ__Quote__c WHERE Id = :aQuoteRequest.quoteId];
		Boolean isCalculated = false;

		if (!quoteInfos.isEmpty())
		{
			SBQQ__Quote__c aQuote = quoteInfos.get(0);
			System.debug(aQuote.SBQQ__LastCalculatedOn__c);
			System.debug(aQuoteRequest.dateSubmitted);
			if (aQuote.SBQQ__LastCalculatedOn__c >= aQuoteRequest.dateSubmitted)
			{
				isCalculated = true;
			}
		}

		DTO_Quote aQuoteResponse = new DTO_Quote();
		aQuoteResponse.quoteId = aQuoteRequest.quoteId;
		aQuoteResponse.isCalculated = isCalculated;
		DTO_Quote_Response aResponse = new DTO_Quote_Response();
		aResponse.id = aQuoteRequest.quoteId;
		aResponse.success = true;
		aResponse.quoteInfo = aQuoteResponse;
		return aResponse;
	}

}