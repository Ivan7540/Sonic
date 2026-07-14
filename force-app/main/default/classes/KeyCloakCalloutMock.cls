/*
Date created: 29/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-143
*/
global class KeyCloakCalloutMock implements HttpCalloutMock
{
    private String Response = '{"firstName": "James", "lastName": "Burt", "email": "james.burt@sureswipe.co.za", "keycloakUuid": "5b7708f5-2b56-41a0-bcf3-aa3c4dc1edc4", "enabled": true, "accountId": "0011w000002y1JU", "exist": true}';
    private Integer statusCode;

    public KeyCloakCalloutMock(Integer statusCode)
    {
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(Response);
        res.setStatusCode(statusCode);
        return res;
    }
}