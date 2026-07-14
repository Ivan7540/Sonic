/**
* Author	:	Swapnil Walse
* Date		:	19 April 2021
* Desc		:	
* 			:	
* 			:	 
* 				
**/
public class SigningRequestInvocable {
    @InvocableMethod(label='Send Signing Request' category='HelloSign Custom')
    public static List<String> sendSigningRequest(List<HelloSignRequestParams> params){
        
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
                try{
                    response = HelloSignInterface.sendSigningRequest(eachParam.originObjectId,
                                                                     eachParam.reqTitle,
                                                                     eachParam.reqSubject,
                                                                     eachParam.reqMessage,
                                                                     eachParam.documentIds,
                                                                     eachParam.signerNames,
                                                                     eachParam.ccEmail,
                                                                     eachParam.sendImmediately,
                                                                     eachParam.isTestMode);
                    responses.add('Success');
                }catch(Exception e){
                    responses.add('Error: ' + e.getMessage());
                }
            }
        }catch(Exception e){
            responses.add(e.getMessage());
        }
        return responses;
    }
}