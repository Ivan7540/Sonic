/**
* Author	:	Swapnil Walse
* Date		:	19 April 2021
* Desc		:	class to put signer names, used with Invocable methods to send Hellosign documents
* 			:	
* 			:	 
* 				
**/
global class HelloSignSignerName {
    @AuraEnabled @InvocableVariable global String role;
    @AuraEnabled @InvocableVariable global String name;
    @AuraEnabled @InvocableVariable global String emailAddress;
    
    public HelloSignSignerName(String role, String name, String emailAddress){
        this.role = role;
        this.name = name;
        this.emailAddress = emailAddress;
    }
    public HelloSignSignerName(){
        this.role = '';
        this.name = '';
        this.emailAddress = '';
    }
}