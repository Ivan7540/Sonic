public class GetDocumentBodyInvocable {
    @InvocableMethod
    public static List<String> getDocumentBody(List<Id> documentIds) {
        List<String> returnString = new List<String>();
        for(Id eachId : documentIds){
            if(String.valueOf(eachId.getSObjectType()) == 'Document') {
                try{
                    returnString.add(EncodingUtil.base64Encode([Select Id, Body From Document Where Id = :eachId].Body));
                }catch(Exception e){
                    returnString.add(e.getMessage());
                }
            }else{
                returnString.add('Object not yet supported!');
            }
        }
        return returnString;
    }
}