({
	doInit : function(cmp, event) {
		var action = cmp.get("c.queryDealItems");
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        var saleType = cmp.get("v.saleType");
                 var thirdParty = cmp.get("v.thirdParty");

        if(saleType =='Outright Purchase' || thirdParty =='Humble' || thirdParty =='GAAP' ){
            cmp.set("v.disableAdd", true);
        }else{
            cmp.set("v.disableAdd", false);
            }
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var dealLines = a.getReturnValue();
                cmp.set("v.dealLines", dealLines);
                var activeSections = [];
                for(var i of dealLines){
                    activeSections.push(i.Id);
                }cmp.set("v.activeSections", activeSections);
                console.log(JSON.stringify(dealLines));
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
	},
    deleteLine: function(cmp, event){
        var action = cmp.get("c.deleteDealLine");
        action.setParams({
            recordId : event.getSource().get("v.value")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Line deleted successfully",
                        "type": "success"
                    });
                    toastEvent.fire();
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    }
})