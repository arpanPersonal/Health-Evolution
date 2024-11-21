@IsTest
public class B2BHistSubsPaymentLinksTest {
    @TestSetup static void makeData(){

        Account account = new Account(Name = 'Test Account');
        insert account;
        
         Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = account.Id
        );
        insert contact;

        Subscription__c s_Annual = new Subscription__c();
        s_Annual.Name = 'Test Annual Subcription';
        s_Annual.Contact__c = contact.Id;
        s_Annual.Historical_Subscription__c = true;
        s_Annual.Type__c = '3 Year Annual';
        s_Annual.Additional_Email_For_Payment__c = 'test@testmail.com';
        s_Annual.Annual_Payment_Amount__c = 1234;
        s_Annual.Total_Amount__c = 20750;
        s_Annual.Next_Payment_Date__c = System.today().addDays(30);
        s_Annual.Status__c = 'Active';
        s_Annual.Payments_Made__c = 0;
        s_Annual.Inital_Payment_Amount__c = 6750;
        s_Annual.Start_Date__c = System.today();
        s_Annual.End_Date__c = System.today().addDays(60);
        
        insert s_Annual;

        Subscription__c s_upfront = new Subscription__c();
        s_upfront.Name = 'Test Upfront Subcription';
        s_upfront.Contact__c = contact.Id;
        s_upfront.Historical_Subscription__c = true;
        s_upfront.Type__c = '2 Year Upfront';
        s_upfront.Additional_Email_For_Payment__c = 'test@testmail.com';
        s_upfront.Annual_Payment_Amount__c = 1234;
        s_upfront.Total_Amount__c = 20750;
        s_upfront.Next_Payment_Date__c = System.today().addDays(30);
        s_upfront.Status__c = 'Active';
        s_upfront.Payments_Made__c = 0;
        s_upfront.Inital_Payment_Amount__c = 6750;
        s_upfront.Start_Date__c = System.today();
        s_upfront.End_Date__c = System.today().addDays(60);
        
        insert s_upfront;

        MerchantAccount merchantAccount = new MerchantAccount();
        merchantAccount.Name = 'Test Merchant Account';
        merchantAccount.Status = 'Complete';
        merchantAccount.CountryIsoCode = 'US';
        merchantAccount.PaymentStatus = 'Enabled';
        merchantAccount.PayoutStatus = 'Enabled';

        Organization org = [Select Id, Name, IsSandbox from Organization LIMIT 1];
        if(org.IsSandbox){
            merchantAccount.Mode = 'Test';
            insert merchantAccount;
        }
        else{
            merchantAccount.Mode = 'Live';
            insert merchantAccount; 
        }

        MerchAccPaymentMethodSet paymentMethod = new MerchAccPaymentMethodSet(
            DeveloperName = 'AMER-CC',
            MerchantAccountId = merchantAccount.Id
        );
        insert paymentMethod;
    }

    @isTest static void testBatchableWithRecordId_Annual() {
        // Retrieve test data
        Subscription__c testSubscription = [SELECT Id FROM Subscription__c WHERE Name = 'Test Annual Subcription' LIMIT 1 ];

        Test.startTest();
        B2BCreateHistrorcialSubs_PaymentLinks batch = new B2BCreateHistrorcialSubs_PaymentLinks(testSubscription.Id);
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest static void testBatchableWithRecordId_Upfront() {
        // Retrieve test data
        Subscription__c testSubscription = [SELECT Id FROM Subscription__c WHERE Name = 'Test Upfront Subcription' LIMIT 1 ];

        Test.startTest();
        B2BCreateHistrorcialSubs_PaymentLinks batch = new B2BCreateHistrorcialSubs_PaymentLinks(testSubscription.Id);
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testBatchableWithoutRecordId() {
        Test.startTest();
        B2BCreateHistrorcialSubs_PaymentLinks batch = new B2BCreateHistrorcialSubs_PaymentLinks();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
}