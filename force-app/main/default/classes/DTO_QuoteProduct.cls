/**
 * Created by JurgitaG on 3/17/2021.
 *
 * Data transfer object which contains fields for Rate, Rebate, Product Bundle
 */

public with sharing class DTO_QuoteProduct
{
	@AuraEnabled public String dealLineId;
	@AuraEnabled public String product;
	@AuraEnabled public String device;
	@AuraEnabled public String deviceType;
	@AuraEnabled public String productId;
	@AuraEnabled public String productCode;
	@AuraEnabled public Integer quantity;
	@AuraEnabled public Integer numberOfMonths;
	@AuraEnabled public Decimal discount;
	@AuraEnabled public Decimal discountAmount;
	@AuraEnabled public Integer maxQuantity;
	@AuraEnabled public Decimal ratePercentage;
	@AuraEnabled public Decimal transactionFee;
	@AuraEnabled public Decimal cardSplit;
	@AuraEnabled public String contractTerm;
	@AuraEnabled public String paymentServer;
	@AuraEnabled public Integer paymentServerQuantity;
	@AuraEnabled public Integer bluetoothPrinterQuantity;
	@AuraEnabled public Integer masterpassQuantity;
	@AuraEnabled public Integer switchpayQuantity;
	@AuraEnabled public Integer moreTymeNetQuantity;
	@AuraEnabled public Integer moreTymeGrossQuantity;
	@AuraEnabled public Integer amexQuantity;
	@AuraEnabled public Integer acquiringQuantity;
	@AuraEnabled public Boolean simCarsIncluded;
	@AuraEnabled public Boolean smeDeviceSupportIncluded;
	@AuraEnabled public Integer includeDocking;
	@AuraEnabled public Integer includePaperRolls;
	@AuraEnabled public Integer includePED;

	@AuraEnabled public Integer giftQuantity;
	@AuraEnabled public Integer giftDevicesQuantity;
	@AuraEnabled public Integer loyaltyDevicesQuantity;
	@AuraEnabled public Integer bespokeQuantity;
	@AuraEnabled public Integer catalogueQuantity;
	@AuraEnabled public String giftLoyaltyPaymentType;

	@AuraEnabled public Integer PEDQuantity;
	@AuraEnabled public String staticResourceName;
	@AuraEnabled public String rebatedProduct;
	@AuraEnabled public String rebateMotivation;
	@AuraEnabled public Decimal lineDiscount;


	public DTO_QuoteProduct()
	{
	}

	public DTO_QuoteProduct(String product, String device, String contractTerm, Integer quantity)
	{
		this.product = product;
		this.device = device;
		this.contractTerm = contractTerm;
		this.quantity = quantity;
	}

	public DTO_QuoteProduct(String productId, String productName, Decimal ratePercentage, Decimal cardSplit)
	{
		this.productId = productId;
		this.product = productName;
		this.ratePercentage = ratePercentage;
		this.cardSplit = cardSplit;
	}

	public DTO_QuoteProduct(String product, String device, Integer maxQuantity, Integer quantity, Integer numberOfMonths, Decimal discount, Decimal discountAmount)
	{
		this.product = product;
		this.device = device;
		this.quantity = quantity;
		this.maxQuantity = maxQuantity;
		this.numberOfMonths = numberOfMonths;
		this.discount = discount;
		this.discountAmount = discountAmount;
	}

	public  DTO_Quote parse(String json)
	{
		return (DTO_Quote) System.JSON.deserialize(json, DTO_Quote.class);
	}
}