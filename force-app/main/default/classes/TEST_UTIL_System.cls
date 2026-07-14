@isTest (SeeAllData=true)
public class TEST_UTIL_System {
    static testmethod void testextractListFromMap() {
        List<Account> accList = new List<Account>();
        List<Account> accList2 = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account a = new Account(Name='Test ' + i);
            Account b = new Account(Name='Testing ' + i);
            accList.add(a);
            accList2.add(b);
        }
        //DAL_BaseObject.insertDbObjects(accList);
        Map<String, List<Account>> accsMpa = new Map<String, List<Account>>();
        accsMpa.put('One', accList);
        accsMpa.put('Two', accList2);
        Test.startTest();
        List<Account> rtnList = UTIL_System.extractListFromMap(accsMpa);
        Test.stopTest();
        System.assertEquals(20, rtnList.size());
    }
    
    static testmethod void testmatches() {
        Account a = new Account(Name='Test');
        Map<String, Account> accMap = new Map<String, Account>();
        accMap.put('Name', a);
        Test.startTest();
        Boolean bool = UTIL_System.matches(a, accMap);
        Test.stopTest();
        System.assertEquals(false, bool);
        System.debug('bool is ' + bool);
    }
    
    static testmethod void testfindWhere() {
        Account a = new Account(Name='Test');
        List<Account> accList = new List<Account>();
        accList.add(a);
        Test.startTest();
        List<Account> aList = UTIL_System.findWhere(accList,'Name','Test');
        Test.stopTest();
        System.assertEquals(1, aList.size());
    }

    static testmethod void testfindWhereIn() {
        Account a = new Account(Name='Test');
        List<Account> accList = new List<Account>();
        List<String> sList = new List<String>();
        accList.add(a);
        sList.add('Test');
        Test.startTest();
        List<Account> aList = UTIL_System.findWhereIn(accList,'Name',sList);
        Test.stopTest();
        System.assertEquals(1, aList.size());
    }

    @isTest
    static void testAddress()
    {
        Account testAccount = TestDataFactory.createTestAccounts(1, 0, 'GAU')[0];
        testAccount.ShippingStreet = '1 First Rd';
        testAccount.ShippingCity = 'Midrand';
        testAccount.ShippingState = 'Gauteng';
        testAccount.ShippingCountry = 'South Africa';
        testAccount.ShippingPostalCode = '1685';

        update testAccount;

        Test.startTest();

        String result = UTIL_System.addressConversion(testAccount, Account.ShippingAddress.getDescribe().getLocalName());

        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('1 First Rd, Midrand, Gauteng, 1685', result);
    }

    @isTest
    static void testNullString()
    {
        String[] testArray = new String[]{al.StringUtils.EMPTY, 'mjbu', null, '1111', ' '};

        Test.startTest();

        String[] resultArray = UTIL_System.nullSafeString(testArray);

        Test.stopTest();

        System.assertEquals(testArray.size(), resultArray.size());
        System.assertEquals(5, resultArray.size());
        System.assertEquals(testArray[0], resultArray[0]);
        System.assertEquals(testArray[1], resultArray[1]);
        System.assertEquals(testArray[3], resultArray[3]);
        System.assertEquals(testArray[4], resultArray[4]);

        System.assertNotEquals(null, resultArray[2]);
    }
}