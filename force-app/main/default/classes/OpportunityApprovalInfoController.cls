/**
 * Created by JurgitaG on 7/16/2021.
 */

public class OpportunityApprovalInfoController
{
	public class productData{
		@AuraEnabled
		public String productName;
		@AuraEnabled
		public Decimal discount;
		@AuraEnabled
		public Decimal netTotal;
		@AuraEnabled
		public Decimal quantity;
		@AuraEnabled
		public Decimal priorQuantity;
		@AuraEnabled
		public Id quoteLineId;
	}


	@AuraEnabled
	public static String getRecordId(Id processId){
		List<ProcessInstanceWorkitem> processWorkItems = [
				SELECT
						Id, CreatedDate, ProcessInstance.TargetObjectId
				FROM ProcessInstanceWorkitem WHERE Id = : processId
		];
		if (processWorkItems.isEmpty())
		{
			return null;
		}
		return processWorkItems.get(0).ProcessInstance.TargetObjectId;
	}

	@AuraEnabled
	public static String getOpportunityType(String processId){
		String recordId = getRecordId(processId);

		List<Opportunity> opps = [SELECT Id, Type FROM Opportunity WHERE Id = :recordId];
		if (opps.isEmpty())
		{
			return null;
		}
		return opps.get(0).Type;
	}

	@AuraEnabled
	public static List<productData> getQuoteLines(String processId){
		String recordId = getRecordId(processId);
		List<productData> oppProducts = new List<OpportunityApprovalInfoController.productData>();
		List<SBQQ__QuoteLine__c> lines = [
				SELECT
						Id,
						SBQQ__ProductName__c,
						SBQQ__NetTotal__c,
						SBQQ__Quantity__c,
						SBQQ__PriorQuantity__c,
						SBQQ__Discount__c
				FROM SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__c IN (SELECT SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id =:recordId) AND SBQQ__Hidden__c= FALSE
		];
		for (SBQQ__QuoteLine__c aLine: lines){
			productData oppProduct = new productData();
			oppProduct.productName = aLine.SBQQ__ProductName__c;
			oppProduct.quantity = aLine.SBQQ__Quantity__c;
			oppProduct.priorQuantity = aLine.SBQQ__PriorQuantity__c;
			oppProduct.netTotal = aLine.SBQQ__NetTotal__c;
			oppProduct.discount = aLine.SBQQ__Discount__c;
			oppProduct.quoteLineId = aLine.Id;
			oppProducts.add(oppProduct);
		}

		return oppProducts;
	}
}