public class LCC_QuoteSummary
{

	@AuraEnabled
	public static DTO_QuoteSummary getQuoteLines(Id quoteId)
	{
		DTO_QuoteSummary returnObj = new DTO_QuoteSummary();
		returnObj.groups = new List<DTO_QuoteSummary.quoteLinesGroup>();
		returnObj.rates = new List<DTO_QuoteSummary.quoteLines>();

		List<SBQQ__QuoteLineConsumptionRate__c> consumptionRates =
		[
				SELECT
						Id,
						SBQQ__LowerBound__c,
						SBQQ__UpperBound__c,
						SBQQ__Price__c,
						SBQQ__QuoteLineConsumptionSchedule__c,
						SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c,
						SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c
				FROM
						SBQQ__QuoteLineConsumptionRate__c
				WHERE
						SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c = :quoteId
				ORDER BY
						SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c ASC
		];

		for (SBQQ__QuoteLineConsumptionRate__c eachRate : consumptionRates)
		{
			DTO_QuoteSummary.quoteLines newLine = new DTO_QuoteSummary.quoteLines();
			newLine.quoteLineId = eachRate.Id;
			newLine.lowerBound = eachRate.SBQQ__LowerBound__c;
			newLine.upperBound = eachRate.SBQQ__UpperBound__c;
			newLine.productName = eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c;
			if (eachRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__ProductCode__c.endsWith('_PER_TRANSACTION_FEES'))
			{
				newLine.transactionFee = eachRate.SBQQ__Price__c;
			} else
			{
				newLine.rate = eachRate.SBQQ__Price__c / 100;
			}
			returnObj.rates.add(newLine);
		}

		List<DTO_QuoteSummary.quoteLinesGroup> quoteLinesGroup = returnObj.groups;

		List<SBQQ__QuoteLine__c> quoteLines =
		[
				SELECT
                        Id,
						SBQQ__CustomerTotal__c,
						SBQQ__Discount__c,
						SBQQ__AdditionalDiscountAmount__c,
						SBQQ__NetTotal__c,
						NetTotalWithVATCalc__c,
						VATCalculated__c,
						SBQQ__ProductName__c,
						SBQQ__Product__c,
						SBQQ__ProductCode__c,
						SBQQ__Product__r.SBQQ__Hidden__c,
						SBQQ__Product__r.IsAssetProduct__c,
						SBQQ__Product__r.IsSubscriptionProduct__c,
						SBQQ__RequiredBy__r.SBQQ__ProductCode__c, //Parent product code
						SBQQ__Quantity__c,
						SBQQ__Group__r.Name,
						SBQQ__Quote__r.Name,
						RebateQuantity__c,
						RebatePercent__c,
						RebateMonths__c,
						RebateAmount__c
				FROM SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__c = :quoteId
				AND SBQQ__RequiredBy__r.SBQQ__ProductCode__c != :DAL_Product.rateBundleProductCode
				AND SBQQ__ProductCode__c != :DAL_Product.rateBundleProductCode
				ORDER BY SBQQ__Group__r.SBQQ__Number__c, SBQQ__Number__c
		];
		Map<String, Map<String, DTO_QuoteSummary.quoteLines>> mapQuoteLines = new Map<String, Map<String, DTO_QuoteSummary.quoteLines>>();
		if (!quoteLines.isEmpty())
		{
			String currentGroup = '';
			DTO_QuoteSummary.quoteLinesGroup newGroup;
			Decimal onceOffAmount = 0;
			Decimal recurringAmount = 0;

			for (SBQQ__QuoteLine__c eachLine : quoteLines)
			{

				if (!eachLine.SBQQ__Product__r.SBQQ__Hidden__c)
				{
					if (eachLine.SBQQ__Product__r.IsSubscriptionProduct__c)
					{
						recurringAmount += eachLine.NetTotalWithVATCalc__c;
					}
					else
					{
						onceOffAmount += eachLine.NetTotalWithVATCalc__c;
					}
					if (eachLine.SBQQ__Group__r.Name != currentGroup)
					{
						newGroup = new DTO_QuoteSummary.quoteLinesGroup();
						newGroup.groupName = eachLine.SBQQ__Group__r.Name;
						quoteLinesGroup.add(newGroup);
						newGroup.quoteLines = new List<DTO_QuoteSummary.quoteLines>();
						currentGroup = eachLine.SBQQ__Group__r.Name;
						mapQuoteLines.put(currentGroup, new Map<String, DTO_QuoteSummary.quoteLines>());
					}
					DTO_QuoteSummary.quoteLines newLine = new DTO_QuoteSummary.quoteLines();
					newLine.discount = eachLine.SBQQ__Discount__c == null ? 0 : eachLine.SBQQ__Discount__c / 100;
					newLine.additionalDiscount = eachLine.SBQQ__AdditionalDiscountAmount__c == null ? 0 : eachLine.SBQQ__AdditionalDiscountAmount__c;
					newLine.vatAmount = eachLine.VATCalculated__c;
					newLine.netAmount = eachLine.SBQQ__NetTotal__c;
					newLine.netTotal = eachLine.NetTotalWithVATCalc__c;
					newLine.productName = eachLine.SBQQ__ProductName__c;
					newLine.quantity = Integer.valueOf(eachLine.SBQQ__Quantity__c);
					newLine.quoteNumber = eachLine.SBQQ__Quote__r.Name;
					newLine.quoteLineId = eachLine.Id;
					newLine.rebateQty = (eachLine.RebateQuantity__c == null ? 0 : eachLine.RebateQuantity__c);
					newLine.rebateMonths = eachLine.RebateMonths__c == null ? 0 : eachLine.RebateMonths__c;
					newLine.rebatePercent = (eachLine.RebatePercent__c == null ? 0 : eachLine.RebatePercent__c) / 100;//lightning component bug
					newLine.rebateAmount = (eachLine.RebateAmount__c == null ? 0 : eachLine.RebateAmount__c);
					newGroup.quoteLines.add(newLine);

					if (mapQuoteLines.get(currentGroup).containsKey(eachLine.SBQQ__ProductCode__c))
					{
						DTO_QuoteSummary.quoteLines quoteLines2 = mapQuoteLines.get(currentGroup).get(eachLine.SBQQ__ProductCode__c);
						quoteLines2.discount = eachLine.SBQQ__Discount__c == null ? 0 : eachLine.SBQQ__Discount__c / 100;
						quoteLines2.vatAmount += eachLine.VATCalculated__c;
						quoteLines2.netAmount += eachLine.SBQQ__NetTotal__c;
						quoteLines2.netTotal += eachLine.NetTotalWithVATCalc__c;
						quoteLines2.productName = eachLine.SBQQ__ProductName__c;
						quoteLines2.quantity += Integer.valueOf(eachLine.SBQQ__Quantity__c);
						quoteLines2.quoteNumber = eachLine.SBQQ__Quote__r.Name;
						quoteLines2.rebateQty += (eachLine.RebateQuantity__c == null ? 0 : eachLine.RebateQuantity__c);
					}
					else
					{
						mapQuoteLines.get(currentGroup).put(eachLine.SBQQ__ProductCode__c, newLine);
					}
				}
			}
			returnObj.onceOffAmount = onceOffAmount;
			returnObj.monthlyAmount = recurringAmount;
		}

		returnObj.groups = new List<DTO_QuoteSummary.quoteLinesGroup>();

		for (String aGroup : mapQuoteLines.keySet())
		{
			DTO_QuoteSummary.quoteLinesGroup newGroup = new DTO_QuoteSummary.quoteLinesGroup();
			newGroup.groupName = aGroup;
			if (newGroup.quoteLines == null)
			{
				newGroup.quoteLines = new List<DTO_QuoteSummary.quoteLines>();
			}
			for (String aLineKey : mapQuoteLines.get(aGroup).keySet())
			{
				newGroup.quoteLines.add(mapQuoteLines.get(aGroup).get(aLineKey));
			}
			returnObj.groups.add(newGroup);
		}

		return returnObj;
	}

	@AuraEnabled
	public static DTO_QuoteSummary getQuoteLines2(Id quoteId)
	{
		DTO_Quote quoteRequest = new DTO_Quote();
		quoteRequest.quoteId = quoteId;
		DTO_QuoteSummary responseObj = (DTO_QuoteSummary) new API_Callout_SalesApp().getQuote(quoteId);
		return responseObj;
	}
}