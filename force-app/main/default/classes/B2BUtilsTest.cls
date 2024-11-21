@IsTest
public class B2BUtilsTest {
     
    @TestSetup static void makeData() {

        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;

        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Contact contact = new Contact(
               FirstName = 'Test',
               LastName = 'User',
               AccountId = account.Id,
               Email = System.now().millisecond() + 'test@test.com'
        );
        insert contact;

        //Create Community User
        String profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1].Id;
        User u = new User(
            Alias = 'Test',
            CommunityNickname = 'Test',
            ContactId = contact.Id,
            Email = contact.Email,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LastName = contact.LastName,
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/New_York',
            Username = 'testuser@gmail.com'
        );
        insert u;
    }

    @IsTest static void testGetUserAccountID() {

        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        String result;
        Test.startTest();
        System.runAs(user) {
            result = B2BUtils.getUserAccountID();
        }
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'AccountId should not be null');
    }

    @IsTest static void testGetUserContactID() {

        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        String result;
        Test.startTest();
        System.runAs(user) {
            result = B2BUtils.getUserContactID();
        }
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'ContactId should not be null');
    }

    @IsTest static void testGetAccountActiveOrCheckoutWebCart() {

        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        //Insert Webcart
        String accountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        String webStoreId = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1].Id;
        Webcart wc = new WebCart(
            Name = 'Test WebCart',
            Status = 'Active',
            AccountId = accountId,
            OwnerId = user.Id,
            WebStoreId = webStoreId
        );
        insert wc;

        String result;
        Test.startTest();
        System.runAs(user) {
            result = B2BUtils.getAccountActiveOrCheckoutWebCart();
        }
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'CartId should not be null');
    }

    @IsTest static void testGetAccountActiveOrCheckoutWebCart_null() {

        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        String result;
        Test.startTest();
        System.runAs(user) {
            result = B2BUtils.getAccountActiveOrCheckoutWebCart();
        }
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null');
    }
}