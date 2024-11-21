public class B2BFirstTimePasswordService {
    public static String createFirstTimePassword(Id contactId) {
        // Get the associated user for the contact
        
        Contact contact = [SELECT Id, OwnerId FROM Contact WHERE Id = :contactId LIMIT 1];
        User user = [SELECT Id, Username FROM User WHERE Id = :contact.OwnerId LIMIT 1];
        Id UserId = user.Id;
        
        String password = B2BFirstTimePasswordHelper.generateRandomPassword(8);
        //System.setPassword(user.Id, password);
        if(password!= null)
            try{
                UserPasswordGenerateQueueable passwordUpdateJob = new UserPasswordGenerateQueueable(contactId, password,UserId);
                System.enqueueJob(passwordUpdateJob);
                contact.FirstTimePassword__c = password;
                update contact;
                
            }catch(Exception e){
                System.debug('Error updating user password: ' + e.getMessage());
            }
        return password;
    }
}