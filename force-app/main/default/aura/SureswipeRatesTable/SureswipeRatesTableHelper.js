({
    doInit : function(cmp, event) {
        var action = cmp.get("c.getRates");
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                cmp.set("v.ratesList", a.getReturnValue());
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    }
})