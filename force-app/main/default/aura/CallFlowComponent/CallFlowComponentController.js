({
    doInit : function (cmp, event, helper) {
        //Nothing to do for now
    },
    handleClick1 : function (cmp, event, helper) {
        // Find the component whose aura:id is "flowId"
        var flow = cmp.find("flowId");
        console.log("In Handle Click");
        // In that component, start your flow. Reference the flow's Unique Name.
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : cmp.get("v.recordId")
            }
        ];
        flow.startFlow(cmp.get("v.flowAPIName"), inputVariables);
    },
})