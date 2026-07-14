public virtual class API_Callout_Base
{
	public static final String ERROR = 'Error';
	public static final String SUCCESS = 'Success';
	public static final String GET = 'GET';
	public static final String ACCEPT = 'Accept';
	public static final String CONTENT_TYPE = 'Content-Type';
	public static final String WWW_URL_ENCODED = 'application/x-www-form-urlencoded';
	public static final String APPLICATION_JSON = 'application/json';
	public static final String AUTHORIZATION = 'Authorization';
	public static final String BASIC = 'Basic';
	public static final String POST = 'POST';
	public static final String PATCH = 'PATCH';

	public Map<String, String> getRequestResponse(HttpResponse httpResponse)
	{
		Map<String, String> returnMap = new Map<String, String>();
		if (httpResponse.getStatusCode() >= 400)
			returnMap.put(ERROR, httpResponse.getBody());
		else
				returnMap.put(SUCCESS, httpResponse.getBody());
		return returnMap;
	}

	public Map<String, String> sendRequest(HttpRequest req)
	{
		Http http = new Http();
		try
		{
			HttpResponse res = http.send(req);
			return getRequestResponse(res);
		}
		catch (Exception e)
		{
			return new Map<String, String>{ERROR => e.getMessage()};
		}
	}
}