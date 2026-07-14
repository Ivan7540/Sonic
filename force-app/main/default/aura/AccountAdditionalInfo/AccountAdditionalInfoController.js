({
    recordUpdate : function(component, event, helper) {
        let accId = component.get('v.opportunity.AccountId');

        let action = component.get('c.getRelated');        
        action.setParams({accountId : accId});
        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.accountRelation', response.getReturnValue());
            } else if (state === 'ERROR') {
                let errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})