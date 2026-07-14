global class GetAbilityDebtorMock implements HttpCalloutMock{
	private String Response = '{"contractId": "0012500001RrXWQAA3", "response": "FOU060"}';
    private Integer statusCode;

    public getAbilityDebtorMock(Integer statusCode)
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