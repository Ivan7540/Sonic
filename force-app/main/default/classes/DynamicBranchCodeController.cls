public class DynamicBranchCodeController
{
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getBranchCodes(){
		List<BankBranchCode__mdt> branchCodes = [SELECT MasterLabel, BranchCode__c FROM BankBranchCode__mdt];
		Map<String, String> branchCodeMap = new Map<String, String>();
		for (BankBranchCode__mdt branchCode : branchCodes)
		{
			branchCodeMap.put(branchCode.MasterLabel, branchCode.BranchCode__c);
		}
		return branchCodeMap;
	}
}