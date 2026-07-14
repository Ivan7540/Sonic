@isTest
public class SendPaymentLinkTest {
    @isTest static void testMethod1(){
        
        List<String> inputs = new List<String>();
        inputs.add('Test12345');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendPaymentLinkMock()); 
        List<SendPaymentLink.responseParam> outputs = SendPaymentLink.sendPaymentLink(inputs);
        Test.stopTest();
        
        System.assertEquals(200, outputs.get(0).statusCode);
        
    }
}