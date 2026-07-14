/**
 * Created by JurgitaG on 2/9/2021.
 */

public without sharing class LCC_LookupInput
{
	@AuraEnabled(cacheable=true)
	public static List<sobject> findRecords(String searchKey, String objectName) {
		string searchText = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
		string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';
		return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6');
	}
}