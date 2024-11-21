@isTest
public class B2BCheckoutHelperTest {

    @isTest
    static void testSetCartDeliveryGroup() {
        // Setup test data
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
        
         WebCart testCart = new WebCart(
            Name = 'Test Cart',
            AccountId = testAccount.Id,
              WebStoreId = testWebStore.Id,
              PoNumber = null,
            
            Status = 'Active'
        );
        insert testCart;
        
        CartDeliveryGroup cdg = new CartDeliveryGroup(
            Name = 'testcartdeliveryGroup',
            CartId = testCart.Id, // assuming a CartId is required
            DeliveryMethodId = null,
            DeliverToName = null
        );
        insert cdg;

        OrderDeliveryMethod odm = new OrderDeliveryMethod(
            Name = 'Test Delivery Method' // assuming a Name is required
        );
        insert odm;

        // Call the method to be tested
        Test.startTest();
        String resultId = B2BCheckoutHelper.setCartDeliveryGroup(cdg.CartId);
        Test.stopTest();

        // Verify the results
        CartDeliveryGroup updatedCdg = [SELECT Id, DeliveryMethodId, DeliverToName FROM CartDeliveryGroup WHERE Id = :cdg.Id];
        System.assertEquals('Placeholder Name', updatedCdg.DeliverToName, 'DeliverToName should be updated to "Placeholder Name"');
        System.assertEquals(odm.Id, updatedCdg.DeliveryMethodId, 'DeliveryMethodId should be updated to the Id of the inserted OrderDeliveryMethod');

        WebCart updatedWc = [SELECT Id, PoNumber FROM WebCart WHERE Id = :testCart.Id];
        System.assertEquals('NA', updatedWc.PoNumber, 'PoNumber should be updated to "NA"');

        System.assertEquals(cdg.Id, resultId, 'Returned Id should match the Id of the updated CartDeliveryGroup');
    }
}