/**
 * Created by simonas on 2021-08-18.
 */

@IsTest(SeeAllData=false)
private class CaseUpdateValidatorTest
{
	@IsTest
	static void shouldIgnoreSameStatus()
	{
		Case oldCase =  new Case(
				Status = DAL_Case.STATUS_CANCELLATION_RETRACTED
		);
		Case newCase = oldCase.clone(true);
		Test.startTest();
		CaseUpdateValidator validator = new CaseUpdateValidator();
		validator.initialize(new List<Case>());
		validator.validate(oldCase, newCase);
		System.assert(newCase.getErrors().isEmpty());
		Test.stopTest();
	}

	@IsTest
	static void shouldAllowChangeStatusIdNoCompletedWorkOrder()
	{
		Case oldCase = new Case();
		Case newCase = new Case(
				Status = DAL_Case.STATUS_CANCELLATION_RETRACTED
		);
		Test.startTest();
		CaseUpdateValidator validator = new CaseUpdateValidator();
		System.assert(validator.caseIdsWithCompletedWorkOrders.isEmpty());
		validator.validate(oldCase, newCase);
		System.assert(newCase.getErrors().isEmpty());
		Test.stopTest();
	}

	@IsTest
	static void shouldNotAllowRetractingCaseWithCompletedOrder()
	{
		Case oldCase = new Case(
				Id = Case.getSObjectType().getDescribe().getKeyPrefix() + '000000000000'
		);
		Case newCase = oldCase.clone(true);
		newCase.Status = DAL_Case.STATUS_CANCELLATION_RETRACTED;
		Test.startTest();
		CaseUpdateValidator validator = new CaseUpdateValidator();
		validator.addCaseIdsWithCompletedWorkOrder(newCase);
		validator.validate(oldCase, newCase);
		System.System.assertEquals(CaseUpdateValidator.ERROR_HAS_COMPLETED_WORK_ORDER, newCase.getErrors()[0].getMessage());
		Test.stopTest();
	}
}