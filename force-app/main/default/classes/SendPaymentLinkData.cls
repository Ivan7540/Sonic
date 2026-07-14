public class SendPaymentLinkData {

	public String expiryDate;
	public String customerName;
	public String customerEmail;
	public String specialNotes;
	public String msisdn;
	public String uci;
	public String puid;
	public String merchantReference;
	public Double amount;
	public Schedule schedule;
	public List<String> paymentLinkChannels;
	public String description;
	public String messageBody;

	public class Schedule {
		public String startDate;
		public Integer frequency;
		public Integer recurrence;
	}
	public static SendPaymentLinkData parse(String json) {
		return (SendPaymentLinkData) System.JSON.deserialize(json, SendPaymentLinkData.class);
	}
}