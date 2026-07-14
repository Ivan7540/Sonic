/**
 * Used to instantiate and execute Trigger Handlers associated with SObjects.
 */
public class FACTORY_TriggerHandler
{
	public enum TriggerHandler
	{
		TH_LEAD,
		TH_WORKORDER,
		TH_QUOTE,
		TH_OPPORTUNITY,
		TH_CONTRACT,
		TH_CASE,
        TH_DEAL,
		TH_DEALLINE
	}

	public class TriggerException extends Exception
	{
	}

	//This entry
	public class TriggerStackEntry
	{
		public INT_Trigger handler;
		public Boolean isBefore;
		public DAL_BaseObject.DatabaseOperation operation;
		public TriggerHandler handlerEnum;

		public TriggerStackEntry(INT_Trigger triggerHandler, TriggerHandler handlerEnum)
		{
			handler = triggerHandler;
			isBefore = Trigger.isBefore;
			operation = DAL_BaseObject.getTriggerDBOperation();
			this.handlerEnum = handlerEnum;
		}
	}

	//This static stack contains (for the current context) the stack of trigger calls
	private static UTIL_Stack.ObjectStack triggerStack = new UTIL_Stack.ObjectStack();


	private static final Map<TriggerHandler, System.Type> REGISTERED_HANDLER = new Map<TriggerHandler, System.Type>();
	static
	{
		REGISTERED_HANDLER.put(TriggerHandler.TH_LEAD, LeadHandler.class);
		REGISTERED_HANDLER.put(TriggerHandler.TH_WORKORDER, WorkOrderHandler.class);
		REGISTERED_HANDLER.put(TriggerHandler.TH_QUOTE, QuoteHandler.class);
		REGISTERED_HANDLER.put(TriggerHandler.TH_OPPORTUNITY, OpportunityHandler.class);
		REGISTERED_HANDLER.put(TriggerHandler.TH_CONTRACT, ContractHandler.class);
		REGISTERED_HANDLER.put(TriggerHandler.TH_CASE, CaseHandler.class);
        REGISTERED_HANDLER.put(TriggerHandler.TH_DEAL, DealHandler.class);
        REGISTERED_HANDLER.put(TriggerHandler.TH_DEALLINE, DealLineHandler.class);

		System.assert(TriggerHandler.values().size() == REGISTERED_HANDLER.size());
	}

    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.SObjectType soType - Object type to process (SObject.SObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
	public static void createHandler(TriggerHandler handlerEnum)
	{
		// Get the handler requested
		INT_Trigger handler = getHandler(handlerEnum);

		// Make sure we have a handler registered, new handlers must be registered in the getHandler method.
		if(handler == null)
			throw new TriggerException('No Trigger Handler registered for Name: ' + handlerEnum.name());

		//Ensure we push the current handler and operation onto the stack
		triggerStack.push(new TriggerStackEntry(handler, handlerEnum));
		try
		{
			//Ensure that any handler that cannot handle recursion or expects to only be directly initated not to execute
//			if(!handler.allowRecursion() && inRecursion(handler))
//				return;
//			else if(!handler.allowNonSelfInitiated() && !selfInitiated(handler))
//				return;

			// Execute the handler to fulfil the trigger
			execute(handler);
		}
		catch(Exception error)
		{
			UTIL_System.logException(error);
			throw error;
		}
		finally
		{
			//if processing complete remove the handler from the stack
			triggerStack.pop();
		}
	}
    
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   INT_Trigger handler - A Trigger Handler to execute.
     */
	private static void execute(INT_Trigger handler)
	{
		// Before Trigger
		if(Trigger.isBefore)
		{
			// Call the bulk before to handle any caching of data and enable bulkification
			handler.bulkBefore();

			// Iterate through the records to be deleted passing them to the handler.
			if(Trigger.isDelete)
				for(SObject so : Trigger.old)
					handler.beforeDelete(so);
			// Iterate through the records to be inserted passing them to the handler.
			else if(Trigger.isInsert)
				for(SObject so : Trigger.new)
					handler.beforeInsert(so);
			// Iterate through the records to be updated passing them to the handler.
			else if(Trigger.isUpdate)
				for(SObject so : Trigger.old)
					handler.beforeUpdate(so, Trigger.newMap.get(so.Id));

		}
		else
		{
			// Call the bulk after to handle any caching of data and enable bulkification
			handler.bulkAfter();

			// Iterate through the records deleted passing them to the handler.
			if(Trigger.isDelete)
				for(SObject so : Trigger.old)
					handler.afterDelete(so);
			// Iterate through the records inserted passing them to the handler.
			else if(Trigger.isInsert)
				for(SObject so : Trigger.new)
					handler.afterInsert(so);
			// Iterate through the records updated passing them to the handler.
			else if(Trigger.isUpdate)
				for(SObject so : Trigger.old)
					handler.afterUpdate(so, Trigger.newMap.get(so.Id));
			else if(Trigger.isUndelete)
				for(SObject so : Trigger.new)
					handler.afterUndelete(so);
		}

		// Perform any post processing
		handler.andFinally();
	}
    
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.SObjectType soType - Object type tolocate (SObject.SObjectType)
     *
     * Returns:     INT_Trigger - A trigger handler if one exists or null.
     */
	private static INT_Trigger getHandler(TriggerHandler handlerEnum)
	{
		System.Type handlerType = REGISTERED_HANDLER.get(handlerEnum);
		if(handlerType == null)
			return null;
		else
				return (INT_Trigger)handlerType.newInstance();
	}
}