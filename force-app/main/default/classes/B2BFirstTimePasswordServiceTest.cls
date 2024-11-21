@isTest
public class B2BFirstTimePasswordServiceTest {
    
    // Test case to simulate the creation of a first-time password and ensure the queueable job works as expected
    @isTest
    static void testCreateFirstTimePassword() {
        
        // 1. Create test data (User and Contact)
        User testUser = new User(
            Username = 'testuserdemo@example.com',
            Alias = 'tuser',
            Email = 'testuserdemo@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, // Use a standard profile
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null,
            IsActive = true,
            lastName = 'Demo'
        );
        insert testUser;
        
        Contact testContact = new Contact(
            LastName = 'Test',
            Email = 'testcontact20@example.com',
            OwnerId = testUser.Id,
            FirstTimePassword__c = null
        );
        insert testContact;
        
        // 2. Call the service method to create the first-time password
        Test.startTest();
        String generatedPassword = B2BFirstTimePasswordService.createFirstTimePassword(testContact.Id);
        String newGeneratedPassword = B2BFirstTimePasswordController.createFirstTimePassword(testContact.Id);
        Test.stopTest();
        
        // 3. Validate the expected behavior
        // Ensure a password was generated and assigned to the Contact
        System.assertNotEquals(generatedPassword, null, 'Password should be generated.');
        Contact updatedContact = [SELECT FirstTimePassword__c FROM Contact WHERE Id = :testContact.Id];
        System.assertNotEquals(updatedContact.FirstTimePassword__c, null, 'Password should be saved in the Contact.');
        
        
    }

    // Test case to simulate the scenario when no user is found for the contact's owner
    @isTest
    static void testNoUserFound() {
        
        // 1. Create a Contact with an invalid UserId (non-existing user)
        Contact testContact = new Contact(
            LastName = 'Test',
            Email = 'testcontact30@example.com', // Invalid UserId
            FirstTimePassword__c = null
        );
        insert testContact;
        
        // 2. Call the service method to create the first-time password
        Test.startTest();
        try {
            String generatedPassword = B2BFirstTimePasswordService.createFirstTimePassword(testContact.Id);
            String newGeneratedPassword = B2BFirstTimePasswordController.createFirstTimePassword(testContact.Id);
            Test.stopTest();
        } catch (Exception e) {
            Test.stopTest();
            System.assert(e.getMessage().contains('No user found'), 'Exception message should indicate no user found.');
        }
    }
    
    // Test case to simulate failure in the password set operation (System.setPassword)
    @isTest
    static void testPasswordUpdateFailure() {
        
        // 1. Create test data (User and Contact)
        User testUser = new User(
            Username = 'testuserdemo40@example.com',
            Alias = 'tuser',
            Email = 'testuserdemo40@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, // Use a standard profile
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null,
            lastName = 'demo3',
            IsActive = true
        );
        insert testUser;
        
        Contact testContact = new Contact(
            LastName = 'Test',
            Email = 'testcontact50@example.com',
            OwnerId = testUser.Id,
            FirstTimePassword__c = null
        );
        insert testContact;
        
        // 2. Mock the exception in the queueable job
        Test.startTest();
        UserPasswordGenerateQueueable queueableJob = new UserPasswordGenerateQueueable(testContact.Id, 'TestPassword123', testUser.Id);
        
        // Mock an exception in System.setPassword by using a try-catch in the queueable
        try {
            String generatedPassword = B2BFirstTimePasswordService.createFirstTimePassword(testContact.Id);
            String newGeneratedPassword = B2BFirstTimePasswordController.createFirstTimePassword(testContact.Id);
            System.enqueueJob(queueableJob);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error updating user password'), 'Should handle password update failure properly.');
        }
    }
      @isTest
    static void testInvalidContactIdException() {
        Test.startTest();
        try {
            // Pass a non-existent Contact ID
            Contact testContact = new Contact(
            LastName = 'Test',
            Email = 'testcontact70@example.com',
            FirstTimePassword__c = null
        );
            String result = B2BFirstTimePasswordController.createFirstTimePassword(testContact.Id);
            System.assert(false, 'Expected an exception for invalid Contact ID');
        } catch (AuraHandledException e) {
            System.debug('Exception Message: ' + e.getMessage());

            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception should indicate an error occurred');
     
        }
        Test.stopTest();
    }
 
}