@isTest(SeeAllData=false)
private class TEST_DAL_BaseObject_recordTypes
{
	static testMethod void test_getRecordTypeById()
	{
		Schema.sObjectType objType = Schema.Opportunity.getSObjectType();

		List<RecordType> recordTypes = DAL_BaseObject.getRecordTypes(objType);

		if(recordTypes.size() > 0)
		{
			RecordType rt = recordTypes.get(0);

			// TEST 1
			Id rt_id = rt.Id;
			String expectedName = rt.Name;
			String fetchedName = DAL_BaseObject.getRecordTypeById(rt_id);
			System.assertEquals(expectedName, fetchedName);

			//TEST 2
			String emptyName = DAL_BaseObject.getRecordTypeById(null);
			System.assertEquals(true, String.isEmpty(emptyName));
		}
	}

	static testMethod void test_getRecordTypesByIds()
	{
		Schema.sObjectType objType = Schema.Opportunity.getSObjectType();
		List<RecordType> accountRecordTypes = DAL_BaseObject.getRecordTypes(objType);

		Set<Id> ids = new Set<Id>();
		for(RecordType rt : accountRecordTypes)
		{
			ids.add(rt.Id);
		}

		List<RecordType> fetchedRecordTypes = DAL_BaseObject.getRecordTypesByIds(ids);
		System.assertEquals(accountRecordTypes.size(), fetchedRecordTypes.size());
	}

	static testMethod void test_getRecordTypeByDeveloperName()
	{
		Schema.sObjectType objType = Schema.Opportunity.getSObjectType();

		List<RecordType> recordTypes = DAL_BaseObject.getRecordTypes(objType);

		if(recordTypes.size() > 0)
		{
			RecordType rt = recordTypes.get(0);

			String developerName = rt.DeveloperName;

			Id fetchedId = DAL_BaseObject.getRecordTypeByDeveloperName(objType, developerName);
			System.assertEquals(rt.Id, fetchedId);
		}
	}

	static testMethod void test_getRecordTypesMapForObject()
	{
		Schema.sObjectType objType = Schema.Opportunity.getSObjectType();
		String objName = Opportunity.sObjectType.getDescribe().getLocalName();
		Map<String, Id> recordTypesMap = DAL_BaseObject.getRecordTypesIdsMapForObject(objName);

		if(recordTypesMap.size() > 0)
		{
			Set<String> developerNamesSet =  recordTypesMap.keySet();
			List<String> developersNamesList = new List<String>(developerNamesSet);
			ID rtId = recordTypesMap.get(developersNamesList.get(0));

			Id fetchedId = DAL_BaseObject.getRecordTypeByDeveloperName(objType, developersNamesList.get(0));
			System.assertEquals(rtId, fetchedId);
		}
	}
}