/**
* Author	:	Swapnil Walse
* Date		:	1 April 2021
* Desc		:	Invocable class to amend contracts.
* 			:	
* 			:	 
* 				
**/
public class CPQ_APIAmendContractInvocable {

    public class RequestParams {
        @InvocableVariable public Id contractId;
        @InvocableVariable public Boolean cancelContract;
        @InvocableVariable public String cancellationProductCode;
        @InvocableVariable public Id priceBookId;
        @InvocableVariable public Date amendStartDate;
        @InvocableVariable public Boolean waiverCancellationFee;
        @InvocableVariable public Decimal waiverCancellationFeePercent;
    }

    @InvocableMethod
    public static List<Id> amendContract(List<RequestParams> inputs)
    {
        List<Id> quoteIds = new List<Id>();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        for (RequestParams requestInputs : inputs)
        {
            QuoteModel quoteModel = CPQ_APIWrapper.amendContract(requestInputs.contractId);
            quoteModel.record.SBQQ__StartDate__c = requestInputs.amendStartDate;
            if (requestInputs.cancelContract)
            {
                // query the cancellation product option for this particular bundle
                List<SBQQ__ProductOption__c> options = getOptions(
                        requestInputs.cancellationProductCode,
                        quoteModel.lineItems[0].record.SBQQ__Product__c
                );
                if (options.isEmpty()) {
                    quoteIds.add(quoteModel.record.Id);
                    continue;
                }
                SBQQ__QuoteLine__c cancellationLine = createCancellationLine(requestInputs, quoteModel, options[0]);
                quoteLines.add(cancellationLine);
            }
            quoteIds.add(quoteModel.record.Id);
        }
		Database.insert(quoteLines);
        return quoteIds;
    }

    private static List<SBQQ__ProductOption__c> getOptions(String productCode, Id productSKUId)
    {
        return
        [
                SELECT
                        Id,
                        Name,
                        SBQQ__AppliedImmediatelyContext__c,
                        SBQQ__AppliedImmediately__c,
                        SBQQ__Bundled__c,
                        SBQQ__ComponentCodePosition__c,
                        SBQQ__ComponentCode__c,
                        SBQQ__ComponentDescriptionPosition__c,
                        SBQQ__ComponentDescription__c,
                        SBQQ__ConfiguredSKU__c,
                        SBQQ__DefaultPricingTable__c,
                        SBQQ__DiscountAmount__c,
                        SBQQ__DiscountSchedule__c,
                        SBQQ__Discount__c,
                        SBQQ__DiscountedByPackage__c,
                        SBQQ__ExistingQuantity__c,
                        SBQQ__Feature__c,
                        SBQQ__MaxQuantity__c,
                        SBQQ__MinQuantity__c,
                        SBQQ__Number__c,
                        SBQQ__OptionalSKU__c,
                        SBQQ__OptionalSKU__r.SBQQ__Hidden__c,
                        SBQQ__OptionalSKU__r.SBQQ__Taxable__c,
                        SBQQ__OptionalSKU__r.SBQQ__SubscriptionPricing__c,
                        SBQQ__OptionalSKU__r.SBQQ__SubscriptionBase__c,
                        SBQQ__OptionalSKU__r.SBQQ__PricingMethod__c,
                        SBQQ__OptionalSKU__r.SBQQ__SubscriptionType__c,
                        SBQQ__OptionalSKU__r.SBQQ__ChargeType__c,
                        SBQQ__OptionalSKU__r.SBQQ__BillingType__c,
                        SBQQ__OptionalSKU__r.SBQQ__BillingFrequency__c,
                        SBQQ__OptionalSKU__r.SBQQ__Optional__c,
                        SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c,
                        SBQQ__OptionalSKU__r.SBQQ__PricingMethodEditable__c,
                        SBQQ__PriceEditable__c,
                        SBQQ__ProductCode__c,
                        SBQQ__ProductConfigurationType__c,
                        SBQQ__ProductDescription__c,
                        SBQQ__ProductFamily__c,
                        SBQQ__ProductName__c,
                        SBQQ__ProductQuantityScale__c,
                        SBQQ__ProductSubscriptionPricing__c,
                        SBQQ__QuantityEditable__c,
                        SBQQ__Quantity__c,
                        SBQQ__QuoteLineVisibility__c,
                        SBQQ__RenewalProductOption__c,
                        SBQQ__Required__c,
                        SBQQ__Selected__c,
                        SBQQ__SubscriptionScope__c,
                        SBQQ__System__c, SBQQ__Type__c,
                        SBQQ__UnitPrice__c,
                        SBQQ__UpliftedByPackage__c
                FROM
                        SBQQ__ProductOption__c
                WHERE
                SBQQ__ProductCode__c = :productCode
                AND
                SBQQ__ConfiguredSKU__c = :productSKUId
        ];
    }

