public class SignatureController {
    private final HellosignSettings__mdt HSSettings;
    //private final String templateId;
    private final SBQQ__Quote__c currentQuote;
    private SBQQ__QuoteLine__c[] currentQuoteLineList;
    private List<AccountContactRelation> contactRelations;
    
    public SignatureController(){
        //templateId = ApexPages.currentPage().getParameters().get('tid');//for future use
        SBQQ__Quote__c[] currentQuoteList = [SELECT Id,
                                             SBQQ__Account__c,
                                             SBQQ__Type__c,
                                             SBQQ__PrimaryContact__c
                                             FROM SBQQ__Quote__c 
                                             WHERE Id = :ApexPages.currentPage().getParameters().get('qid')];

        HSSettings = [Select SendToManager__c,
                      ContactRoles__c
                      From HellosignSettings__mdt
                      Where DeveloperName = 'SureswipeSettings'
                      Limit 1];

        if(currentQuoteList.size() > 0){
            currentQuote = currentQuoteList[0];
            getContactRelations(currentQuote.SBQQ__Account__c);
        }
    }
    public void getContactRelations(Id accountId){
        
        //For amendments, only primary contact is emailed, for New Business, all Directors need to sign
        if(currentQuote.SBQQ__Type__c != 'Amendment'){
            List<String> roles = HSSettings.ContactRoles__c.split(',');

            String queryString = 'Select Id, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Name, Roles From AccountContactRelation Where AccountId = \'';
            queryString = queryString + accountId + '\' ';
            queryString = queryString + 'and Roles includes(\'' + String.join(roles, '\',\'') + '\')';
            system.debug('queryString: ' + queryString);
            contactRelations = Database.query(queryString);
        }else{
            contactRelations = [
                Select Id,
                Contact.FirstName,
                Contact.LastName,
                Contact.Email,
                Contact.Name,
                Roles
                From AccountContactRelation 
                Where AccountId = :accountId
                and ContactId = :currentQuote.SBQQ__PrimaryContact__c
            ];
        }
    }
    
    public SBQQ__Quote__c  getQuote(){
        return currentQuote;
    }
    
    public List<String> getInitialSignatories(){
        
        List<String> signatories = new List<String>();
        Integer companySignatories;
        if(HSSettings.SendToManager__c) companySignatories = 2;
        else companySignatories = 1;

        for(Integer i = 0; i < contactRelations.size() + companySignatories; i++){
            signatories.add('[initial|req|signer' + i + ']');
        }
        return signatories;
    }
    
    public List<String> getClientSignatories(){
        List<String> signatories = new List<String>();
        Integer companySignatories;
        if(HSSettings.SendToManager__c) companySignatories = 2;
        else companySignatories = 1;
        for(Integer i = companySignatories; i < contactRelations.size() + companySignatories; i++){
            signatories.add('signer' + i);
        }
        return signatories;
    }
    public List<String> getCompanySignatories(){
        List<String> signatories = new List<String>();
        signatories.add('signer0');
        if(HSSettings.SendToManager__c)
            signatories.add('signer1');
        return signatories;
    }
    //flow cannot query multivalue picklists so invocable method to get contacts
    @InvocableMethod(label='Get Hellosign Signers')
    public static List<List<Contact>> getContacts(List<Id> accountIds){
        HellosignSettings__mdt HSSettings = [Select SendToManager__c,
                                                ContactRoles__c
                                                From HellosignSettings__mdt
                                                Where DeveloperName = 'SureswipeSettings'
                                                Limit 1];
        List<String> roles = HSSettings.ContactRoles__c.split(',');
        List<List<Contact>> contactsList = new List<List<Contact>>();
        for(Id accountId : accountIds){
            String queryString = 'Select Id, ContactId, Roles From AccountContactRelation Where AccountId = \'' + accountId + '\' ';
            queryString = queryString + 'and Roles includes(\'' + String.join(roles, '\',\'') + '\') ORDER BY CreatedDate ASC';
            Set<Id> contactIds = new  Set<Id>();
            List<AccountContactRelation> relationsList = Database.query(queryString);
            for(AccountContactRelation eachRelation : relationsList){
                contactIds.add(eachRelation.ContactId);
            }
            contactsList.add([Select Id, Name, Email From Contact Where Id in :contactIds]);
        }
        return contactsList; 
    }
}