public class InsertNewUser {
   @future
   public static void createPortalUser(Id ContactId) {
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Health Evolution Partner Portal Profile' LIMIT 1];

        User portalUser = new User(
            FirstName = 'Portal',
            LastName = 'User',
            Email = 'portaluser_' + System.currentTimeMillis() + '@example.com',
            Username = 'portaluser_' + System.currentTimeMillis() + '@example.com',
            Alias = 'pUser',
            ProfileId = portalProfile.Id,
            UserRoleId = portalRole.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ContactId = ContactId
          
        );

        insert portalUser;
        portalUser.IsPortalEnabled = true;
        update portalUser;
    }
}