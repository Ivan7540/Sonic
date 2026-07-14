/**
 * Created by simonas on 2022-02-11.
 */

public virtual class DealLineBundleConverter
{
	private static DealLineRebateConverter rebateConverter = new DealLineRebateConverter();

	public List<DTO_DealLineBundle> convert(List<Deal_Line__c> dealLines)
	{
		List<DTO_DealLineBundle> bundles = new List<DTO_DealLineBundle>();
		for (Deal_Line__c dealLine : dealLines)
		{
			DTO_DealLineBundle bundle = new DTO_DealLineBundle();
			bundle.id = dealLine.Id;
			bundle.product = dealLine.Product__c;
			bundle.device = dealLine.Device__c;
			bundle.contractTerm = dealLine.ContractTerm__c;
			bundle.Quantity = dealLine.Quantity__c;
			bundle.paymentServer = dealLine.PaymentServer__c;
			bundle.deviceType = dealLine.DeviceType__c;
			bundle.moretymeType = dealLine.MoretymeType__c;
			bundle.rebateLines = rebateConverter.convert(dealLine.Child_Lines__r);
			bundles.add(bundle);
		}
		return bundles;
	}
}