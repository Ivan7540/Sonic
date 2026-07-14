({
	handleUploadFinished : function(cmp, event) {
		// Get the list of uploaded files
        var uploadedFiles = event.getParam("files");

        // Get the file name
        uploadedFiles.forEach(function(file){
            cmp.set("v.contentDocumentId", file.documentId);
            cmp.set("v.documentName", file.name);
            cmp.set("v.contentVersionId", file.contentVersionId);
            console.log(cmp.get("v.contentDocumentId"));
            console.log(cmp.get("v.documentName"));
            console.log(cmp.get("v.contentVersionId"));
        });
	}
})