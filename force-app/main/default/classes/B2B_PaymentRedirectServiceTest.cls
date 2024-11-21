@isTest
public class B2B_PaymentRedirectServiceTest {

    /*@testSetup
    static void setup() {
        // Create necessary test data
		Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName='Doe', FirstName='John', Email='john.doe@example.com', Phone='555-555-5555', AccountId=testAccount.Id);
        insert testContact;
        
        Opportunity testOpportunity = new Opportunity(Name='Test Opportunity', StageName='Closed Won', CloseDate=Date.today(), AccountId=testAccount.Id);
        insert testOpportunity;
        
        Product2 laptopProduct = new Product2(Name='Laptop', IsActive=true);
        insert laptopProduct;
         Pricebook2 standardPricebook =new Pricebook2(Name= 'testPricebook',IsActive = true);
        insert standardPricebook;
//        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
        
        PricebookEntry laptopPricebookEntry = new PricebookEntry(Pricebook2Id=standardPricebook.Id, Product2Id=laptopProduct.Id, UnitPrice=1000, IsActive=true);
        insert laptopPricebookEntry;
        
        Order order = new Order(AccountId = testAccount.Id ,OpportunityId=testOpportunity.Id, EffectiveDate=Date.today(), Status='Draft', Pricebook2Id=standardPricebook.Id);
        insert order; 
        
        orderDeliveryMethod odm = new orderDeliveryMethod(Name = 'Test method',ProductId = laptopProduct.Id);
        insert odm;
        
         OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(OrderId = order.Id, OrderDeliveryMethodId = odm.Id, DeliverToName = 'Test Name');
        insert orderDeliveryGroup;
        
        OrderItem orderItem = new OrderItem(OrderId=order.Id, PricebookEntryId=laptopPricebookEntry.Id, Quantity=2, Product2Id = laptopProduct.Id,UnitPrice= 100.00, OrderDeliveryGroupId = orderDeliveryGroup.Id);
        insert orderItem;
            
        order.Status = 'Activated';
		update order;
        
        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=order.Id; 
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        system.debug('subhahsis osor'+osor);
        system.debug('subhahsis osor'+osor.orderSummaryId);
        

        // Subscription__c record linked to OrderSummary
        Subscription__c subscription = new Subscription__c(
            Order_Item_Summary__c = osor.orderSummaryId
        );
        insert subscription;

        // PaymentLink record linked to Subscription__c
        PaymentLink paymentLink = new PaymentLink(
            //PaymentUrl = 'https://paymentlink.com',
            Subscription__c = subscription.Id,
            Payment_Year__c = 'Year 1',
            Status = 'Active'
        );
        insert paymentLink;
    }*/

    @isTest(SeeAllData = true)
    static void testGetPaymentLinkSuccess() {
        // Prepare test data
        //setup();
         // Create necessary test data
		Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName='Doe', FirstName='John', Email='john.doe@example.com', Phone='555-555-5555', AccountId=testAccount.Id);
        insert testContact;
        
        Opportunity testOpportunity = new Opportunity(Name='Test Opportunity', StageName='Closed Won', CloseDate=Date.today(), AccountId=testAccount.Id);
        insert testOpportunity;
        
        Product2 laptopProduct = new Product2(Name='Laptop', IsActive=true);
        insert laptopProduct;
         //Pricebook2 standardPricebook =new Pricebook2(Name= 'testPricebook',IsActive = true);
        //insert standardPricebook;
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
        
        PricebookEntry laptopPricebookEntry = new PricebookEntry(Pricebook2Id=standardPricebook.Id, Product2Id=laptopProduct.Id, UnitPrice=1000, IsActive=true);
        insert laptopPricebookEntry;
        
        Order order = new Order(AccountId = testAccount.Id ,OpportunityId=testOpportunity.Id, EffectiveDate=Date.today(), Status='Draft', Pricebook2Id=standardPricebook.Id);
        insert order; 
        
        orderDeliveryMethod odm = new orderDeliveryMethod(Name = 'Test method',ProductId = laptopProduct.Id);
        insert odm;
        
         OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(OrderId = order.Id, OrderDeliveryMethodId = odm.Id, DeliverToName = 'Test Name');
        insert orderDeliveryGroup;
        
        OrderItem orderItem = new OrderItem(OrderId=order.Id, PricebookEntryId=laptopPricebookEntry.Id, Quantity=2, Product2Id = laptopProduct.Id,UnitPrice= 100.00, OrderDeliveryGroupId = orderDeliveryGroup.Id);
        insert orderItem;
            
        order.Status = 'Activated';
		update order;
        
        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=order.Id; 
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        system.debug('subhahsis osor'+osor);
        system.debug('subhahsis osor'+osor.orderSummaryId);
        
        OrderItemSummary oItem = [Select Id from OrderItemSummary where OrderSummaryId =: osor.orderSummaryId Limit 1];
        

        // Subscription__c record linked to OrderSummary
        Subscription__c subscription = new Subscription__c(
            Order_Item_Summary__c = oItem.Id,
            Name = 'test',
            Status__c = 'Active'
        );
        insert subscription;
        
        

        
        List<OrderSummary> od = [Select Id,OrderNumber FROM OrderSummary WHERE Id =: osor.orderSummaryId LIMIT 1];
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('recordId', od[0].OrderNumber);

        // Call the method
        Map<String, Object> result = B2B_PaymentRedirectService.getPaymentLink(mapParams);

        // Assertions

        //System.assert(result.containsKey('paymentObj'));
    }

    @isTest
    static void testGetPaymentLinkNoRecordId() {
        // Prepare test data
        Map<String, Object> mapParams = new Map<String, Object>();

        // Call the method
        Map<String, Object> result = B2B_PaymentRedirectService.getPaymentLink(mapParams);

        // Assertions

    }

    @isTest
    static void testGetPaymentLinkNoOrderSummary() {
        // Prepare test data
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('recordId', 'ORD99999'); // non-existing order number

        // Call the method
        Map<String, Object> result = B2B_PaymentRedirectService.getPaymentLink(mapParams);

        // Assertions

    }

   /* @isTest
    static void testGetPaymentLinkInvoiceOrder() {
        // Insert OrderSummary with Invoice_Order__c = true
        OrderSummary orderSummaryInvoice = new OrderSummary(
            OrderNumber = 'ORDINVOICE',
            Invoice_Order__c = true
        );
        insert orderSummaryInvoice;

        // Prepare test data
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('recordId', 'ORDINVOICE');

        // Call the method
        Map<String, Object> result = B2B_PaymentRedirectService.getPaymentLink(mapParams);

        // Assertions
        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals('Invoice order - no redirection to payment link', result.get('message'));
    }*/

   /* @isTest
    static void testGetPaymentLinkNoSubscription() {
        // Insert OrderSummary with no linked Subscription__c
        OrderSummary orderSummaryNoSub = new OrderSummary(
            OrderNumber = 'ORDNOSUB',
            Invoice_Order__c = false
        );
        insert orderSummaryNoSub;

        // Prepare test data
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('recordId', 'ORDNOSUB');

        // Call the method
        Map<String, Object> result = B2B_PaymentRedirectService.getPaymentLink(mapParams);

        // Assertions
        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals('', result.get('message'));
    }*/

    /*@isTest
    static void testGetPaymentLinkNoPaymentLink() {
        // Insert OrderSummary and Subscription__c without PaymentLink
        OrderSummary orderSummaryNoPayment = new OrderSummary(
            OrderNumber = 'ORDNOPAYMENT',
            Invoice_Order__c = false
        );
        insert orderSummaryNoPayment;

        Subscription__c subscriptionNoPayment = new Subscription__c(
            Order_Item_Summary__c = orderSummaryNoPayment.Id
        );
        insert subscriptionNoPayment;

        // Prepare test data
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('recordId', 'ORDNOPAYMENT');

        // Call the method
        Map<String, Object> result = B2B_PaymentRedirectService.getPaymentLink(mapParams);

        // Assertions
        System.assertEquals(false, result.get('isSuccess'));
        System.assertEquals('no payment links found', result.get('message'));
    }*/
}