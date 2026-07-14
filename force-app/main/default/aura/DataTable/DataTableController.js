({
    doInit : function(cmp, event, helper) {
        cmp.set("v.columns", JSON.parse(cmp.get("v.columnsString")));
    }
})