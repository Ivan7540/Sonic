@isTest
public class SendPaymentLinkMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Length', '0');
        response.setStatusCode(200);
        return response; 
    }
}