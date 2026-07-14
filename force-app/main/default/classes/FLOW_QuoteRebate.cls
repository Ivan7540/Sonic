/**
 * Created by JurgitaG on 4/12/2021.
 */

public with sharing class FLOW_QuoteRebate
{
	@InvocableMethod(label='Add Rebates' category='Quote' Callout=true)
	public static List<QuoteRebateResult> addRates(List<QuoteRateRequest> requests)
	{
		List<QuoteRebateResult> createdQuotes = new List<QuoteRebateResult>();
		for(QuoteRateRequest qrequest : requests){

			Id quoteId = qrequest.QuoteId;
			System.debug(qrequest.rebates);
			List<DTO_QuoteProduct> quoteRebates = qrequest.rebates;
			List<DTO_QuoteProduct>rebates =new List<DTO_QuoteProduct>();
			if (qrequest.rebates!=null)
			{
				rebates = qrequest.rebates;
			}
			DTO_Quote quoteRateReq = new DTO_Quote(quoteId, quoteRebates);
			quoteRateReq.dealId = qrequest.dealId;
			quoteRateReq.saleType = qrequest.saleType;
			Map<String, String> responseObj = new API_Callout_SalesApp().addRebates(quoteRateReq);
			System.debug(responseObj);

			DTO_Quote_Response  response = DTO_Quote_Response.parse(responseObj.get(API_Callout_Base.SUCCESS));
//			Id quoteId = response.id;

			QuoteRebateResult result = new QuoteRebateResult();
			result.quoteId = quoteId;
			result.dateSubmitted = response.quoteInfo.dateSubmitted;
			createdQuotes.add(result);
			if (!Test.isRunningTest())
			{
				updateDealLines(qrequest.dealId, rebates);
			}

		}
		return createdQuotes;
	}

	public static void updateDealLines(String dealId, List<DTO_QuoteProduct> rebates){
		List<Deal_Line__c> dealLines = [
				SELECT Id,
						BundleId__c,
						Name,
						RebateMonths__c,
						RebateDiscountAmount__c,
						RebateDiscountPercentage__c,
						RebatedQuantity__c,
						RebateMotivation__c,
						RebatedProduct__c
				FROM
						Deal_Line__c
				WHERE Deal__c =:dealId
				AND (BundleId__c!= null
				OR RebatedProduct__c !=null)
		];
		Map<Id, Deal_Line__c> lineMapByBundle= new Map<Id, Deal_Line__c>();
		List< Deal_Line__c> otherRebates= new List< Deal_Line__c>();
		for (Deal_Line__c dealLine :dealLines){
			dealLine.RebatedQuantity__c = null;
			dealLine.RebateMonths__c = null;
			dealLine.RebateDiscountAmount__c = null;
			dealLine.RebateDiscountPercentage__c = null;
			dealLine.RebateMotivation__c = null;
			if (dealLine.BundleId__c != null)
			{
				lineMapByBundle.put(dealLine.BundleId__c, dealLine);
			} else {
				otherRebates.add( dealLine);
			}
		}
		delete otherRebates;
		List<Deal_Line__c> linesToCreate= new List<Deal_Line__c>();
		for (DTO_QuoteProduct aRebate :rebates){
			if (aRebate.productId!=null && lineMapByBundle.containsKey(aRebate.productId))
			{
				Deal_Line__c aLine = lineMapByBundle.get(aRebate.productId);
				aLine.RebatedQuantity__c = aRebate.quantity;
				aLine.RebateMonths__c = aRebate.numberOfMonths;
				aLine.RebateDiscountAmount__c = aRebate.discountAmount;
				aLine.RebateDiscountPercentage__c = aRebate.discount;
				aLine.RebateMotivation__c = aRebate.rebateMotivation;
			}
			if (aRebate.rebatedProduct !=null)
			{
				Deal_Line__c aLine = new Deal_Line__c();

				aLine.RebatedQuantity__c = aRebate.quantity;
				aLine.Name = aRebate.rebatedProduct;
				aLine.RebateMonths__c = aRebate.numberOfMonths;
				aLine.RebateDiscountAmount__c = aRebate.discount;
				aLine.RebateDiscountPercentage__c = aRebate.discountAmount;
				aLine.RebateMotivation__c = aRebate.rebateMotivation;
				aLine.RebatedProduct__c = aRebate.rebatedProduct;
				aLine.Deal__c = dealId;
				linesToCreate.add(aLine);

			}
		}
		insert linesToCreate;
		update lineMapByBundle.values();

	}

	public class QuoteRateRequest
	{
		@InvocableVariable(label='Quote Id' required=true)
		public String QuoteId;

		@InvocableVariable(label='Deal Id' required=true)
		public String dealId;

		@InvocableVariable(label='Sale Type')
		public String saleType;

		//Because we cannot pass any other type List to Invocable method,
		// I am passing conjunct String where fields is presented in following order: Product, Device, Contract Term, Quantity
		// they are separated by ',' symbol
		@InvocableVariable(label='Product List with rebates')
		public List<DTO_QuoteProduct> rebates;
	}
	public class QuoteRebateResult{
		@InvocableVariable(label='Quote Id' required=true)
		public String quoteId;


		@InvocableVariable(label='Quote submitted for calculation time')
		public Datetime dateSubmitted;
	}
}