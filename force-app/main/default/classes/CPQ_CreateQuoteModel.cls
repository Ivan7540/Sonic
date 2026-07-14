/**
* Author	:	Swapnil Walse
* Date		:	23 March 2021
* Desc		:	Class that adds pre-defined product structure to a quote with a group
* 			:	inputs:
* 			:	quoteId: quote to which product and group needs to be added
*			:	staticResource: name of static resource to be added, including the prefix 'PM_'
*			:	deviceQtyMap: product code and qty map.
*			:	This method also adds Group if a group of that name does not exist, if it does, uses existing group name
* 				
**/
@RestResource(urlMapping='/SonicCPQ/AddBundleFromStaticResource')
global class CPQ_CreateQuoteModel
{
	Static Integer nextLine;

	global class requestParams
	{
		public String quoteId;
		public String staticResource;
		public Map<String, Integer> deviceQtyMap;
	}

	@HttpPost
	global static List<String> createCPQQuoteModelCallout(List<requestParams> inputs)
	{
		List<String> statusMsgs = new List<String>();

		for (requestParams eachParam : inputs)
		{
			try
			{
				String status = createCPQQuoteModel(eachParam.quoteId, eachParam.staticResource, eachParam.deviceQtyMap);
				statusMsgs.add(status);
			}
			catch (Exception e)
			{
				statusMsgs.add(e.getMessage());
			}
		}

		return statusMsgs;
	}

	public static String createCPQQuoteModel(Id quoteId, String staticResource, Map<String, Integer> deviceQtyMap)
	{
		Integer rootLineKey;
		Id rootLineId;
		StaticResource resource = getResource(staticResource);

		if (resource != null)
		{
			String jsonString = resource.Body.toString();
			QuoteModel quoteModel = (QuoteModel) JSON.deserialize(jsonString, QuoteModel.class);
			QuoteModel newQM = CPQ_APIWrapper.getQuoteModel(quoteId);
			nextLine = newQM.nextKey;

			//Below 2 maps to update group and parent keys
			Map<Integer, Integer> groupMap = new Map<Integer, Integer>();
			Map<Integer, Integer> lineMap = new Map<Integer, Integer>();

			//Below maps to create clones of device product that are input in deviceQtyMap Map
			Map<Integer, List<QuoteLineModel>> childRecordListMap = new Map<Integer, List<QuoteLineModel>>();
			Map<String, QuoteLineModel> productCodeMap = new Map<String, QuoteLineModel>();

			//Create a map of existing groups
			Map<String, Integer> newQMExistingGroupMap = new Map<String, Integer>();

			for (QuoteLineGroupModel eachModel : newQM.lineItemGroups)
			{
				newQMExistingGroupMap.put(eachModel.record.Name, eachModel.key);
			}

			//Copy across groups
			for (QuoteLineGroupModel eachModel : quoteModel.lineItemGroups)
			{
				if (newQMExistingGroupMap.containsKey(eachModel.record.Name))
				{
					groupMap.put(eachModel.key, newQMExistingGroupMap.get(eachModel.record.Name));
					nextLine++;
				}
				else
				{
					QuoteLineGroupModel newModel = new QuoteLineGroupModel();
					SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c();
					newModel.record = newGroup;
					newModel.key = nextLine;
					newGroup.Name = eachModel.record.Name;
					newGroup.CurrencyIsoCode = eachModel.record.CurrencyIsoCode;
					newGroup.SBQQ__Quote__c = quoteId;
					newGroup.SBQQ__Account__c = newQM.record.SBQQ__Account__c;
					newGroup.SBQQ__AdditionalDiscountRate__c = eachModel.record.SBQQ__AdditionalDiscountRate__c;
					newGroup.SBQQ__BillingFrequency__c = eachModel.record.SBQQ__BillingFrequency__c;
					newGroup.SBQQ__CustomerTotal__c = eachModel.record.SBQQ__CustomerTotal__c;
					newGroup.SBQQ__Description__c = eachModel.record.SBQQ__Description__c;
					newGroup.SBQQ__ListTotal__c = eachModel.record.SBQQ__ListTotal__c;
					newGroup.SBQQ__NetTotal__c = eachModel.record.SBQQ__NetTotal__c;
					newGroup.SBQQ__Optional__c = eachModel.record.SBQQ__Optional__c;
					newGroup.SBQQ__SeparateContract__c = true;
					newGroup.SBQQ__SubscriptionTerm__c = eachModel.record.SBQQ__SubscriptionTerm__c;
					newGroup.SBQQ__Number__c = nextLine;
					nextLine++;
					groupMap.put(eachModel.key, newModel.key);

					newQM.lineItemGroups.add(newModel);
				}
			}

			Map<Id, SObject> contractedPriceMap = getContractedPrices(newQM.record.SBQQ__Account__c, newQM.record.SBQQ__MasterContract__c);

			for (QuoteLineModel lineModel : quoteModel.lineItems)
			{
				QuoteLineModel newLineModel = new QuoteLineModel();
				SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
				newLineModel.record = newQuoteLine;
				newLineModel.upliftable = lineModel.upliftable;
				newLineModel.reconfigurationDisabled = lineModel.reconfigurationDisabled;
				newLineModel.productQuantityEditable = lineModel.productQuantityEditable;
				newLineModel.productHasDimensions = lineModel.productHasDimensions;
				newLineModel.key = nextLine;

				newLineModel.parentGroupKey = groupMap.get(lineModel.parentGroupKey);

				if (lineModel.parentItemKey != null)
				{
					newLineModel.parentItemKey = lineMap.get(lineModel.parentItemKey);
				}
				else
				{
					rootLinekey = newLineModel.key;
				}

				newLineModel.descriptionLocked = lineModel.descriptionLocked;
				newQuoteLine.SBQQ__Quote__c = quoteId;
				newQuoteLine.SBQQ__Product__c = lineModel.record.SBQQ__Product__c;

				if (contractedPriceMap.containsKey(lineModel.record.SBQQ__Product__c))
				{
					SBQQ__ContractedPrice__c price = (SBQQ__ContractedPrice__c) contractedPriceMap.get(lineModel.record.SBQQ__Product__c);
					newQuoteLine.SBQQ__ContractedPrice__c = price.Id;
					newQuoteLine.SBQQ__SpecialPriceType__c = 'Contracted Price';
					newQuoteLine.SBQQ__SpecialPrice__c = price.SBQQ__Price__c;
					// Catering for percentage discounts if ever used in the future
					newQuoteLine.SBQQ__Discount__c = price.SBQQ__Discount__c;
				}

				newQuoteLine.SBQQ__Number__c = nextLine;
				newQuoteLine.SBQQ__PricebookEntryId__c = lineModel.record.SBQQ__PricebookEntryId__c;
				newQuoteLine.SBQQ__HasConsumptionSchedule__c = lineModel.record.SBQQ__HasConsumptionSchedule__c;
				newQuoteLine.SBQQ__Hidden__c = lineModel.record.SBQQ__Hidden__c;
				newQuoteLine.SBQQ__Taxable__c = lineModel.record.SBQQ__Taxable__c;
				newQuoteLine.SBQQ__SubscriptionPricing__c = lineModel.record.SBQQ__SubscriptionPricing__c;
				newQuoteLine.SBQQ__SubscriptionBase__c = lineModel.record.SBQQ__SubscriptionBase__c;
				newQuoteLine.SBQQ__SubscriptionScope__c = lineModel.record.SBQQ__SubscriptionScope__c;
				newQuoteLine.SBQQ__ProductSubscriptionType__c = lineModel.record.SBQQ__ProductSubscriptionType__c;
				newQuoteLine.SBQQ__SubscriptionType__c = lineModel.record.SBQQ__SubscriptionType__c;
				newQuoteLine.SBQQ__ChargeType__c = lineModel.record.SBQQ__ChargeType__c;
				newQuoteLine.SBQQ__BillingType__c = lineModel.record.SBQQ__BillingType__c;
				newQuoteLine.SBQQ__BillingFrequency__c = lineModel.record.SBQQ__BillingFrequency__c;
				newQuoteLine.SBQQ__CostEditable__c = lineModel.record.SBQQ__CostEditable__c;
				newQuoteLine.SBQQ__ListPrice__c = lineModel.record.SBQQ__ListPrice__c;
				newQuoteLine.SBQQ__OriginalPrice__c = lineModel.record.SBQQ__OriginalPrice__c;
				newQuoteLine.SBQQ__NonDiscountable__c = lineModel.record.SBQQ__NonDiscountable__c;
				newQuoteLine.SBQQ__NonPartnerDiscountable__c = lineModel.record.SBQQ__NonDiscountable__c;
				newQuoteLine.SBQQ__Optional__c = lineModel.record.SBQQ__Optional__c;
				newQuoteLine.SBQQ__Bundle__c = lineModel.record.SBQQ__Bundle__c;
				newQuoteLine.SBQQ__Bundled__c = lineModel.record.SBQQ__Bundled__c;
				newQuoteLine.SBQQ__PriceEditable__c = lineModel.record.SBQQ__PriceEditable__c;
				newQuoteLine.SBQQ__PricingMethod__c = lineModel.record.SBQQ__PricingMethod__c;
				newQuoteLine.SBQQ__PricingMethodEditable__c = lineModel.record.SBQQ__PricingMethodEditable__c;
				newQuoteLine.SBQQ__Quantity__c = lineModel.record.SBQQ__Quantity__c;
				newQuoteLine.SBQQ__Renewal__c = lineModel.record.SBQQ__Renewal__c;
				newQuoteLine.SBQQ__AllowAssetRefund__c = lineModel.record.SBQQ__AllowAssetRefund__c;
				newQuoteLine.SBQQ__Product__r = lineModel.record.SBQQ__Product__r;
				newQuoteLine.SBQQ__ProductOption__r = lineModel.record.SBQQ__ProductOption__r;
				newQuoteLine.SBQQ__ProductOption__c = lineModel.record.SBQQ__ProductOption__c;
				newQuoteLine.SBQQ__DynamicOptionId__c = lineModel.record.SBQQ__DynamicOptionId__c;
				newQuoteLine.SBQQ__Description__c = lineModel.record.SBQQ__Description__c;
				newQuoteLine.SBQQ__Favorite__c = lineModel.record.SBQQ__Favorite__c;
				newQuoteLine.SBQQ__SubscriptionPercent__c = lineModel.record.SBQQ__SubscriptionPercent__c;
				newQuoteLine.SBQQ__DefaultSubscriptionTerm__c = lineModel.record.SBQQ__DefaultSubscriptionTerm__c;
				newQuoteLine.SBQQ__SubscriptionCategory__c = lineModel.record.SBQQ__SubscriptionCategory__c;
				newQuoteLine.SBQQ__TaxCode__c = lineModel.record.SBQQ__TaxCode__c;
				newQuoteLine.SBQQ__CompoundDiscountRate__c = lineModel.record.SBQQ__CompoundDiscountRate__c;
				newQuoteLine.SBQQ__Cost__c = lineModel.record.SBQQ__Cost__c;
				newQuoteLine.SBQQ__DiscountSchedule__c = lineModel.record.SBQQ__DiscountSchedule__c;
				newQuoteLine.SBQQ__TermDiscountSchedule__c = lineModel.record.SBQQ__TermDiscountSchedule__c;
				newQuoteLine.SBQQ__OptionDiscount__c = lineModel.record.SBQQ__OptionDiscount__c;

				//for Amendments
				newQuoteLine.SBQQ__BundledQuantity__c = lineModel.record.SBQQ__BundledQuantity__c;
				newQuoteLine.SBQQ__OptionLevel__c = lineModel.record.SBQQ__OptionLevel__c;
				newQuoteLine.SBQQ__OptionType__c = lineModel.record.SBQQ__OptionType__c;
				newQM.lineItems.add(newLineModel);
				lineMap.put(lineModel.key, newLineModel.key);
				nextLine++;

				//Add to productCodeMap
				ProductCodeMap.put(lineModel.record.SBQQ__ProductCode__c, newLineModel);

				//add to child lines map
				if (newLineModel.parentItemKey != null)
				{
					if (childRecordListMap.containsKey(newLineModel.parentItemKey))
					{
						childRecordListMap.get(newLineModel.parentItemKey).add(newLineModel);
					}
					else
					{
						List<QuoteLineModel> lineList = new List<QuoteLineModel>();
						lineList.add(newLineModel);
						childRecordListMap.put(newLineModel.parentItemKey, lineList);
					}
				}
			}

			//Now that all products are created, create clones of products
			if (deviceQtyMap != null)
			{
				for (String eachProductCode : deviceQtyMap.keySet())
				{
					if (productCodeMap.containsKey(eachProductCode))
					{
						if (eachProductCode == DAL_Product.masterpassRentalPC)
						{
							Integer masterpassQty = deviceQtyMap.get(eachProductCode);
							//for masterpass, we need reduce the qty based on what is given as it is already part of device bundle
							removeProduct(newQM, masterpassQty, eachProductCode);
							removeProduct(newQM, masterpassQty, 'SS_MASTERPASS');
						}
						else if (eachProductCode == DAL_Product.switchpayRentalPC)
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
//                            removeProduct(newQM, switchpayQty, DAL_Product.masterpassRentalPC);
							removeProduct(newQM, switchpayQty, 'SS_SWITCHPAY');
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == DAL_Product.MORETYME_NET)
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
//                                removeProduct(newQM, switchpayQty, DAL_Product.MORETYME_NET);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == DAL_Product.MORETYME_GROSS)
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
//                                removeProduct(newQM, switchpayQty, DAL_Product.MORETYME_GROSS);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == 'SS_MORETYME')
						{
							Integer productQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, productQty, eachProductCode);
						}
						else if ((eachProductCode == 'SS_LOYALTY_AND_GIFT_BUNDLE') || (eachProductCode == 'SS_LOYALTY_AND_GIFT_3_BUNDLE'))
						{
							Integer productQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, productQty, eachProductCode);
							removeProduct(newQM, productQty, 'SS_CARD_HOLDER_DISPLAY_STAND_AND_ARTWORK');
							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_OUTRIGHT_FEE');
							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_MONTHLY_FEE');
							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_SETUP_FEE');
							removeProduct(newQM, productQty, 'SS_CUSTOM_BRANDED_CARDS');

							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_MONTHLY_SERVICE_FEE');
							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_STARTER_OUTRIGHT_FEE');
							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_STARTER_MONTHLY_FEE');
							removeProduct(newQM, productQty, 'SS_GIFT_AND_LOYALTY_SETUP');
						}
						else if (eachProductCode == 'SS_CARD_ARTWORK_DESIGN_BESPOKE')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == 'SS_CARD_ARTWORK_DESIGN_STANDARD')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, 'SS_CARD_ARTWORK_DESIGN_STANDARD');
						}
						else if (eachProductCode == 'SS_CARD_ARTWORK_DESIGN_CATALOGUE')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
							removeProduct(newQM, switchpayQty, 'SS_CARD_ARTWORK_DESIGN_MERCHANT');
						}else if (eachProductCode == 'SS_CARD_ARTWORK_DESIGN_MERCHANT')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, 'SS_CARD_ARTWORK_DESIGN_MERCHANT');
						}
						else if (eachProductCode == 'SS_GIFT')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
							removeProduct(newQM, switchpayQty, 'SS_GIFT_ENROLMENT_FORM');
						}else if (eachProductCode == 'SS_AMEX')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == 'SS_LOYALTY')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
							removeProduct(newQM, switchpayQty, 'SS_LOYALTY_ENROLLMENT_FORM');

						}
						else if (eachProductCode == 'AD_A920PRO_BASE')
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == DAL_Product.paperRollProductCode)
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
						else if (eachProductCode == DAL_Product.PEDStandPC)
						{
							Integer switchpayQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, switchpayQty, eachProductCode);
						}
                        else if (eachProductCode == DAL_Product.bluetoothPrinterRentalPC)
						{
							Integer productQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, productQty, eachProductCode);
							removeProduct(newQM, productQty, 'SS_BLUETOOTH_PRINTER');

						}
                        else if (eachProductCode == DAL_Product.amexCardFee)
						{
							Integer productQty = deviceQtyMap.get(eachProductCode);
							removeProduct(newQM, productQty, eachProductCode);
						}

						else
						{
							Integer qty = deviceQtyMap.get(eachProductCode) - 1; //first instance has already been created.

							for (Integer ctr = 0; ctr < qty; ctr++)
							{
								QuoteLineModel parentLine = (QuoteLineModel) JSON.deserialize(JSON.serialize(productCodeMap.get(eachProductCode)), QuoteLineModel.class);
								newQM.lineItems.addAll(addClones(parentLine, parentLine.key, nextLine, productCodeMap, childRecordListMap));
							}
						}
					}
				}
			}

			//Now save and get the root quote line's Id
			newQM = CPQ_APIWrapper.saveQuote(newQM);
			for (QuoteLineModel eachLine : newQM.lineItems)
			{
				if (eachLine.key == rootLineKey)
				{
					rootLineId = eachLine.record.Id;
				}
			}

			return rootLineId;
		}
		else
		{
			return 'Static Resource ' + staticResource + ' Not Found';
		}
	}

	private static void removeProduct(QuoteModel newQM, Integer qty, String productCode)
	{
		for (Integer i = newQM.lineItems.size() - 1; i >= 0; i--)
		{
			if (!newQM.lineItems.isEmpty())
			{
				if (newQM.lineItems.get(i).record.SBQQ__Product__r.ProductCode == productCode)
				{
					if (qty > 0)
					{
						qty--;
						continue;
					}
					else
					{
						newQM.lineItems.remove(i);
					}
				}
			}
		}
	}

	//Recursive method to add children
	private static List<QuoteLineModel> addClones(QuoteLineModel parentLine,
			Integer originalKey,
			Integer parentKey,
			Map<String, QuoteLineModel> productCodeMap,
			Map<Integer, List<QuoteLineModel>> childRecordListMap)
	{
		List<QuoteLineModel> quoteLines = new List<QuoteLineModel>();
		//Integer originalKey = parentLine.key;//Get original key to get child lines
		Integer newKey = nextLine;//To set parent of new child lines
		parentLine.key = nextLine;
		parentLine.record.SBQQ__Number__c = nextLine;
		quoteLines.add(parentLine);
		nextLine++;

		List<QuoteLineModel> childLines = (List<QuoteLineModel>) JSON.deserialize(JSON.Serialize(childRecordListMap.get(originalKey)), List<QuoteLineModel>.class);

		// check if there are any children
		if (childLines != null)
		{
			for (QuoteLineModel eachLine : childLines)
			{
				eachLine.parentItemKey = parentKey;
				Integer childOriginalKey = eachLine.key;
				eachLine.key = nextLine;
				eachLine.record.SBQQ__Number__c = nextLine;
				//quoteLines.add(eachLine);
				nextLine++;
				quoteLines.addAll(addClones(eachLine, childOriginalKey, nextLine, productCodeMap, childRecordListMap));
			}
		}

		return quoteLines;
	}

	private static StaticResource getResource(String resourceName)
	{
		List<StaticResource> result =
		[
				SELECT Id,
						Body
				FROM StaticResource
				WHERE Description = :resourceName
				LIMIT 1
		];

		if (result.size() == 1)
		{
			return result[0];
		}
		else
		{
			return null;
		}
	}

	public static Map<Id, SObject> getContractedPrices(Id accountId, Id contractId)
	{
		List<SBQQ__ContractedPrice__c> result =
		[
				SELECT Id,
						SBQQ__Discount__c,
						SBQQ__Price__c,
						SBQQ__Product__c,
						SBQQ__Product__r.ProductCode
				FROM SBQQ__ContractedPrice__c
				WHERE SBQQ__Account__c = :accountId
				AND SBQQ__Contract__c = :contractId
				AND (SBQQ__ExpirationDate__c > TODAY OR SBQQ__ExpirationDate__c = null)
				AND SBQQ__EffectiveDate__c < TODAY
		];

		return UTIL_System.convertListToSingleMap(result, SBQQ__ContractedPrice__c.SBQQ__Product__c.getDescribe().getLocalName());
	}
}