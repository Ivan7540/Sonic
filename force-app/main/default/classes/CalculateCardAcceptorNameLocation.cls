/**
 * @description       :
 * @author            : swapnil@adumo.com
 * @group             :
 * @last modified on  : 01-29-2026
 * @last modified by  : swapnil@adumo.com
 * Short name should be 16 chars long, and if duplicates then it should be 14 chars long with 2 char number
 *
**/
public class CalculateCardAcceptorNameLocation 
{
    @InvocableMethod
    public static void calculateCardAcceptorInfo(List<Id> accountIds) 
    {
        List<Account> accounts = 
        [
            SELECT Id,
            Name,
            CardAcceptorNameLocation__c,
            CardAcceptorShortName__c,
            Division__c,
            BillingCity,
            ShippingCity,
            BillingCountryCode,
            ShippingCountryCode,
            BillingState,
            BillingStateCode,
            ShippingState,
            ShippingStateCode,
            (
                SELECT Id,
                AcquiringType__c,
                AdumoAggregator__c,
                SettlementType__c
                FROM MerchantIds__r
                WHERE Status__c = 'Received'
            )
            FROM Account
            WHERE Id IN :accountIds
        ];

        Set<String> shortNamesToQuery = new Set<String>();

        for(Account eachAccount : accounts)
        {
            shortNamesToQuery.add(eachAccount.Name.left(14));
        }

        List<Account> duplicates = 
        [
            SELECT Id,
            CardAcceptorShortName__c
            FROM Account
            WHERE CardAcceptorShortName__c IN :shortNamesToQuery
        ];

        Map<String, Integer> duplicateCount = new Map<String, Integer>();
        for(Account eachAccount : duplicates)
        {
            if(duplicateCount.containsKey(eachAccount.CardAcceptorShortName__c))
            {
                duplicateCount.put(eachAccount.CardAcceptorShortName__c, duplicateCount.get(eachAccount.CardAcceptorShortName__c) + 1);
            }
            else
            {
                duplicateCount.put(eachAccount.CardAcceptorShortName__c, 1);
            }
        }

        for(Account eachAccount : accounts)
        {
            Integer shortNameLength = 15;
            if(eachAccount.MerchantIds__r.size() > 0)
            {
                if(eachAccount.Division__c == 'Card Connect')
                {
                    eachAccount.CardAcceptorNameLocation__c = 'CCN';
                }
                else if(eachAccount.Division__c == 'Mobile Merchant')
                {
                    eachAccount.CardAcceptorNameLocation__c = 'MM ';
                }
                else
                {
                    eachAccount.CardAcceptorNameLocation__c = UTIL_Constants.EMPTY;
                }

                if(eachAccount.MerchantIds__r[0].AcquiringType__c == 'Aggregator')
                {
                    eachAccount.CardAcceptorNameLocation__c += '*';
                    shortNameLength = 14;
                }
                else if(eachAccount.MerchantIds__r[0].AcquiringType__c == 'ISO')
                {
                    eachAccount.CardAcceptorNameLocation__c = '';
                    shortNameLength = 18;
                }

                eachAccount.CardAcceptorShortName__c = eachAccount.Name.left(shortNameLength);
                eachAccount.CardAcceptorNameLocation__c += eachAccount.CardAcceptorShortName__c;
                eachAccount.CardAcceptorNameLocation__c.rightPad(18);

                if(duplicateCount.containsKey(eachAccount.Name.Left(14)))
                {
                    Integer duplicateCounter = duplicateCount.get(eachAccount.Name.left(14)) + 1;

                    if(duplicateCounter < 9) 
                    {
                        eachAccount.CardAcceptorNameLocation__C += ' ' + String.valueOf(duplicateCounter);
                    }
                    else 
                    {
                        eachAccount.CardAcceptorNameLocation__C += String.valueOf(duplicateCounter);
                    }
                }

                eachAccount.CardAcceptorNameLocation__c.rightPad(20);

                if(eachAccount.MerchantIds__r[0].AcquiringType__c == 'Aggregator')
                {
                    if(eachAccount.MerchantIds__r[0].SettlementType__c == 'Net Settlement' && eachAccount.MerchantIds__r[0].AcquiringType__c == 'Aggregator')
                    {
                        eachAccount.CardAcceptorNameLocation__c += '{$}';
                    }
                    else
                    {
                        eachAccount.CardAcceptorNameLocation__c += '{#}';
                    }
                }

                If(eachAccount.BillingCity == null)
                {
                    if(eachAccount.ShippingCity == null)
                    {
                        if(eachAccount.BillingState == null)
                        {
                            if(eachAccount.ShippingState == null)
                            {
                                eachAccount.CardAcceptorNameLocation__c = eachAccount.CardAcceptorNameLocation__c.rightPad(36);
                            }
                            else
                            {
                                eachAccount.CardAcceptorNameLocation__c += eachAccount.ShippingState.left(13);
                            }
                        }
                        else
                        {
                            eachAccount.CardAcceptorNameLocation__c += eachAccount.BillingState.left(13);
                        }
                    }
                    else 
                    {
                        eachAccount.CardAcceptorNameLocation__c += eachAccount.ShippingCity.left(13);
                    }
                }
                else
                {
                    eachAccount.CardAcceptorNameLocation__c += eachAccount.BillingCity.left(13);
                }

                eachAccount.CardAcceptorNameLocation__c = eachAccount.CardAcceptorNameLocation__c.rightPad(36);

                if(eachAccount.BillingStateCode == null && eachAccount.ShippingStateCode != null)
                {
                    eachAccount.CardAcceptorNameLocation__c += eachAccount.ShippingStateCode;                    
                }
                else
                {
                    eachAccount.CardAcceptorNameLocation__c += eachAccount.BillingStateCode;
                }
                    
                eachAccount.CardAcceptorNameLocation__c = eachAccount.CardAcceptorNameLocation__c.rightPad(38);

                if(eachAccount.BillingCountryCode == null && eachAccount.ShippingCountryCode != null)
                {                    
                    eachAccount.CardAcceptorNameLocation__c += eachAccount.ShippingCountryCode;                    
                }
                else
                {
                    eachAccount.CardAcceptorNameLocation__c += eachAccount.BillingCountryCode;
                }

                eachAccount.CardAcceptorNameLocation__c = eachAccount.CardAcceptorNameLocation__c.rightPad(40);
            }
        }

        update accounts;
    }
}