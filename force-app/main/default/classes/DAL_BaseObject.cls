/*
** This is the base Data Access Layer Object from which all DAL objects should inherited
** It impements various common functions
*/

global virtual class DAL_BaseObject
{
	global enum DatabaseOperation
	{
		DBO_INSERT, DBO_UPDATE, DBO_DELETE, DBO_UNDELETE
	}

	public static Map<Integer, Map<String, List<String>>> dmlOperationErrors = new Map<Integer, Map<String, List<String>>>();

	private static final String CONTACT_EMAIL_SUFFIX = '@mailinator.com';
	private static final String ERROR_UNABLE_TO_SAVE = 'Unable to save the following: ' + al.StringUtils.LF;
	private static final String SUCCESSFULL_DELETE_MESSAGE = 'Successfully deleted an object with ID: ';

	//Used to retrieve recordtypes during a transaction context, will be filled with all recordtypes in system.
	private static List<RecordType> ALL_RECORD_TYPES = null;
	private static Map<String, Map<String, RecordType>> ALL_RECORD_TYPES_BYOBJECT_MAP = null;
	private static Map<ID, RecordType> ALL_RECORD_TYPES_BYID_MAP = null;
	private static String MASTER_RECORDTYPE_NAME = 'Master';

	public static final String SUM_ALIAS = 'sum';
	public static final String COUNT_ALIAS = 'num';
	public static final String CUSTOM_FIELD_SUFFIX = '__c';
	public static final String UNDERSCORE_SEPARATOR = '_';
	public static final String DOT_SEPARATOR = '.';

	public static final String FIELD_ID = 'Id';
	public static final String FIELD_ACCOUNT_ID = 'AccountId';
	public static final String FIELD_CONTENDOCUMENT_ID = 'ContentDocumentId';
	public static final String FIELD_DOCUMENT_ID = 'Document__c';
	public static final String FIELD_LOCATION_ID = 'Location_of_Documents__c';
	public static final String FIELD_LINKEDENTITY_ID = 'LinkedEntityId';
	public static final String FIELD_OPPORTUNITY_ID = 'OpportunityId';
	public static final String FIELD_OWNER_ID = 'OwnerId';
	public static final String FIELD_CREATEDBY_ID = 'CreatedById';
	public static final String FIELD_MODIFIEDBY_ID = 'LastModifiedById';
	public static final String FIELD_ISDELETED = 'IsDeleted';
	public static final String FIELD_PARENT_ID = 'ParentId';
	public static final String FIELD_MASTERRECORD_ID = 'MasterRecordId';
	public static final String FIELD_PARTNERACCOUNT_ID = 'PartnerAccountId';
	public static final String FIELD_SYNCEDQUOTE_ID = 'SyncedQuoteId';
	public static final String FIELD_CONTRACTID_ID = 'ContractId';
	public static final String FIELD_PERSON_CONTACT_ID = 'PersonContactId';
	public static final String FIELD_PRICEBOOK2_ID = 'Pricebook2Id';
	public static final String FIELD_PRICEBOOK_ENTRY_ID = 'PricebookEntryId';
	public static final String FIELD_PRODUCT2ID = 'Product2Id';
	public static final String FIELD_RECORDTYPE_ID = 'RecordTypeID';
	public static final String FIELD_RECORDTYPE_DEV_NAME = 'RecordType.DeveloperName';

	public static final String OBJECT_RECORDTYPE = 'RecordType';
	public static final String FIELD_USER_ID = 'UserId';
	public static final String FIELD_DOCUSIGN_ENVELOPE_ID = 'dsfs__DocuSign_Envelope_ID__c';

	public static final String FIELD_COMPANY = 'Company';
	public static final String FIELD_EMAIL = 'Email';
	public static final String FIELD_FIRST_NAME = 'FirstName';
	public static final String FIELD_LAST_NAME = 'LastName';
	public static final String FIELD_NAME = 'Name';
	public static final String FIELD_DOCUMENT_NAME = 'Document_Name__c';
	public static final String FIELD_TEAM_MEMBER_ROLE = 'TeamMemberRole';

	public static final String FIELD_ACCOUNT_C = 'Account__c';
	public static final String FIELD_CASE_C = 'Case__c';
	public static final String FIELD_FINANCIAL_ASSET_C = 'Financial_Asset__c';
	public static final String FIELD_ACCEPTANCE_STATUS_C = 'Acceptance_Status__c';
	public static final String FIELD_OPPORTUNITY_C = 'Opportunity__c';
	public static final String FIELD_OPPORTUNITY_LINE_ITEM_ID_C = 'Opportunity_Line_Item_Id__c';
	public static final String FIELD_SHADOW_OPPORTUNITY_PRODUCT_C = 'Shadow_Opportunity_Product__c';

	public static final String FIELD_EXPR0 = 'expr0';

	public static final String FIELD_LAST_MODIFIED_DATE = 'LastModifiedDate';

	public static final String SEARCH_TERM_FMT = '{0}{1}{0}';
	public static final String LIKE_WILD_CARD_CHAR = '%';
	public static final String SOQL_OFFSET_FMT = ' OFFSET {0}';
	private static final Set<String> DEFAULT_SEARCH_FIELDS = new Set<String> {FIELD_ID, FIELD_NAME};

	public static final String UNKNOWN_VALUE = 'Unknown';
	public static final String VALUE_YES = 'Yes';
	public static final String VALUE_NO = 'No';
	public static final String VALUE_IN_PROGRESS = 'In Progress';
	public static final String VALUE_COMPLETE = 'Complete';


	public static final Boolean ALL_OBJECTS_MUST_SUCCEED = true;
	public static final Boolean NOT_ALL_OBJECTS_MUST_SUCCEED = false;

	public static final String DATE_FORMAT = 'yyyy/MM/dd HH:mm a';
	public static final String STD_CURRENCY_ISO_CODE = 'ZAR';

	public static final Integer LIMIT_NUMBER_OF_RECORDS = 50000;

	//Various Lengths
	public static final Integer FL_NAME = 80;
	private static final Integer DEFAULT_NAME_LEN = 15;
	public static final Integer PHONE_NUMBER_LENGTH = 9;

	public static final String SUBJECT_FMT = '{0} - {1}';

	public static final String PHONE_FMT = '+{0}{1}{2}{3}{4}';

	public static final Integer NICK_NAME_LEN = 8;
	public static final String COMMUNITY_NICKNAME = al.RandomStringUtils.randomAlphabetic(NICK_NAME_LEN);

	private static final Map<Integer, DatabaseOperation> DATABASE_OPP_MAP = new Map<Integer, DatabaseOperation>
	{
			DatabaseOperation.DBO_INSERT.ordinal() => DatabaseOperation.DBO_INSERT,
			DatabaseOperation.DBO_UPDATE.ordinal() => DatabaseOperation.DBO_UPDATE,
			DatabaseOperation.DBO_DELETE.ordinal() => DatabaseOperation.DBO_DELETE,
			DatabaseOperation.DBO_UNDELETE.ordinal() => DatabaseOperation.DBO_UNDELETE
	};

	public class DatabaseException extends Exception
	{
	}

	public static Boolean insertDBObjects(List<SObject> listOfObjects, Boolean allInsertsMustSucceed)
	{
		return UpdateDatabase(listOfObjects, DatabaseOperation.DBO_INSERT, allInsertsMustSucceed);
	}

	public static void UndeleteDBObject(SObject objectToUndelete)
	{
		List<SObject> listOfObjects = new List<SObject>{objectToUndelete};
		UndeleteDBObjects(listOfObjects);
	}

	public static void UndeleteDBObjects(List<SObject> listOfObjects)
	{
		Database.undelete(listOfObjects);
	}

	public static Boolean InsertDBObjects(List<SObject> listOfObjects)
	{
		return InsertDBObjects(listOfObjects, true);
	}

	public static Boolean InsertDBObject(SObject obj)
	{
		return InsertDBObject(obj, true);
	}

	public static Boolean InsertDBObject(SObject obj, Boolean allUpdatesMustSucceed)
	{
		return InsertDBObjects(New List<SObject> {obj}, allUpdatesMustSucceed);
	}

	public static Boolean UpdateDBObjects(List<SObject> listOfObjects, Boolean allUpdatesMustSucceed)
	{
		return UpdateDatabase(listOfObjects, DatabaseOperation.DBO_UPDATE, allUpdatesMustSucceed);
	}

	public static Boolean UpdateDBObject(SObject obj)
	{
		return UpdateDBObject(obj, true);
	}

	public static Boolean UpdateDBObject(SObject obj, Boolean allUpdatesMustSucceed)
	{
		return UpdateDBObjects(new List<SObject> {obj}, allUpdatesMustSucceed);
	}

	public static Boolean UpdateDBObjects(List<SObject> listOfObjects)
	{
		return UpdateDBObjects(listOfObjects, true);
	}

	public static Boolean DeleteDBObjects(List<SObject> listOfObjects, Boolean allDeletesMustSucceed)
	{
		return UpdateDatabase(listOfObjects, DatabaseOperation.DBO_DELETE, allDeletesMustSucceed);
	}

	public static Boolean DeleteDBObjects(List<SObject> listOfObjects)
	{
		return DeleteDBObjects(listOfObjects, true);
	}

	public static Boolean DeleteDBObject(SObject obj)
	{
		return DeleteDBObjects(new List<SObject> {obj});
	}

	private static Boolean UpdateDatabase(List<SObject> listOfObjects, DatabaseOperation operation, Boolean allOperationsMustSucceed)
	{
		Savepoint saveTransaction = null;

		dmlOperationErrors.clear();

		if(listOfObjects.isEmpty())
			return false;

		List<SObject> listToUpdate = new List<SObject>();

		//remove duplicates (if we are doing delete or update)
		if(operation == DatabaseOperation.DBO_UPDATE || operation == DatabaseOperation.DBO_DELETE)
		{
			Set<SObject> setOfObject = new Set<SObject>();
			setOfObject.addAll(listOfObjects);
			listOfObjects.clear();
			listOfObjects.addAll(setOfObject);
		}

		List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
		List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();

		if(allOperationsMustSucceed)
			saveTransaction = Database.setSavepoint();

		try
		{
			if(operation == DatabaseOperation.DBO_INSERT)
				saveResults = Database.insert(listOfObjects, allOperationsMustSucceed);
			else if(operation == DatabaseOperation.DBO_UPDATE)
				saveResults = Database.update(listOfObjects, allOperationsMustSucceed);
			else if(operation == DatabaseOperation.DBO_DELETE)
				deleteResults = Database.delete(listOfObjects, allOperationsMustSucceed);

			Integer objIndex = 0;

			if(!saveResults.isEmpty())
				for(Database.SaveResult saveResult : saveResults)
				{
					if(!saveResult.isSuccess())
						collectErrors(listOfObjects, objIndex, saveResult.getErrors());

					objIndex++;
				}
			else if(!deleteResults.isEmpty())
				for(Database.Deleteresult deleteResult : deleteResults)
				{
					if(!deleteResult.isSuccess())
						collectErrors(listOfObjects, objIndex, deleteResult.getErrors());

					objIndex++;
				}
		}
		catch(Exception error)
		{
			if(saveTransaction != null)
				Database.rollback(saveTransaction);

			UTIL_System.logException(error);

			throw error;
		}

		return dmlOperationErrors.isEmpty();
	}

	private static void collectError(List<SObject> listOfObjects, Integer objIndex, Database.Error error, Map<String, List<String>> fieldToErrors)
	{
		String errorMessage;

		if(error instanceof Database.DuplicateError)
		{
			Database.DuplicateError duplicateError = (Database.DuplicateError)error;
			errorMessage = duplicateError.getDuplicateResult().getErrorMessage();
		}
		else
				errorMessage = error.getMessage();

		List<String> fields = error.getFields();

		if(fields.isEmpty())
		{
			List<String> errors = fieldToErrors.get(al.StringUtils.EMPTY);

			if(errors == null)
				fieldToErrors.put(al.StringUtils.EMPTY, new List<String> {errorMessage});
			else
					errors.add(errorMessage);
		}
		else
				for(String fieldName : fields)
				{
					List<String> errors = fieldToErrors.get(fieldName);

					if(errors == null)
						fieldToErrors.put(fieldName, new List<String> {errorMessage});
					else
							errors.add(errorMessage);
				}
	}

	private static void collectErrors(List<SObject> listOfObjects, Integer objIndex, List<Database.Error> errors)
	{
		Map<String, List<String>> fieldToErrors = dmlOperationErrors.get(objIndex);

		if(fieldToErrors == null)
		{
			fieldToErrors = new Map<String, List<String>>();
			dmlOperationErrors.put(objIndex, fieldToErrors);
		}

		for(Database.Error error : errors)
			collectError(listOfObjects, objIndex, error, fieldToErrors);
	}

	public static DatabaseOperation getTriggerDBOperation()
	{
		if(trigger.isInsert)
			return DatabaseOperation.DBO_INSERT;
		else if(trigger.isUpdate)
			return DatabaseOperation.DBO_UPDATE;
		else if(trigger.isDelete)
			return DatabaseOperation.DBO_DELETE;
		else
				return DatabaseOperation.DBO_UNDELETE;
	}

	public static Date generateRandomDate()
	{
		Date randomDate = Date.today();
		Date epochDate = Datetime.newInstance(0).date();
		Integer daysBetween = epochDate.daysBetween(randomDate);
		//Generate years to subtract from current date
		Integer daysToSubtract = (Math.random() * daysBetween + 1).intValue();
		return randomDate.addDays(-daysToSubtract);
	}

	public static String generateRandomNumber()
	{
		return al.RandomStringUtils.randomNumeric(DEFAULT_NAME_LEN);
	}

	public static Integer generateRandomInteger()
	{
		Integer randomInteger = (Integer)(Math.random() * 10) + 1;
		return randomInteger;
	}

	public static String generateRandomName()
	{
		return al.RandomStringUtils.randomAlphabetic(DEFAULT_NAME_LEN);
	}

	public static String generateRandomDescription()
	{
		return al.RandomStringUtils.randomAlphabetic(FL_NAME);
	}

	public static String generateRandomEmail()
	{
		return generateRandomName() + CONTACT_EMAIL_SUFFIX;
	}

	public static String getRecordTypeById(Id recordTypeID)
	{
		populateRecordTypesMap();

		RecordType recordType = ALL_RECORD_TYPES_BYID_MAP.get(recordTypeID);

		if(recordType != null)
			return recordType.Name;
		else
				return al.StringUtils.EMPTY;
	}

	public static List<RecordType> getRecordTypesByIds(Set<ID> recordTypeIds)
	{
		populateRecordTypesMap();

		List<RecordType> recordTypes = new List<RecordType>();

		for(ID recordTypeId : recordTypeIds)
		{
			RecordType recordType = ALL_RECORD_TYPES_BYID_MAP.get(recordTypeID);
			if(recordType != null)
				recordTypes.add(recordType);
		}

		return recordTypes;
	}

	public static Map<String, Id> getRecordTypesIdsMapForObject(String sobjectTypeName)
	{
		List<RecordType> recordTypes =
		[
				SELECT Id,
						DeveloperName,
						SobjectType,
						Name,
						Description
				FROM RecordType
				WHERE SobjectType =: sobjectTypeName
		];

		Map<String, Id> recordsTypesMap = new Map<String, Id>();
		for(RecordType rt : recordTypes)
			recordsTypesMap.put(rt.DeveloperName, rt.Id);

		return recordsTypesMap;
	}

    /*
    * @description Method will retrieve the Id for the RecordType of an Object by DeveloperName (if it exists), else it will return a null
    * This method can be called many times in the same transaction context but will only ever do one query
    */
	public static Id getRecordTypeByDeveloperName(SObjectType objectType, String recordTypeName)
	{
		populateRecordTypesMap();

		Map<String, RecordType> recordTypesMap = ALL_RECORD_TYPES_BYOBJECT_MAP.get(objectType.getDescribe().getLocalName());

		if(recordTypesMap == null)
			return null;

		RecordType recordType = recordTypesMap.get(recordTypeName);

		if(recordType == null)
			return null;

		return recordType.Id;
	}
    
    /*
    * @description Method will ensure all recordtypes are retrieved and popualted into map (assuminng map hasn't already been populated)
    */
	private static void populateRecordTypesMap()
	{
		if(ALL_RECORD_TYPES == null)
		{
			ALL_RECORD_TYPES_BYOBJECT_MAP = new Map<String, Map<String, RecordType>>();

			ALL_RECORD_TYPES =
			[
					SELECT
							Id,
							SobjectType,
							Name,
							Description,
							DeveloperName
					FROM RecordType
					LIMIT 10000
			];

			ALL_RECORD_TYPES_BYID_MAP = new Map<ID, RecordType>();

			for(RecordType recordType : ALL_RECORD_TYPES)
			{
				ALL_RECORD_TYPES_BYID_MAP.put(recordType.Id, recordType);

				Map<String, RecordType> recordTypesMap = ALL_RECORD_TYPES_BYOBJECT_MAP.get(recordType.SobjectType);

				if(recordTypesMap == null)
				{
					recordTypesMap = new Map<String, RecordType>();
					ALL_RECORD_TYPES_BYOBJECT_MAP.put(recordType.SobjectType, recordTypesMap);
				}

				recordTypesMap.put(recordType.DeveloperName, recordType);
			}

		}
	}

	public static List<RecordType> getRecordTypes(SObjectType objectType)
	{
		return
		[
				SELECT
						Id,
						Name,
						Description,
						DeveloperName
				FROM
						RecordType
				WHERE
						SobjectType = :objectType.getDescribe().getLocalName()
		];
	}
    
    /* 
    * @description Method will ensure that the string passed will fit inside a name field.
    */


	public static SObject newObject(String sobjectTypeName)
	{
		SObjectType objType = UTIL_System.getSObjectTypeByName(sobjectTypeName);

		if(objType == null)
			return null;

		return objType.newSObject();
	}
}