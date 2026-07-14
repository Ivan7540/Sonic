({
    doInit : function(component, event, helper) {
      const quoteId = component.get('v.recordId');
      const action = component.get('c.getQuoteLines2');
      action.setParams({ quoteId });
      action.setCallback(this, function(response) {
        console.log({
            state: response.getState(),
            value: response.getReturnValue(),
            errors: response.getError()
        });
        if (response.getState() === 'SUCCESS') {
          const payload = response.getReturnValue();
          component.set('v.quoteLinesGroup', payload['groups']);
          component.set('v.rates', payload['rates']);
          component.set('v.onceOffAmount', payload['onceOffAmount']);
          component.set('v.monthlyAmount', payload['monthlyAmount']);
        } else if (response.getState() === 'ERROR') {
          const errors = response.getError();
          alert(errors[0].message);
        }
      });
      $A.enqueueAction(action);
    }
})