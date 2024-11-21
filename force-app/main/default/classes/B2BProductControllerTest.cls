@isTest
public class B2BProductControllerTest {
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
    
    
    @IsTest static void testMethod1() {
        Product2 pr = [Select Id From Product2 Limit 1];
        User user = [SELECT Id FROM User WHERE Username = 'testuser@gmail.com' LIMIT 1];
        
        B2BProductHelper.ProductValidation result;
        Boolean res;
        Test.startTest();
        System.runAs(user) {
            
            result = B2BProductController.getPricingResponseItem(pr.Id);
            res = B2BProductController.doesProductHasPrice(pr.Id);
        }
        Test.stopTest();
    }
}