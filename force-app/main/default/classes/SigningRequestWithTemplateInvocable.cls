/**
* Author	:	Swapnil Walse
* Date		:	19 April 2021
* Desc		:	
* 			:	
* 			:	 
* 				
**/
global class SigningRequestWithTemplateInvocable {
    @InvocableMethod(label='Send Signing Request With Template' category='HelloSign Custom')
    public static List<String> sendSigningRequestWithTemplate(List<HelloSignRequestParams> params){
        
        List<String> responses = new List<String>();
        HelloSign.ServiceObjects.SignatureRequestResponse response;
        try{
            for(HelloSignRequestParams eachParam : params){
                Map<String, Map<String, String>> signerNames = new Map<String, Map<String, String>>();
                for(HelloSignSignerName eachName : eachParam.signerNames){
                    Map<String, String> eachMap = new Map<String, String>();
                    eachMap.put(eachName.name, eachName.emailaddress);
                    signerNames.put(eachName.role, eachMap);
                }
                response = HelloSignInterface.sendSigningRequestWithTemplate(eachParam.sfdcTemplateId,
                                                                             eachParam.originObjectId,
                                                                             signerNames,
                                                                             eachParam.sendImmediately,
                                                                             eachParam.isTestMode);
                responses.add('Success');
            }
        }catch(Exception e){
            responses.add(e.getMessage());
        }
        return responses;
    }
}