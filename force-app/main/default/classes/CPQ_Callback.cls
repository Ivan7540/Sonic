global class CPQ_Callback implements SBQQ.CalculateCallback {
    global void Callback(String quoteJSON){
          quoteJSON = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);
          QuoteModel savedModel = (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
        
        //Convert json to object and get Id of quote to create platform event.
        //Platform events are needed to resume process after pricing is updated.
        List<CPQCalculateAPICallback__e> saveEvents = new List<CPQCalculateAPICallback__e>();
        saveEvents.add( new CPQCalculateAPICallback__e(QuoteId__c = savedModel.record.Id) );
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(saveEvents);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }//End For
    }
}