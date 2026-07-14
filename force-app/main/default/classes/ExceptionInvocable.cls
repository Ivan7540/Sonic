/*
Date created: 05/06/2021
Developer: Ivan Vrtacnik
JIRA number: PS-636
*/
public class ExceptionInvocable 
{
    public class CustomException extends Exception {}
    
    @InvocableMethod(label='Throw Custom Flow Exception')
    public static void throwCustomFlowException(List<String> input)
    {
        throw createCustomException(input[0]);
    }

    static CustomException createCustomException(String message) 
    {
        CustomException ex = new CustomException(message);
        ex.setMessage(message);
        return ex;
    }
}