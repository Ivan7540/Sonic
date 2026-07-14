public class LCC_FilePreviewAndSelector {
    @AuraEnabled
    public static List<Id> getDocumentIds(String recordId){
        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentDocumentLink> cdls = [Select Id,
                                          ContentDocumentId,
                                          LinkedEntityId
                                          From ContentDocumentLink
                                          Where ContentDocumentId = :recordId
                                          OR LinkedEntityId = :recordId
                                         ];
        for(ContentDocumentLink cdl : cdls){
            contentDocumentIDs.add(cdl.ContentDocumentId);
        }
        return new List<Id>(contentDocumentIds);
    }
}