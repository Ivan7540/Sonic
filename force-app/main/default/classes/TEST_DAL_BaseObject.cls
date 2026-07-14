/**
 * Created by daini on 17/06/08.
 */
@isTest(SeeAllData=false)
public with sharing class TEST_DAL_BaseObject {

    static testMethod void test_undelete() {
        
        Account acc = DAL_Account.newItem();
        DAL_BaseObject.InsertDBObject(acc);

        Test.startTest();
        DAL_BaseObject.DeleteDBObject(acc);

        DAL_BaseObject.UndeleteDBObject(acc);

        Test.stopTest();

    }
}