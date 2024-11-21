public class UserPasswordGenerateQueueable implements Queueable {

    private Id contactId;
    private String password;
    private Id userId;

    // Constructor to pass parameters
    public UserPasswordGenerateQueueable(Id contactId, String password,Id UserId) {
        this.contactId = contactId;
        this.password = password;
        this.userId = UserId;
    }
    // Execute method that runs in the background
    public void execute(QueueableContext context) {
        // Get the user associated with the contact
        User user = [SELECT Id FROM User WHERE Id = :userId LIMIT 1];

        // Check if a User is found
        if (user != null) {
            try {
                // Set the password for the user
                System.setPassword(user.Id, password);
            } catch (Exception e) {
                System.debug('Error updating user password: ' + e.getMessage());
            }
        } else {
            System.debug('No user found for the given contact');
        }
    }
}