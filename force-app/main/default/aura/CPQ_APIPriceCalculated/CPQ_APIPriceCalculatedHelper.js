({
    // Client-side function that invokes the subscribe method on the
    // empApi component.
    subscribe : function(component, event, helper) {
        // Get the empApi component.
        const empApi = component.find("empApi");
        // Get the channel from the input box.
        var channel = "/event/CPQCalculateAPICallback__e";
        const replayId = -1;
        
        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console.
        const callback = function (message) {
            console.log("Event Received : " + JSON.stringify(message));
            var msg = JSON.stringify(message.data.payload.Message__c);
            console.log("Event Received : " + msg);
            if(message.data.payload.QuoteId__c == component.get("v.quoteId")){
                component.set("v.calculationDone", true);
                //unsubscribe now
                helper.unsubscribe(component, event, helper);
            }
        };
        
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, callback).then(function(newSubscription) {
            console.log("Subscribed to channel " + channel);
            component.set("v.subscription", newSubscription);
        });
    },
    
    // Client-side function that invokes the unsubscribe method on the
    // empApi component.
    unsubscribe : function(component, event, helper) {
        // Get the empApi component.
        const empApi = component.find("empApi");
        // Get the channel from the subscription object.
        const channel = component.get("v.subscription").channel;
        
        // Callback function to be passed in the subscribe call.
        const callback = function (message) {
            console.log("Unsubscribed from channel " + channel);
        };
        
        // Unsubscribe from the channel using the sub object.
        empApi.unsubscribe(component.get("v.subscription"), callback);
    },
    handleChange : function(component, event, helper) {
        // When an option is selected, navigate to the next screen
        //var response = event.getSource().getLocalId();
        //component.set("v.value", response);
        var navigate = component.get("v.navigateFlow");
        navigate("NEXT");
    }
})