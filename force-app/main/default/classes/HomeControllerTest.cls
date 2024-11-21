@isTest
public class HomeControllerTest {
    @isTest(SeeAllData=true)
    public static void getTestData(){
        
        
        Account acc = new Account();
        acc.Name = 'Community Account';
        Insert acc;
        
        Contact commcon = new Contact();
        commcon.FirstName = 'Community';
        commcon.LastName = 'Contact';
        commcon.Email = 'test@gmail.com';
        commcon.Title = 'Dev';
        commcon.Company_Name__c = 'Test Pvt Ldt';
        commcon.AccountID = acc.Id;
        commcon.Areas_of_Interest__c='Care Delivery Redesign';
        Insert commcon;
        
        list<String> areaofinterestlist = new  list<String>();
        areaofinterestlist.add(commcon.Areas_of_Interest__c);
        
        Roundtable_Data__c rt = new Roundtable_Data__c();
        rt.Name = 'AI and Data-Powered Innovation';
        rt.Sub_Heading__c = 'Realizing the promise of big data in an evolving landscape';
        rt.LinkedIn_URL__c = 'https://www.linkedIn.com/groups/9229361/';
        insert rt;
        
        Contact_Roundtable__c crt = new Contact_Roundtable__c();
        crt.Contact__c = commcon.Id;
        crt.Roundtable_Data__c = rt.Id;
        insert crt;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Customer Community Login User2' Limit 1];
        
        User u = new User();
        u.FirstName = 'Community ';
        u.LastName = 'Contact';
        u.ContactId = commcon.Id;
        u.Alias = 'test123';
        u.email = 'test@gmail.com';
        u.ProfileId = portalProfile.Id;
        u.EmailEncodingKey = 'UTF-8';
        u.CommunityNickname = 'test12345';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.UserName = 'test@gmail.com';
        insert u;
        
        Event eventobj = new Event(Session__c = 'Demo', subject = 'Meeting',WhoId=commcon.Id,IsVisibleInSelfService=true,DurationInMinutes=50,ActivityDateTime=date.valueOf('2023-02-28'));
        insert eventobj;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = commcon.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
        
        Roundtable_Data__c getroundtabledata= HomeController.getRoundtable(rt.Id);
        List<Contact> conlist = HomeController.getContacts(rt.Id);
        List<User> uerlist = HomeController.fellowInformation(u.Id);
        List<Contact_Roundtable__c> crtlist = HomeController.getContactslist(rt.Id);
        List<Event> eventlist = HomeController.getRoundTableEvents(rt.Id,u.id);
        Boolean currentcrtval = HomeController.CurrentRoundtable(rt.Id);
        List<User> fellowlist = HomeController.fellowInformation(u.Id);
        List<Contact> contlist = HomeController.getContacts(rt.Id);
        HomeController.sendEmail(u.id);
        String updatecontcheck = HomeController.updateContactcheck(true,u.Id);
        String updatecontcheckfalse = HomeController.updateContactcheck(false,u.Id);
        List<ContentDocumentLink> contdoclinklist = HomeController.getRoundtableFiles(rt.Id);
        List<Contact_Roundtable__c> crtlistval = HomeController.getRoundtableslist(u.Id);
        List<User> usercondocval = HomeController.setUserPhoto(documents[0].Id);
        String downloadattachId = HomeController.DownloadAttachment(documents[0].Id);
        /*UpdateContactFromCommunityBatch obj = new UpdateContactFromCommunityBatch(true,commcon.Id);
        DataBase.executeBatch(obj);*/
        List<String> aoilist =HomeController.getFellowInfoWithAOI();
        String userid = u.Id;
        String uaoi =HomeController.UpdateAreaOfInterest(userid,areaofinterestlist);
        Test.stopTest();  
        
    }
    
}