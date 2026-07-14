/**
 * Created by JurgitaG on 7/19/2021.
 */

({

    getOpportunityType: function(cmp, event){
        var action = cmp.get("c.getOpportunityType");
        action.setParams({
            processId : cmp.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                cmp.set("v.opportunityType", a.getReturnValue());
                console.log(JSON.stringify(a.getReturnValue()));
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    },
    getOpportunityLines: function(cmp, event){
        var action = cmp.get("c.getQuoteLines");
        action.setParams({
            processId : cmp.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                cmp.set("v.opportunityLines", a.getReturnValue());
                console.log(JSON.stringify(a.getReturnValue()));
            }else{
                console.log(a.getState());
            }
        });
        //Now enqueue action
        $A.enqueueAction(action);
    },
});