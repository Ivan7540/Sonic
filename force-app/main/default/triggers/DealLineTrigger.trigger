/**
 * Created by ViktorijaR on 12/14/2021.
 */

trigger DealLineTrigger on Deal_Line__c (before delete)
{
	FACTORY_TriggerHandler.createHandler(FACTORY_TriggerHandler.TriggerHandler.TH_DEALLINE);
}