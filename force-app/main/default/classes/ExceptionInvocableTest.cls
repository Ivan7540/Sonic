/*
Date created: 05/06/2021
Developer: Ivan Vrtacnik
JIRA number: PS-636
*/
@isTest(SeeAllData = false)
public class ExceptionInvocableTest 
{
    private static String testMessage = 'Test message';

    @isTest
    static void testThrow()
    {
        Test.startTest();

        try 
        {
            ExceptionInvocable.throwCustomFlowException(new List<String>{testMessage});
            System.assert(false, 'Exception should be thrown');
        } 
        catch (ExceptionInvocable.CustomException cex) 
        {
            System.assertEquals(testMessage, cex.getMessage(), 'Incorrect exception message');  
        }
        catch (Exception ex) 
        {
            System.assert(false, 'Wrong exception type: ' + ex.getTypeName());
        }

        Test.stopTest();
    }
}