@IsTest
public class B2BProductHelperTest {
    
    @TestSetup static void makeData() {

        Product2 product = new Product2(
            IsActive = true,
            Name = 'Test Product1', 
            Family = 'TestClass',
            StockKeepingUnit = 'test'
        );
        insert product;

        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Contact contact = new Contact(
               FirstName = 'Test',
               LastName = 'User',
               AccountId = account.Id,
               Email = System.now().millisecond() + 'test@test.com',
               Fellow_Level__c = 'Innovator Fellowship'
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

        Fellowship_Price__c fellowPrice = new Fellowship_Price__c(
            Price__c = 5000,
            Renewal_Price__c = 4500,
            Initial_Payment_Amount__c = 2500,
            Paid_Upfront__c = false,
            ProductId__c  = product.Id,
            Fellowship__c = 'Innovator Fellowship'
        );
        insert fellowPrice;
    }

    @IsTest static void testGetPricingResponseItem() {

        String productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1].Id;
        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        B2BProductHelper.ProductValidation result;
        Test.startTest();
        System.runAs(user) {
            result = B2BProductHelper.getPricingResponseItem(productId);
        }
        Test.stopTest();
        
        System.assertEquals(true, result.isValid, 'Response should be valid');
    }

    @IsTest static void testGetPricingResponseItem_noSKU() {

        String productId = null;
        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        B2BProductHelper.ProductValidation result;
        Test.startTest();
        System.runAs(user) {
            result = B2BProductHelper.getPricingResponseItem(productId);
        }
        Test.stopTest();
        
        System.assertEquals(false, result.isValid, 'Response should not be valid');
    }

    @IsTest static void testGetPricingResponseItem_exception() {

        String productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1].Id;
        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        B2BProductHelper.ProductValidation result;
        Test.startTest();
        try{
            result = B2BProductHelper.getPricingResponseItem(productId);
        }
        catch(Exception e) {
            System.debug('##Exception: ' + e.getMessage());
        }
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null');
    }
}