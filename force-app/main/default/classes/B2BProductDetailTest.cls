@IsTest
public class B2BProductDetailTest {

    @TestSetup static void makeData() {

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

        Product2 product = new Product2(
            IsActive = true,
            Name = 'Test Product1', 
            Family = 'TestClass'
        );
        insert product;

        Fellowship_Price__c fellowPrice = new Fellowship_Price__c(
            Price__c = 5000,
            Renewal_Price__c = 4500,
            Initial_Payment_Amount__c = 2500,
            Paid_Upfront__c = false,
            ProductId__c  = product.Id
        );
        insert fellowPrice;

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

    @IsTest
    public static void testGetFellowPrice_null() {

        String productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1].Id;
        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        B2BProductDetail.FellowshipPriceWrapper result;
        Test.startTest();
        System.runAs(user) {
            result = B2BProductDetail.getFellowPrice(productId);
        }
        Test.stopTest();

        System.assertEquals(null, result, 'Result should be null');
    }

    @IsTest
    public static void testGetFellowPrice() {
        
        String productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product1' LIMIT 1].Id;
        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];

        Fellowship_Price__c fsp = [SELECT Id, Price__c, Fellowship__c FROM Fellowship_Price__c WHERE Paid_Upfront__c = false LIMIT 1];
        fsp.Fellowship__c = 'Innovator Fellowship';
        update fsp;

        B2BProductDetail.FellowshipPriceWrapper result;
        Test.startTest();
        System.runAs(user) {
            result = B2BProductDetail.getFellowPrice(productId);
        }
        Test.stopTest();

        System.assertEquals(fsp.Price__c, result.totalPrice, 'Price should match');
    }
}