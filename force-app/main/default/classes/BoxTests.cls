@isTest
public class BoxTests {
    // Mock class to handle the HTTP callouts
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    static void setupTestData() {
        // Insert test data for Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert testAccount2;

        // Insert test data for Opp
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity 1', AccountId=testAccount.Id, StageName='Target', CloseDate=Date.newInstance(2024, 10, 6));
        insert testOpp;
        testOpp.Name = 'Testing Opportunity 1';
        update testOpp;

        // Insert test data for Lead
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Test Contact 1', AccountId=testAccount.Id);
        insert testContact;
        testContact.FirstName = 'testing';
        update testContact;

        // Insert test data for box__FRUP__c
        box__FRUP__c testFrup = new box__FRUP__c(box__object_name__c = 'Account', box__record_id__c = testAccount.Id, box__folder_id__c = '12345');
        insert testFrup;
                
        box__FRUP__c testFrup2 = new box__FRUP__c(box__object_name__c = 'Contact', box__record_id__c = testAccount.Id, box__folder_id__c = '123456');
        insert testFrup2;
        
        box__FRUP__c testFrup3 = new box__FRUP__c(box__object_name__c = 'Opportunity', box__record_id__c = testAccount.Id, box__folder_id__c = '123457');
        insert testFrup3;
    }

    @isTest
    static void testCreateAccountFolder() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Query the Account to get the Id
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        // Call the future method
        Set<String> accIds = new Set<String>{acc.Id};
        BoxFolderHandler.updateAccountName(accIds);
        Test.stopTest();

    }



    @isTest
    static void testBoxAccountTrigger() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        // Insert an Account to fire the trigger
        Account acc = new Account(Name = 'Test Account Trigger');
        insert acc;
        acc.Name = 'test acc';
        update acc;
        Test.stopTest();
        
        box.toolkit bt = new box.Toolkit();
        BoxFolderHandler.renameBoxFolder('1234', 'testing', bt);
        bt.commitChanges();
    }

    @isTest
    static void testBoxFrupTrigger() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        // Insert a box__FRUP__c to fire the trigger
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        box__FRUP__c frup = new box__FRUP__c(box__object_name__c = 'Contact', box__record_id__c = cont.Id, box__folder_id__c = '12345');
        insert frup;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        box__FRUP__c frup2 = new box__FRUP__c(box__object_name__c = 'Opportunity', box__record_id__c = opp.Id, box__folder_id__c = '12345');
        insert frup2;
        Test.stopTest();
    }
    
    @isTest
    static void testMergedAccounts() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert testAccount2;

        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity 1', AccountId=testAccount.Id, StageName='Target', CloseDate=Date.newInstance(2024, 10, 6));
        insert testOpp;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Test Contact 1', AccountId=testAccount.Id);
        insert testContact;

		Database.merge(testAccount2, testAccount, false);
    }
    
    
}