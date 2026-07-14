/**
* Author	:	Swapnil Walse
* Date		:	25 April 2021
* Desc		:	DAL class for products
* 			:	
* 			:	 
* 				
**/

public class DAL_Product {

    //Default Pricebooks
    public static final String SSPriceBookName = 'Sureswipe Price Book';

	public static final String cancellationFeeProductCode = 'SS_CANCELLATION_FEES';
    public static final String installFeesProductCode = 'SS_INSTALL_TRAINING_FEE';
    public static final String minimumBillProductCode = 'SS_MINIMUM_BILL';
    //Bundles
    public static final String rateBundleProductCode = 'SS_RATE_BUNDLE';
    public static final String welcomeBoxProductCode = 'SS_WELCOME_BOX';
    //Rates
    public static final String domesticCreditCardFees = 'SS_DOMESTIC_CREDIT_CARD_FEES';
    public static final String sureswipeAcquiringDomesticCreditCardFees = 'SS_ACQUIRING_DOMESTIC_CREDIT_CARD_FEES';
    public static final String domesticDebitCardFees = 'SS_DOMESTIC_DEBIT_CARD_FEES';
    public static final String sureswipeAcquiringDomesticDebitCardFees = 'SS_ACQUIRING_DOMESTIC_DEBIT_CARD_FEES';
    public static final String internationalCreditCardFees = 'SS_INTERNATIONAL_CREDIT_CARD_FEES';
    public static final String sureswipeAcquiringInternationalCreditCardFees = 'SS_ACQUIRING_INTERNATIONAL_CREDIT_CARD_FEES';
    public static final String internationalDebitCardFees = 'SS_INTERNATIONAL_DEBIT_CARD_FEES';
    public static final String sureswipeAcquiringInternationalDebitCardFees = 'SS_ACQUIRING_INTERNATIONAL_DEBIT_CARD_FEES';
    public static final Set<String> masterpassFees = new  Set<String>{'SS_MASTERPASS_DEBIT_FEES', 'SS_MASTERPASS_CREDIT_FEES' };
    public static final String masterpasDebitFee = 'SS_MASTERPASS_DEBIT_FEES';
    public static final String masterpasCreditFee = 'SS_MASTERPASS_CREDIT_FEES';
    public static final String switchpayFees = 'SS_SWITCHPAY_FEES';
    public static final String monthlyConnectivityFee = 'SS_OUTRIGHT_PURCHASE_MONTHLY_CONNECTIVITY_FEE';
    public static final String moreTymeBankFee = 'SS_TYME_BANK_FEES';
    public static final String moreTymeTransactionFee = 'SS_TYME_BANK_PER_TRANSACTION_FEES';
    public static final String amexCardFee = 'SS_AMEX_FEES';
    //Rentals
    public static final String deviceRentalProductCode = 'SS_DEVICE_RENTAL';

    public static final List<String> calloutFeeProductCodes = new List<String>{'SS_CLASSIC_CALLOUT_FEE','SS_LITE_CALLOUT_FEE'};
    public static final String paperRollDeliverProductCode = 'SS_PAPER_ROLLS_DELIVERY';
    public static final String paperRollProductCode = 'SS_PAPER_ROLLS';
    public static final String unpaidDeibtOrderProductCode = 'SS_UNPAID_DEBIT_ORDER_FEE';
    public static final String reactivationFeeProductCode = 'SS_REACTIVATION_FEE';
    //Product Options
    public static final String bluetoothPrinterRentalPC =  'SS_BLUETOOTH_PRINTER_RENTAL';
    public static final String PEDStandPC = 'SS_PED_STAND';
    public static final String masterpassRentalPC = 'SS_MASTERPASS_RENTAL';
    public static final String switchpayRentalPC = 'SS_SWITCHPAY_RENTAL';
    public static final String SWITCHPAY = 'SS_SWITCHPAY';
    public static final String MORETYME_NET = 'SS_MORETYME_NET_RENTAL';
    public static final String MORETYME_GROSS = 'SS_MORETYME_GROSS_RENTAL';
    public static final String sp630PC = 'SS_SP_630';

    //ProductFamilies
    public static final String PRODUCT_FAMILY_LITE ='Lite';
    public static final String PRODUCT_FAMILY_EFT ='EFT';
    public static final String PRODUCT_FAMILY_INTEGRATED ='Integrated';

