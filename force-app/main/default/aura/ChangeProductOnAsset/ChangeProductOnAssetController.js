({
    init : function (component) {
      // call apex to fetch selectable products
        console.log('v.productFamily: ', component.get('v.productFamily'));
      var action = component.get("c.getSelectableProducts");
        action.setParams({
            "productFamily" : component.get('v.productFamily') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                console.log('a.getReturnValue:', a.getReturnValue());
                
                var productArr = [];
                productArr.push({
                    value: null, label: '--None--'
                });
                
                for(var i = 0; i < a.getReturnValue().length; i++){
                    productArr.push({
                       value: a.getReturnValue()[i].Id, label: a.getReturnValue()[i].Name
                    });
                }
                component.set('v.sObjList', productArr);
                console.log('v.sObjList', v.sObjList);
            }
        });
        $A.enqueueAction(action);
   },
    
    handleChange: function (cmp, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = cmp.get("v.selectedValue");
        console.log('selectedOptionValue: ', selectedOptionValue);
        //alert("Option selected with value: '" + selectedOptionValue + "'");
		cmp.set('v.selectedProductId', selectedOptionValue);
    }
})