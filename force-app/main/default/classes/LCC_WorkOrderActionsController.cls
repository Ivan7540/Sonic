public class LCC_WorkOrderActionsController {
    @AuraEnabled
    public static List<WorkOrderAction__c> getWorkOrderActions(Id recordId){
        WorkOrder__c thisOrder = [Select Id, Status__c from WorkOrder__c where Id = :recordId];
        
        return [SELECT Id,
                Name,
                WorkOrder__c, 
                Complete__c, 
                CompletionAction__c, 
                MetadataReference__c, 
                NewStatus__c, 
                DueDate__c, 
                HoursDue__c,
                CompletingUser__c, 
                TimeCompleted__c, 
                OrdinalNumber__c 
                FROM WorkOrderAction__c
                Where WorkOrder__c = :recordId
                //and NewStatus__c = :thisOrder.Status__c
                order by OrdinalNumber__c asc];
    }
    @AuraEnabled
    public static string updateCurrentAction(Id recordId){
        WorkOrder__c thisOrder = [Select Id, Status__c from WorkOrder__c where Id = :recordId];
        
        List<WorkOrderAction__c> actions = [SELECT Id,
                                            Name,
                                            WorkOrder__c, 
                                            Complete__c, 
                                            CompletionAction__c, 
                                            MetadataReference__c, 
                                            NewStatus__c, 
                                            DueDate__c, 
                                            HoursDue__c,
                                            CompletingUser__c, 
                                            TimeCompleted__c, 
                                            OrdinalNumber__c 
                                            FROM WorkOrderAction__c
                                            Where WorkOrder__c = :recordId
                                            //and NewStatus__c = :thisOrder.Status__c
                                            and Complete__c = false
                                            order by OrdinalNumber__c asc];
        if(actions.isEmpty()){
            throw new AuraHandledException('No Items to update!');
        }else{
            WorkOrderAction__c actionToUpdate = actions[0];
            actionToUpdate.Complete__c = true;
            try{
            	update actionToUpdate;
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return 'success';
    }
}