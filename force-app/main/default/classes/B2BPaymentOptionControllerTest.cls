@IsTest
public class B2BPaymentOptionControllerTest {

    @IsTest
    static void testUpdateWebCartPaymentOption() {
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        // Create test data
        WebCart testCart = new WebCart(
            Name = 'Test Cart',
            AccountId = testAccount.Id,
            WebStoreId = testWebStore.Id,
            Status = 'Active');
        insert testCart;

        // Verify initial state
        testCart = [SELECT Id, Invoice_Order__c FROM WebCart WHERE Id = :testCart.Id];
        System.assertEquals(false, testCart.Invoice_Order__c, 'Initially, Invoice_Order__c should be false');

        // Test the controller method with isInvoiceOrder = true
        B2BPaymentOptionController.updateWebCartPaymentOption(testCart.Id, true);

        // Verify the update
        testCart = [SELECT Id, Invoice_Order__c FROM WebCart WHERE Id = :testCart.Id];
        System.assertEquals(true, testCart.Invoice_Order__c, 'Invoice_Order__c should be true after the update');

        // Test the controller method with isInvoiceOrder = false
        B2BPaymentOptionController.updateWebCartPaymentOption(testCart.Id, false);

        // Verify no changes when isInvoiceOrder is false
        testCart = [SELECT Id, Invoice_Order__c FROM WebCart WHERE Id = :testCart.Id];
        System.assertEquals(false, testCart.Invoice_Order__c, 'Invoice_Order__c should be false when isInvoiceOrder is false');
    }
}