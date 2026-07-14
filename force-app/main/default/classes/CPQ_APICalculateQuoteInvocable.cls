public class CPQ_APICalculateQuoteInvocable {
    @InvocableMethod()
    public static List<String> calculateQuote(List<Id> quoteIds) {
        List<String> returnString = new List<String>();
        for(Id quoteId : quoteIds){
            CPQ_APIWrapper.calculateQuote(quoteId);
            returnString.add('Submitted');
        }
        return returnString;
    }
}