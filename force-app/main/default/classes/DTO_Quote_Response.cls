/**
 * Created by JurgitaG on 3/18/2021.
 */

global class DTO_Quote_Response
{
	public String id;
	public Boolean success;
	public DTO_Quote quoteInfo;
	public static DTO_Quote_Response parse(String json)
	{
		return (DTO_Quote_Response) System.JSON.deserialize(json, DTO_Quote_Response.class);
	}
}