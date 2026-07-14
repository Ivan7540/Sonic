/**
* Author	:	Swapnil Walse
* Date		:	19 April 2021
* Desc		:	
* 			:	
* 			:	 
* 				
**/
global class HelloSignRecentSigningRequest {
    global class responseParams{
        @InvocableVariable global String sigReqId;
        @InvocableVariable global Boolean isComplete;
        @InvocableVariable global Boolean isDeclined;
        @InvocableVariable global Boolean hasError;
    }
    
    @InvocableMethod(label='Get Recent Signing Request' category='Remote Signing')
    public static List<responseParams> getRecentSigningRequestInvocable(List<Id> sigReqOrObjectIds){
        
        List<responseParams> responses = new List<responseParams>();
        for(Id eachId : sigReqOrObjectIds){
            responseParams eachResponse = new responseParams();
            HelloSign.ServiceObjects.SignatureRequestResponse response = new HelloSign.ServiceObjects.SignatureRequestResponse();
            response = HelloSignInterface.getRecentSigningRequest(eachId);
            if(response != null){
                eachResponse.isComplete = response.signature_request.is_complete;
                eachResponse.sigReqId = response.signature_request.signature_request_id;
                eachResponse.isDeclined = response.signature_request.is_declined;
                eachResponse.hasError = response.signature_request.has_error;
            }
        }
        return responses;
    }
}