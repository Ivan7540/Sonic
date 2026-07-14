/**
 * Created by JurgitaG on 3/13/2021.
 */

public without sharing class DTO_QuoteGroup
{
	public String name;
	public String currencyIso;
	public String quoteId;
	public String description;
	public Integer groupNumber;
	public Boolean separateContract;
	public Decimal customerTotal;
	public Decimal netTotal;
	public Decimal listTotal;


	public Map<String, Object> dtoMapping()
	{
		return new Map<String, Object>
		{
				'Name' => this.name,
				'CurrencyIsoCode' => this.currencyIso,
				'SBQQ__Quote__c' => this.quoteId,
				'SBQQ__Description__c' => this.description,
				'SBQQ__Number__c' => this.groupNumber,
				'SBQQ__SeparateContract__c' => this.separateContract,
				'SBQQ__CustomerTotal__c' => this.customerTotal,
				'SBQQ__NetTotal__c' => this.netTotal,
				'SBQQ__ListTotal__c' => this.listTotal
		};
	}

	public DTO_QuoteGroup(String name, String currencyIso, String quoteId, String description, Integer groupNumber)
	{
		this.name = name;
		this.currencyIso = currencyIso;
		this.quoteId = quoteId;
		this.description = description;
		this.groupNumber = groupNumber;
		this.separateContract = true;
		this.customerTotal= 0;
		this.netTotal=0;
		this.listTotal=0;
	}

}