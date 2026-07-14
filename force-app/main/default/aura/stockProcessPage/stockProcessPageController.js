({
	handleCardClick : function(component, event, helper) {
        var selectedCard = event.currentTarget.dataset.value;
        console.log("selectedCard:", selectedCard);
        
        var selectedType;
        if(selectedCard == 'allocateBootStock'){
            selectedType = component.get('c.openAllocateBootStockModal');
        } else if(selectedCard == 'allocateRepairStock'){
            selectedType = component.get('c.openAllocateRepairStockModal');
        } else if(selectedCard == 'unallocateStock'){
            selectedType = component.get('c.openUnallocateStockModal');
        }
        
        $A.enqueueAction(selectedType);
	},
    
    openAllocateBootStockModal : function(component, event, helper){
        component.set('v.BootOrRepair', 'Boot');
        component.set('v.isOpen', true);
        
		var inputVariables = [{name:'BootOrRepair', type:'String', value:component.get("v.BootOrRepair")}]; 
        
        var flow = component.find("allocateFlowId");
        flow.startFlow("Work_Order_Unallocate_Stock", inputVariables);
    },
    
	openAllocateRepairStockModal : function(component, event, helper){
        component.set('v.BootOrRepair', 'Repair');
        component.set('v.isOpen', true);
        
		var inputVariables = [{name:'BootOrRepair', type:'String', value:component.get("v.BootOrRepair")}]; 
        
        var flow = component.find("allocateFlowId");
        flow.startFlow("Work_Order_Unallocate_Stock", inputVariables);
    },
    
	openUnallocateStockModal : function(component, event, helper){
        component.set('v.isOpen', true);
        
        var flow = component.find("allocateFlowId");
        flow.startFlow("Work_Order_Unallocate_Stock");
    },
    
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
        }
    }
})