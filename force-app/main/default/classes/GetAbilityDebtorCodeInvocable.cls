/*
Date created: 07/06/2021
Developer: Ajit Gopu
JIRA number: PS-517
*/
public class GetAbilityDebtorCodeInvocable {
	@InvocableMethod
    public static Void getAbilityDebtorCode(List<Id> oppId)
    {
        GetAbilityDebtorCode.updateAccount(oppId);
    }
}