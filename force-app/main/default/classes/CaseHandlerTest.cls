/**
 * Created by simonas on 2021-08-18.
 */

@IsTest(SeeAllData=false)
private class CaseHandlerTest
{
	@IsTest
	static void shouldAllowUpdatingCase()
	{
        Test.startTest();
        try
        {
            Case newCase = new Case(
                    Subject = 'Test'
            );
            insert newCase;
            update newCase;
            System.assert(true);
        }
        catch (Exception e)
        {
            System.assert(false, e);
        }
        Test.stopTest();
	}
}