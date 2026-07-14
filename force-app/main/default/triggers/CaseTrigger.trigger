/**
 * Created by simonas on 2021-08-18.
 */

trigger CaseTrigger on Case (before update)
{
	FACTORY_TriggerHandler.createHandler(FACTORY_TriggerHandler.TriggerHandler.TH_CASE);
}