@isTest
public class B2B_SubscriptionPaymentReminderBatchTest {
    @testSetup
    static void setup() {
        // Creating test subscription records with different next payment dates
        Date todayDate = Date.today();
        Date daysRemaining14 = todayDate.addDays(14);
        Date daysRemaining30 = todayDate.addDays(30);
        Date daysRemaining60 = todayDate.addDays(60);
        
        List<Subscription__c> subscriptions = new List<Subscription__c>();
        subscriptions.add(new Subscription__c(Name='Test1', Next_Payment_Date__c = todayDate, Status__c = 'Active', Type__c = '2 Year Annual', Total_Amount__c = 100, Start_Date__c = todayDate, End_Date__c = todayDate.addYears(2)));
        subscriptions.add(new Subscription__c(Name='Test2', Next_Payment_Date__c = daysRemaining14, Status__c = 'Active', Type__c = '2 Year Annual', Total_Amount__c = 200, Start_Date__c = todayDate, End_Date__c = todayDate.addYears(2)));
        subscriptions.add(new Subscription__c(Name='Test3', Next_Payment_Date__c = daysRemaining30, Status__c = 'Active', Type__c = '3 Year Annual', Total_Amount__c = 300, Start_Date__c = todayDate, End_Date__c = todayDate.addYears(3)));
        subscriptions.add(new Subscription__c(Name='Test4', Next_Payment_Date__c = daysRemaining60, Status__c = 'Active', Type__c = '3 Year Annual', Total_Amount__c = 100, Start_Date__c = todayDate, End_Date__c = todayDate.addYears(3)));
        
        insert subscriptions;
    }
    
    @isTest
    static void testSingleRecordBatch() {
        // Fetch a subscription record to test with
        Subscription__c sub = [SELECT Id, Type__c, Total_Amount__c, Start_Date__c, End_Date__c FROM Subscription__c LIMIT 1];
        
        Test.startTest();
        // Execute the controller with a single request
        b2bSubscriptionPaymentReminderController.Requests request = new b2bSubscriptionPaymentReminderController.Requests();
        request.recordId = sub.Id;
        request.type = sub.Type__c;
        request.totalAmount = sub.Total_Amount__c;
        request.startDate = sub.Start_Date__c;
        request.endDate = sub.End_Date__c;
        
        List<b2bSubscriptionPaymentReminderController.Requests> requestList = new List<b2bSubscriptionPaymentReminderController.Requests>();
        requestList.add(request);
        
        List<b2bSubscriptionPaymentReminderController.Results> results = b2bSubscriptionPaymentReminderController.execute(requestList);
        
        Test.stopTest();
        
        // Assertions to verify the behavior
        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0].outputHtml);
    }
    
    @isTest
    static void testMultipleRecordsBatch() {
        List<Subscription__c> subs = [SELECT Id, Type__c, Total_Amount__c, Start_Date__c, End_Date__c FROM Subscription__c LIMIT 4];
        
        List<b2bSubscriptionPaymentReminderController.Requests> requestList = new List<b2bSubscriptionPaymentReminderController.Requests>();
        
        for (Subscription__c sub : subs) {
            b2bSubscriptionPaymentReminderController.Requests request = new b2bSubscriptionPaymentReminderController.Requests();
            request.recordId = sub.Id;
            request.type = sub.Type__c;
            request.totalAmount = sub.Total_Amount__c;
            request.startDate = sub.Start_Date__c;
            request.endDate = sub.End_Date__c;
            requestList.add(request);
        }
        
        Test.startTest();
        List<b2bSubscriptionPaymentReminderController.Results> results = b2bSubscriptionPaymentReminderController.execute(requestList);
        Test.stopTest();
        
        // Verify that subscriptions have been processed
        System.assertEquals(4, results.size());
        for (b2bSubscriptionPaymentReminderController.Results result : results) {
            System.assertNotEquals(null, result.outputHtml);
        }
    }
    
    @isTest
    static void testFinishMethod() {
        
        Test.startTest();
        // Execute the batch to ensure the finish method is called
        B2B_SubscriptionPaymentReminderBatch batch = new B2B_SubscriptionPaymentReminderBatch();
        Database.executeBatch(batch, 4); // Match batch size to the number of test records
        Test.stopTest();
        
        // You can add assertions here if there's any behavior to verify after finish() is called
    }
    
    @isTest
    static void testFinishMethod_constructor() {
         // Fetch a subscription record to test with
        Subscription__c sub = [SELECT Id, Type__c, Total_Amount__c, Start_Date__c, End_Date__c FROM Subscription__c LIMIT 1];
        
        Test.startTest();
        Id recordId = sub.Id;
        B2B_SubscriptionPaymentReminderBatch scheduledBatch = new B2B_SubscriptionPaymentReminderBatch(recordId);
        Database.executeBatch(scheduledBatch, 1);
        Test.stopTest();
        
    }
}