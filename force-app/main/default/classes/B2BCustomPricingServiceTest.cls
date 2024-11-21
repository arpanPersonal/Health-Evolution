@IsTest
public class B2BCustomPricingServiceTest {
    @TestSetup
    static void setupTestData() {
          Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1]; 
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
         Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Fellow_Level__c = 'Innovator Fellowship'
        );
        insert testContact;
         // Create a unique username
        String uniqueUsername = 'testuser' + Datetime.now().getTime() + '@example.com';
        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser = new User(
                FirstName = 'Test12',
                LastName = 'User',
                Username = uniqueUsername,
                Email = 'testuser@example.com',
                Alias = 'testusr',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                ContactId = testContact.Id,
                LanguageLocaleKey = 'en_US'
            );
            insert testUser;
        }

        String currentUserId = testUser.Id;
     
        // Create Fellowship_Price__c records
        Product2 testProduct1 = new Product2(Name = 'Product 1');
        insert testProduct1;
        Product2 testProduct2 = new Product2(Name = 'Product 2');
        insert testProduct2;

        Fellowship_Price__c price1 = new Fellowship_Price__c(
            Price__c = 100,
            ProductId__c = testProduct1.Id,
            Fellowship__c = 'Innovator Fellowship'
        );
        Fellowship_Price__c price2 = new Fellowship_Price__c(
           // Fellowship__c = 'Fellowship',
            Price__c = 200,
            ProductId__c = testProduct2.Id
        );
        insert price1;
        insert price2;

        
    }
    
    @IsTest
    static void testProcessPrice() {
        setupTestData();
        User userId = [SELECT Id FROM User WHERE FirstName = 'Test12' LIMIT 1 ];
        Product2 testProduct1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1' LIMIT 1] ;
        Product2 testProduct2 = [SELECT Id FROM Product2 WHERE Name = 'Product 2' LIMIT 1] ;
        // Prepare a PricingRequest
        commercestorepricing.PricingRequestItem item1 = new commercestorepricing.PricingRequestItem(testProduct1.Id);
        	
        commercestorepricing.PricingRequestItem item2 = new commercestorepricing.PricingRequestItem(testProduct2.Id);
       

        List<commercestorepricing.PricingRequestItem> items = new List<commercestorepricing.PricingRequestItem>();
        items.add(item1);
        items.add(item2);

        commercestorepricing.PricingRequest request = new commercestorepricing.PricingRequest();
        request.addPricingRequestItem(item1);

        // Call the processPrice method
        System.runAs(userId){
        B2BCustomPricingService pricingService = new B2BCustomPricingService();
      
        commercestorepricing.PricingResponse response = pricingService.processPrice(request);
        
        // Assert the response contains the correct prices
        System.assertEquals(1, response.getPricingResponseItems().size(), 'Expected 1 pricing response items');
        //System.assertEquals(100, response.getPricingResponseItems().get(0).getPrice(), 'Expected price for product 1 to be 100');
       // System.assertEquals(200, response.getPricingResponseItems().get(1).getPrice(), 'Expected price for product 2 to be 200');
        }
    }

    @IsTest static void testProcessTransactionalPrice() {

        User userId = [SELECT Id FROM User WHERE FirstName = 'Test12' LIMIT 1 ];
        Product2 testProduct1 = [SELECT Id FROM Product2 WHERE Name = 'Product 1' LIMIT 1] ;

        commercestorepricing.TransactionalPricingRequest request = new commercestorepricing.TransactionalPricingRequest();

        commercestorepricing.TransactionalPricingResponse response;
        Test.startTest();
        System.runAs(userId){
            try{
                B2BCustomPricingService pricingService = new B2BCustomPricingService();
                response = pricingService.processTransactionalPrice(request);
            }
            catch(Exception e) {
                System.debug('##Exception: '+ e.getMessage());
            }
        }
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
    } 

}