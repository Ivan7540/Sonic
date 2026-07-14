/*
Date created: 02/06/2021
Developer: Ivan Vrtacnik
JIRA number: PS-225
*/
public class AllContractCancellationInvocable 
{
    public static List<String> CancellableStatuses = new List<String>{'Activated', 'Suspended'};

    @InvocableMethod
    public static List<List<Id>> cancelContracts(List<Id> accountIds)
    {
        List<Contract> contractList = getAccountContracts(accountIds);
        List<CPQ_APIAmendContractInvocable.RequestParams> inputs = new List<CPQ_APIAmendContractInvocable.RequestParams>();

        for(Contract contract: contractList)
        {
            CPQ_APIAmendContractInvocable.RequestParams param = new CPQ_APIAmendContractInvocable.RequestParams();
            param.amendStartDate = Date.today();
            param.cancelContract = true;
            param.cancellationProductCode = 'SS_CANCELLATION_FEES';
            param.waiverCancellationFee = true;
            param.contractId = contract.Id;
            param.priceBookId = contract.SBQQ__OpportunityPricebookId__c;
            inputs.add(param);
        }

        List<Id> quoteIds = CPQ_APIAmendContractInvocable.amendContract(inputs);

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

        for(Id qId :quoteIds)
        {
            quotes.add(new SBQQ__Quote__c(Id = qId, CreateOrderCalculation__c = true));
        }

        DAL_BaseObject.UpdateDBObjects(quotes);

        return new List<List<Id>>{quoteIds};
    }

    private static List<Contract> getAccountContracts(List<Id> accountIds)
    {
        return
        [
            SELECT  Id,
                    Pricebook2Id,
                    SBQQ__OpportunityPricebookId__c
            FROM Contract   
            WHERE AccountId IN :accountIds
            AND Status IN :CancellableStatuses
        ];
    }
}