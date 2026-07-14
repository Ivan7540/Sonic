/**
* Author	:	Swapnil Walse
* Date		:	13 April 2021
* Desc		:	invocable method that can be used to create content version in flows
* 			:	
* 			:	 
* 				
**/
public class CreateContentVersioninvocable {
    @InvocableMethod(label = 'Create ContentVersion/Files')
    public static FlowOutput[] createFile(FlowInput[] inputs) {

        ContentVersion[] filesToCreate = new ContentVersion[]{};

        for(FlowInput input : inputs) {
            ContentVersion file = new ContentVersion();
            String data;
            if(input.fileExtension == 'SNOTE') {
                data = input.data.escapeXML().replace('\r\n', '<br>').replace('\r', '<br>').replace('\n', '<br>').replace('&apos;', '&#39;');
            } else {
                data = input.data;
            }
            
            file.Title = input.title;
            file.PathOnClient = file.Title + '.' + input.fileExtension;
            file.VersionData = EncodingUtil.base64Decode(data);
            file.DocumentType_fileupload__c = input.documentType;
            if(String.isNotEmpty(input.parentId)) {
                file.FirstPublishLocationId = input.parentId;
            }
            filesToCreate.add(file);
        }

        insert filesToCreate;
        FlowOutput[] outputs = new FlowOutput[]{};
        
        for(ContentVersion cv : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :filesToCreate]) {
            FlowOutput output = new FlowOutput();
            output.contentDocumentId = cv.ContentDocumentId;
            outputs.add(output);
        }
        
        return outputs;
    }
    
    public class FlowInput {
        @InvocableVariable(label='File Title' required='true')
        public String title;

        @InvocableVariable(label='File Data' required='true')
        public String data;

        @InvocableVariable(label='File Extension' required='true')
        public String fileExtension;

        @InvocableVariable(label='Related Record ID')
        public String parentId;

        @InvocableVariable(label='Document Type' description='Type of document, picklist restricted' required='false')
        public String documentType;
    }

    public class FlowOutput {
        @InvocableVariable(label='ContentDocument Id')
        public String contentDocumentId;
    }

}