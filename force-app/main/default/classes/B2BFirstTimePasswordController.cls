public with sharing class B2BFirstTimePasswordController {
    @AuraEnabled
    public static String createFirstTimePassword(Id contactId) {
        try {
            return B2BFirstTimePasswordService.createFirstTimePassword(contactId);
        } catch (Exception e) {
            throw new AuraHandledException('Error creating password : ' + e.getMessage());
        }
    }
}