    public static Map<String, String> getContractTermMap(){
        Map<String, String> contractTermMap = new Map<String, String>();
        contractTermMap.put('SS_LITE_MONTH_TO_MONTH_BUNDLE', 'All in Month To Month');
        contractTermMap.put('SS_LITE_24_MONTH_BUNDLE', 'All in 24 Months');
        contractTermMap.put('SS_LITE_OUTRIGHT_PURCHASE_BUNDLE', 'Outright Purchase');

        contractTermMap.put('SS_CLASSIC_PLUS_WITH_POS_24_MONTH_BUNDLE', 'All in 24 Months');
        contractTermMap.put('SS_CLASSIC_PLUS_WITH_POS_OUTRIGHT_PURCHASE_BUNDLE', 'Outright Purchase');

        contractTermMap.put('SS_CLASSIC_PLUS_24_MONTH_BUNDLE', 'All in 24 Month');
        contractTermMap.put('SS_CLASSIC_PLUS_MONTH_TO_MONTH_BUNDLE', 'All in Month To Month');
        contractTermMap.put('SS_CLASSIC_PLUS_OUTRIGHT_PURCHASE_BUNDLE', 'Outright Purchase');

        contractTermMap.put('SS_CLASSIC_24_MONTH_BUNDLE', 'All in 24 Month');
        contractTermMap.put('SS_CLASSIC_MONTH_TO_MONTH_BUNDLE', 'All in Month To Month');
        contractTermMap.put('SS_CLASSIC_OUTRIGHT_PURCHASE_BUNDLE', 'Outright Purchase');
        contractTermMap.put('SS_HUMBLE_24_MONTH_BUNDLE', 'All in 24 Month');
        contractTermMap.put('SS_HUMBLE_MONTH_TO_MONTH_BUNDLE', 'All in Month To Month');
        contractTermMap.put('SS_GAAP_24_MONTH_BUNDLE', 'All in 24 Month');
        return contractTermMap;
    }
    public static Map<String, String> getCalloutFeeProductCodeMap(){
        Map<String, String> calloutFeeProductCodeMap = new Map<String, String>();
        calloutFeeProductCodeMap.put('SS_LITE_MONTH_TO_MONTH_BUNDLE', 'SS_LITE_CALLOUT_FEE');
        calloutFeeProductCodeMap.put('SS_LITE_24_MONTH_BUNDLE', 'SS_LITE_CALLOUT_FEE');
        calloutFeeProductCodeMap.put('SS_LITE_OUTRIGHT_PURCHASE_BUNDLE', 'SS_LITE_CALLOUT_FEE');

        calloutFeeProductCodeMap.put('SS_CLASSIC_PLUS_WITH_POS_24_MONTH_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_CLASSIC_PLUS_WITH_POS_OUTRIGHT_PURCHASE_BUNDLE', 'INCLUDED');

        calloutFeeProductCodeMap.put('SS_CLASSIC_PLUS_24_MONTH_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_CLASSIC_PLUS_MONTH_TO_MONTH_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_CLASSIC_PLUS_OUTRIGHT_PURCHASE_BUNDLE', 'INCLUDED');

        calloutFeeProductCodeMap.put('SS_CLASSIC_24_MONTH_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_CLASSIC_MONTH_TO_MONTH_BUNDLE', 'SS_CLASSIC_CALLOUT_FEE');
        calloutFeeProductCodeMap.put('SS_CLASSIC_OUTRIGHT_PURCHASE_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_HUMBLE_24_MONTH_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_HUMBLE_MONTH_TO_MONTH_BUNDLE', 'INCLUDED');
        calloutFeeProductCodeMap.put('SS_GAAP_24_MONTH_BUNDLE', 'INCLUDED');
        return calloutFeeProductCodeMap;
    }
    public static String getRentalProductCode(String deviceProductCode){
        return deviceProductCode + '_RENTAL';
    }

    public static List<Product2> getProducts(Map<String, BundleRate__mdt> productCodeMap)
    {
        return
        [
                SELECT  Id,
                        ProductCode,
                        Name
                FROM    Product2
                WHERE   ProductCode IN:productCodeMap.keySet()
        ];
    }
 
}