    private static SBQQ__QuoteLine__c createCancellationLine(RequestParams eachParam, QuoteModel quoteModel, SBQQ__ProductOption__c cancellationProductOption)
    {
        List<PricebookEntry> cancellationPricebookEntries = getCancellationEntry(eachParam.priceBookId, eachParam.cancellationProductCode);

        SBQQ__QuoteLine__c newQuoteLine = newQuoteLine(
                quoteModel,
                cancellationProductOption,
                cancellationPricebookEntries[0],
                eachParam.waiverCancellationFee,
                eachParam.waiverCancellationFeePercent
        );

        QuoteLineModel newLineModel = new QuoteLineModel();
        newLineModel.record = newQuoteLine;
        newLineModel.upliftable = cancellationProductOption.SBQQ__UpliftedByPackage__c;
        newLineModel.reconfigurationDisabled = true;
        newLineModel.productQuantityEditable = false;
        newLineModel.productHasDimensions = false;
        newLineModel.key = quoteModel.nextKey;
//        newLineModel.parentGroupKey = quoteModel.lineItems[0].parentGroupKey;
//        newLineModel.parentItemKey = quoteModel.lineItems[0].key; //root is always at 0
        newLineModel.descriptionLocked = true;
        newLineModel.targetCustomerAmount = 0;

        quoteModel.lineItems.add(newLineModel);
        return newQuoteLine;
    }

    private static List<PricebookEntry> getCancellationEntry(Id pricebookId, String productCode)
    {
        return
        [
                SELECT
                        Id,
                        UnitPrice
                FROM
                        PricebookEntry
                WHERE
                        Pricebook2Id = :pricebookId
                        AND
                        ProductCode = :productCode
        ];
    }

    public static SBQQ__QuoteLine__c newQuoteLine(
        QuoteModel quoteModel, 
        SBQQ__ProductOption__c cancelOption, 
        PricebookEntry cancelPBE, 
        Boolean waiverFee,
        Decimal waiverFeePercent
    )
    {
        SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
        newQuoteLine.SBQQ__Quote__c = quoteModel.record.Id;
        newQuoteLine.SBQQ__Product__c = cancelOption.SBQQ__OptionalSKU__c;
        newQuoteLine.SBQQ__Number__c = quoteModel.nextKey;
        newQuoteLine.SBQQ__PricebookEntryId__c = cancelPBE.Id;
        newQuoteLine.SBQQ__HasConsumptionSchedule__c = false;
        newQuoteLine.SBQQ__Hidden__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__Hidden__c;
        newQuoteLine.SBQQ__Taxable__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__Taxable__c;
        newQuoteLine.SBQQ__SubscriptionPricing__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__SubscriptionPricing__c;
        newQuoteLine.SBQQ__SubscriptionBase__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__SubscriptionBase__c;
        newQuoteLine.SBQQ__SubscriptionScope__c = cancelOption.SBQQ__SubscriptionScope__c;
        newQuoteLine.SBQQ__ProductSubscriptionType__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__SubscriptionType__c;
        newQuoteLine.SBQQ__SubscriptionType__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__SubscriptionType__c;
        newQuoteLine.SBQQ__ChargeType__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c;
        newQuoteLine.SBQQ__BillingType__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__BillingType__c;
        newQuoteLine.SBQQ__BillingFrequency__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__BillingFrequency__c;
        newQuoteLine.SBQQ__ListPrice__c = cancelPBE.UnitPrice;
        newQuoteLine.SBQQ__OriginalPrice__c = cancelPBE.UnitPrice;
        newQuoteLine.SBQQ__Optional__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__Optional__c;
        newQuoteLine.SBQQ__Bundle__c = cancelOption.SBQQ__Bundled__c;
        newQuoteLine.SBQQ__PriceEditable__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__PriceEditable__c;
        newQuoteLine.SBQQ__PricingMethod__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__PricingMethod__c;
        newQuoteLine.SBQQ__PricingMethodEditable__c = cancelOption.SBQQ__OptionalSKU__r.SBQQ__PricingMethodEditable__c;
        newQuoteLine.SBQQ__Quantity__c = 1;
//        newQuoteLine.SBQQ__BundledQuantity__c = 1;
        newQuoteLine.SBQQ__Renewal__c = false;
        newQuoteLine.SBQQ__AllowAssetRefund__c = true;
        newQuoteLine.SBQQ__ProductOption__c = cancelOption.Id;
//        newQuoteLine.SBQQ__OptionLevel__c = 1;
//        newQuoteLine.SBQQ__OptionType__c = 'Component';
//        newQuoteLine.SBQQ__RequiredBy__c = quoteModel.lineItems[0].record.Id;
        if (waiverFee == true) {
            newQuoteLine.SBQQ__Discount__c = waiverFeePercent == null ? 100 : waiverFeePercent;
        }
        return newQuoteLine;
    }

}