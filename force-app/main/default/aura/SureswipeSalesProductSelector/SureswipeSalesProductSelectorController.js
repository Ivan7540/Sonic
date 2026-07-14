({
	doInit : function(cmp, event, helper) {
		helper.doInit(cmp, event);
	},
	handleOnChange : function(cmp, event, helper){
		var fieldName = event.getSource().get("v.fieldName");
		var fieldValue = event.getParam("value") == undefined? event.getParam("checked"): event.getParam("value");
		helper.setFieldParams(cmp, fieldName, fieldValue);
		console.log("FieldName: " + fieldName + " FieldValue: " + fieldValue);
	 	var product = cmp.get('v.productName');
		var device = cmp.get('v.deviceName');
		let termField = cmp.find('ContractTerm');
		if(product =='ClassicPlus' && device =='SS_SP_630')
		{
		    cmp.set('v.contractTerm', '24Month');
		    termField.set('v.value', '24Month');
        }
	},
	onSuccess : function(cmp, event, helper){
		var updatedRecord = event.getParam("response");
		cmp.set("v.dealItemId", updatedRecord.id);
		cmp.set("v.showEditor", false);
	},
	handleSubmit : function (cmp, event, helper){
		event.preventDefault();
		var fields = event.getParam('fields');
		helper.calculateStaticResourceName(cmp, event, fields);
		if(!cmp.get("v.preventSave")){
			fields.StaticResourceName__c = cmp.get("v.staticResourceName");
			if(fields.ContractTerm__c == 'None' || fields.Device__c != 'SS_SP_630'){
				fields.VAS__c = null;
				fields.MasterpassQuantity__c = null;
				fields.SwitchpayQuantity__c = null;
			}
			if((!$A.util.isEmpty(fields.VAS__c)) && (fields.VAS__c.includes('Gift') || fields.VAS__c.includes('Loyalty'))){
				//Nothing yet
			}else{
				fields.GiftLoyaltyPaymentType__c = null;
				fields.CardDesignType__c = null;
				fields.AdditionalBrandedCards__c = null;
				fields.AdditionalEnrolmentForms__c = null;
			}
			cmp.find('recordEditForm').submit(fields);
		}
	},
	handleOnLoad : function(cmp, event, helper){
		if(!cmp.get("v.onLoadCalled")){ //handle load is call many times, we need only once
			var recUi = event.getParam("recordUi");
			//console.log(recUi.record.id);
			//console.log(recUi.record.fields["Product__c"].displayValue);

			var fieldNames = Object.keys(recUi.record.fields);
			for(var fieldName in fieldNames){
				helper.setFieldParams(cmp, fieldNames[fieldName], recUi.record.fields[fieldNames[fieldName]].value);
			}
			cmp.set("v.onLoadCalled", true);
		}
	}
})