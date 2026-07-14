/**
* Author	:	Swapnil Walse
* Date		:	28 Feb 2021
* Desc		:	callout class for calculate quote
* 			:	
* 			:	 
* 				
**/

@RestResource(urlMapping='/SonicCPQ/CalculateQuote')
global class CPQ_APICalculateQuoteCallout {
	@HttpPost
    global static List<String> calculateQuote(List<Id>quoteIds){
        List<String> returnString = new List<String>();
        for(Id quoteId : quoteIds){
            CPQ_APIWrapper.calculateQuote(quoteId);
            returnString.add('Submitted');
        }
        return returnString;
    }
}