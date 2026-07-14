/**
* Author	:	Swapnil Walse
* Date		:	3 April 2021
* Desc		:	Class to create a product model and save it in static resource
* 			:	
* 			:	 
* 				
**/
public class CPQ_CreateProductModelStaticResource {
    public class requestParams{
        @InvocableVariable public String resourceName;
        @InvocableVariable public Id quoteId;
    }
    
    @InvocableMethod
    public static List<Boolean> createStaticResourceInvocable(List<requestParams> inputs){
        List<Boolean> resultFlag = new List<Boolean>();
        for(requestParams eachParam : inputs){
            MetadataService.SaveResult result = createStaticResource(eachParam.resourceName, eachParam.quoteId);
            if(result == null){
                resultFlag.add(false);
            }else
                resultFlag.add(result.success);
        }
        return resultFlag;
    }
    public static MetadataService.SaveResult createStaticResource(String resourceName, Id quoteId){        
        //Create Metadata Service
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = fetchUserSessionId();
        MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
        List<MetadataService.SaveResult> results;
        //Read Quote Model
        QuoteModel quoteModel = CPQ_APIWrapper.getQuoteModel(quoteId);
        
        //Create Package
        
        staticResource.contentType = 'text';
        staticResource.cacheControl = 'public';
        staticResource.description = resourceName;
        staticResource.content = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(quoteModel)));
        //Query Static resource and check if already exists
        List<StaticResource> productModelStaticResources = [SELECT Id,
                                                            Name
                                                            FROM StaticResource
                                                            WHERE Description = :resourceName 
                                                            LIMIT 1];
        if(productModelStaticResources.isEmpty()){
            //Create New
            staticResource.fullName = 'QM_' + DateTime.now().format('yyyyMMddhhmmss');
            results = service.createMetadata( new MetadataService.Metadata[] { staticResource });
            system.debug('Result: ' + results);     

        }else{
            //Update Existing
            staticResource.fullName = productModelStaticResources[0].Name;
            results = service.updateMetadata( new MetadataService.Metadata[] { staticResource });
            system.debug('Result: ' + results);
        }
        if(results == null){
            return null;
        }else
            return results[0];
    }
    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIDVF;
        String vfContent;
        if(!Test.isRunningTest()){
            vfContent = reportPage.getContent().toString();
        }else{
            vfContent = 'Start_Of_Session_IdDummyEnd_Of_Session_Id';
        }
         
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
        Integer endP = vfContent.indexOf('End_Of_Session_Id');
        
        sessionId = vfContent.substring(startP, endP);
        
        return sessionId;
    }
}