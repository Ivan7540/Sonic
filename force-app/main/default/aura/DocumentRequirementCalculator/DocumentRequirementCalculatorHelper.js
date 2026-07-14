({
	doInit : function(cmp, event){
        var action = cmp.get("c.getDocuments");
        action.setParams({
            recordId : cmp.get("v.recordId"),
            sObjectName : cmp.get("v.sObjectName"),
            requirementType: cmp.get("v.requirementType"),
            businessType : cmp.get("v.businessType"),
            hideDocuments : cmp.get("v.hideDocuments")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                cmp.set("v.documentRequirement", a.getReturnValue());
                console.log(JSON.stringify(a.getReturnValue()));
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    },
    deleteFile : function(cmp, event, helper){
        var action = cmp.get("c.deleteDocument");
        action.setParams({
            documentId : event.getSource().get("v.name")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "File deleted successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                this.doInit(cmp, event, helper);
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    },
    submitToContracts : function(cmp, event){
        var action = cmp.get("c.submitToContractsTeam");
        action.setParams({
            recordId : cmp.get("v.recordId"),
            sObjectName : cmp.get("v.sObjectName")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Submitted successfully!",
                    "type": "success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    },
    onCheckboxCommit : function(cmp, event){
        var checkButtons = cmp.find("documentSelector");
        var concatenatedIds = "";
        
        if(Array.isArray(checkButtons)){
            for(var x in checkButtons){
                if(checkButtons[x].get("v.checked")){
                    concatenatedIds = concatenatedIds + checkButtons[x].get("v.name") + ',';
                }
            }
        }else{
            if(checkButtons.get("v.checked")){
                concatenatedIds = concatenatedIds + checkButtons.get("v.name");
            }
        }
        cmp.set("v.selectedFiles", concatenatedIds.slice(0, -1));
        console.log(cmp.get("v.selectedFiles"));
    }
})