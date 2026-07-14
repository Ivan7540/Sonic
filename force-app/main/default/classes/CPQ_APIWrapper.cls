/**
* Author	:	Swapnil Walse
* Date		:	28 Feb 2021
* Desc		:	Wrapper class for all cpq methods. 
* 			:	
* 			:	 
* 				
**/
public without sharing class CPQ_APIWrapper {
    
    /** CPQ API Methods available for implementation **/
    public static final String CONTRACT_RENEWER = 'SBQQ.ContractManipulationAPI.ContractRenewer';
    public static final String CONTRACT_AMENDER = 'SBQQ.ContractManipulationAPI.ContractAmender';
    
    public static final String CONFIG_LOADER = 'SBQQ.ConfigAPI.ConfigLoader';//Implemented
    public static final String LOAD_RULE_EXECUTOR = 'SBQQ.ConfigAPI.LoadRuleExecutor';//Implemented
    public static final String CONFIGURATION_VALIDATOR = 'SBQQ.ConfigAPI.ConfigurationValidator';//Implemented
    
    public static final String PRODUCT_LOADER = 'SBQQ.ProductAPI.ProductLoader';//Implemented
    public static final String PRODUCT_SUGGESTER = 'SBQQ.ProductAPI.ProductSuggester';
    public static final String PRODUCT_SEARCHER = 'SBQQ.ProductAPI.ProductSearcher';
    
    public static final String QUOTE_READER = 'SBQQ.QuoteAPI.QuoteReader';//Implemented
    public static final String QUOTE_PRODUCT_ADDER = 'SBQQ.QuoteAPI.QuoteProductAdder';//Implemented
    public static final String QUOTE_CALCULATOR = 'SBQQ.QuoteAPI.QuoteCalculator';//Implemented
    public static final String QUOTE_SAVER = 'SBQQ.QuoteAPI.QuoteSaver';//Implemented
    public static final String QUOTE_DOCUMENT_SAVER = 'SBQQ.QuoteDocumentAPI.Save';//Implemented
    
    public class CalculatorContext { 
        public QuoteModel quote;
        public String callbackClass;
    }
    
    public static void calculateQuote(Id quoteId){
        // READ QUOTE 
        String quoteModelJSON = SBQQ.ServiceRouter.read(QUOTE_READER, quoteId); 
        QuoteModel quoteModelObj = (QuoteModel)JSON.deserialize(quoteModelJSON, QuoteModel.class); 
        //System.debug(LoggingLevel.WARN, 'quoteModelJSON: ' + quoteModelJSON); 
        //System.debug(LoggingLevel.WARN, 'quoteModelObj: ' + quoteModelObj); 
        
        // PREPARE CALCULATOR PAYLOAD 
        CalculatorContext calculatorPayload = new CalculatorContext(); 
        calculatorPayload.quote = quoteModelObj;
        // Specify name of class that implements the callback interface
        calculatorPayload.callbackClass = 'CPQ_Callback';
        
        // RUN CALCULATION
        String calculatedQuoteJSON = SBQQ.ServiceRouter.load(QUOTE_CALCULATOR, null, JSON.serialize(calculatorPayload)); 
        QuoteModel calculatedQuoteModel = (QuoteModel) JSON.deserialize(calculatedQuoteJSON, QuoteModel.class); 
        //System.debug(LoggingLevel.WARN, 'calculatedQuoteJSON: ' + calculatedQuoteJSON); 
        //System.debug(LoggingLevel.WARN, 'calculatedQuoteModel: ' + calculatedQuoteModel); 
    }
    
    public static QuoteModel getQuoteModel(Id quoteId) {
        String jsonResult = SBQQ.ServiceRouter.read(QUOTE_READER, (String) quoteId);
        QuoteModel quoteModel = (QuoteModel) JSON.deserialize(jsonResult, QuoteModel.class);
        
        System.debug(LoggingLevel.WARN, 'jsonResult: ' + jsonResult);
        System.debug(LoggingLevel.WARN, 'quoteModel: ' + quoteModel);
        
        return quoteModel;
    }
    
    public class ProductLoadContext {
        public Id pricebookId;
        public String currencyCode;
        public ProductLoadContext(){}
        public ProductLoadContext(Id pricebookId, String currencyCode) {
            this.pricebookId = pricebookId;
            this.currencyCode = currencyCode;
        }
    }
    
    public static ProductModel loadProduct(Id productId, Id pricebookId, String currencyCode) {
        ProductLoadContext productLoadPayload = new ProductLoadContext(pricebookId, currencyCode);
        String jsonResultProduct = SBQQ.ServiceRouter.load(PRODUCT_LOADER, (String) productId, JSON.serialize(productLoadPayload));
        ProductModel productModel = (ProductModel) JSON.deserialize(jsonResultProduct, ProductModel.class);
        
        return productModel;
    }
    /*not used currently
    public static ProductModel setOptionsConfigured(ProductModel productModel) {
        if(productModel.configuration != null){
            productModel.configuration.configured = true;
            productModel.configuration.configurationEntered = true;
            for(ConfigurationModel configModel : productModel.configuration.optionConfigurations) {
                configModel.configured = true;
                configModel.configurationEntered = true;
            }
            return productModel;
        }else{return productModel;}
    }*/
    
    public class ProductAddContext {
        public Boolean ignoreCalculate;
        public QuoteModel quote;
        public ProductModel[] products;
        public Integer groupKey;
        public ProductAddContext(){
            products = new List<ProductModel>();
        }
        public ProductAddContext(QuoteModel quote, ProductModel[] products){
            this(false, quote, products, null);
        }
        public ProductAddContext(Boolean ignoreCalculate, QuoteModel quote, ProductModel[] products) {
            this(ignoreCalculate, quote, products, null);
        }
        public ProductAddContext(Boolean ignoreCalculate, QuoteModel quote, ProductModel[] products, Integer groupKey){
            this.ignoreCalculate = ignoreCalculate;
            this.quote = quote;
            this.products = products;
            this.groupKey = groupKey;
        }
    }
    
    public static QuoteModel addProductsToQuote(QuoteModel initialQuoteModel, List<Id> productIds, Id pricebookId, String currencyCode, Boolean skipCalculate) {
        List<ProductModel> productModels = new List<ProductModel>();
        for(Id eachProductId : productIds){
            ProductModel productModel = loadProduct(eachProductId, pricebookId, currencyCode);
            productModels.add(productModel);
        }
        
        //Set product model as configured and configurationEntered
        //productModel = setOptionsConfigured(productModel);
        
        ProductAddContext productAddPayload = new ProductAddContext(skipCalculate, initialQuoteModel, productModels);
        return addProductsToQuote(productAddPayload);
    }
    
    public static QuoteModel addProductsToQuote(QuoteModel initialQuoteModel,
                                                List<ProductModel> productModels,
                                                Id pricebookId,
                                                String currencyCode,
                                                Boolean skipCalculate)
    {
        ProductAddContext productAddPayload = new ProductAddContext(skipCalculate, initialQuoteModel, productModels);
        return addProductsToQuote(productAddPayload);
    }
    
    public static QuoteModel addProductsToQuote(ProductAddContext productAddPayload) {
       
        String updatedQuoteJSON = SBQQ.ServiceRouter.load(QUOTE_PRODUCT_ADDER, null, JSON.serialize( productAddPayload));
        QuoteModel updatedQuoteModel = (QuoteModel) JSON.deserialize(updatedQuoteJSON, QuoteModel.class);
        
        return updatedQuoteModel;
    }
    
    public static QuoteModel saveQuote(QuoteModel quoteModel) {
        String savedQuoteJSON = SBQQ.ServiceRouter.save(QUOTE_SAVER, JSON.Serialize(quoteModel));

        QuoteModel updatedQuoteModel = (QuoteModel) JSON.deserialize(savedQuoteJSON, QuoteModel.class);
        return updatedQuoteModel;
    }
    
    public static QuoteModel amendContract(Id contractId) {
        String jsonResult = SBQQ.ServiceRouter.load(CONTRACT_AMENDER, (String) contractId, null);
        QuoteModel quoteModel = (QuoteModel) JSON.deserialize(jsonResult, QuoteModel.class);
        return quoteModel;
    }
    /* documentName: any name to be given to the document
     * paperSize: correct values are Default, Letter, Legal, A4, Defaults to Default.
     * outputFormat: pdf, word, Defaults to pdf.
     */
    public static String generateQuoteProposal(Id quoteId, String documentName, String paperSize, String outputFormat, Id templateId,String language){
        
        QuoteProposalModel context = new QuoteProposalModel();
        context.language = String.isBlank(language)? 'en_US': language;
        context.name = String.isBlank(documentName)? null:documentName;
        context.outputFormat = String.isBlank(outputFormat) ? 'pdf': outputFormat;
        context.paperSize = String.isBlank(paperSize) ? 'A4': paperSize;
        context.quoteId = quoteId;
        context.templateId = templateId;
        
        if(!Test.isRunningTest()) return SBQQ.ServiceRouter.save(QUOTE_DOCUMENT_SAVER, JSON.serialize(context));
        else return null;
    }
    
    /*Currently these mentods are not used
     * private class LoadRuleRunnerContext {
        private QuoteModel quote;
        private ProductModel parentProduct;
        private Integer lineItemKey;
        private List<String> dynamicOptionSkus;
        public ConfigurationModel configuration;
 
        public LoadRuleRunnerContext(
            QuoteModel quote,
            Integer lineItemKey,
            List<String> dynamicOptionSkus,
            ConfigurationModel configuration,
            ProductModel parentProduct) {
            
            this.quote = quote;
            this.parentProduct = parentProduct;
            this.lineItemKey = lineItemKey;
            this.dynamicOptionSkus = dynamicOptionSkus;
            this.configuration = configuration;
        }
    }
    
    public static ProductModel loadRuleExecutor(QuoteModel quoteModel, 
                                                 Id productId,
                                                 Integer lineItemKey,
                                                 List<String> dynamicOptionSkus,
                                                 ConfigurationModel configuration,
                                                 ProductModel parentProduct)
    {
        LoadRuleRunnerContext ctx = new LoadRuleRunnerContext(quoteModel,
                                                              lineItemKey,
                                                              dynamicOptionSkus,
                                                              configuration,
                                                              parentProduct);
        String productJSON = SBQQ.ServiceRouter.load(LOAD_RULE_EXECUTOR, productId, JSON.serialize(ctx));
        return (ProductModel) JSON.deserialize(productJSON, ProductModel.class);
    }
    private class ConfigLoadContext {
        private QuoteModel quote;
        private ProductModel parentProduct;
        
        private ConfigLoadContext(QuoteModel quote, ProductModel parentProduct) {
            this.quote = quote;
            this.parentProduct = parentProduct;
        }
    }
    public Static ProductModel configLoad(Id productId, QuoteModel quote, ProductModel parentProduct){
        ConfigLoadContext ctx = new ConfigLoadContext(quote, parentProduct);
        String productJSON = SBQQ.ServiceRouter.load(CONFIG_LOADER, productId, JSON.serialize(ctx));
        return (ProductModel) JSON.deserialize(productJSON, ProductModel.class);
    }
    private class ValidatorContext {
        private QuoteModel quote;
        private ConfigurationModel configuration;
        private String event;
        private String upgradedAssetId;
    
        public ValidatorContext(
            QuoteModel quote,
            ConfigurationModel configuration,
            String event,
            String upgradedAssetId) {
    
            this.quote = quote;
            this.configuration = configuration;
            this.event = event;
            this.upgradedAssetId = upgradedAssetId;
        }
    }
    
    public static ConfigurationModel validateConfig(Id productId,
                                                    QuoteModel quote,
                                                    ConfigurationModel configuration,
                                                    String event,
                                                    String upgradedAssetId) 
    {
        ValidatorContext ctx = new ValidatorContext(quote,
                                                    configuration,
                                                    event,
                                                    upgradedAssetId);
        
        String configJSON = SBQQ.ServiceRouter.load(CONFIGURATION_VALIDATOR, productId, JSON.serialize(ctx));
        
        return (ConfigurationModel) JSON.deserialize(configJSON, ConfigurationModel.class);
    }*/
}