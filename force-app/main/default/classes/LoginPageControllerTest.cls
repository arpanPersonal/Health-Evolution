@isTest
public class LoginPageControllerTest {
    @IsTest(SeeAllData=true)
    Public static void testGetContactDataMethod()
    {
        
        Account Ac = new Account();
        Ac.Name = 'Community Account';
        Insert Ac;
        
        Contact CommunityContactData = new Contact();
        CommunityContactData.FirstName = 'Community';
        CommunityContactData.LastName = 'Contact';
        CommunityContactData.Salutation = 'Mr.';
        CommunityContactData.Email = 'test@gmail.com';
        CommunityContactData.Title = 'Dev';
        CommunityContactData.Company_Name__c = 'Test Pvt Ldt';
        CommunityContactData.AccountID = Ac.Id;
        Insert CommunityContactData;
        
        
        Roundtable_Data__c RD = new Roundtable_Data__c();
        RD.Name = 'AI and Data-Powered Innovation';
        Insert RD;
        
        Roundtable_Data__c RD1 = new Roundtable_Data__c();
        RD1.Name = 'Innovations in Mental and Behavioral Health';
        Insert RD1;
        
        Roundtable_Data__c RD2 = new Roundtable_Data__c();
        RD2.Name = 'Value-Based Care For Specialized Populations';
        Insert RD2;
        
        Roundtable_Data__c RD3 = new Roundtable_Data__c();
        RD3.Name = 'Scalable Drivers of Health Approaches';
        Insert RD3;
        
        
        Roundtable_Data__c RD4 = new Roundtable_Data__c();
        RD4.Name = 'Data-Driven Health Equity Strategies';
        Insert RD4;
        
        Roundtable_Data__c RD5 = new Roundtable_Data__c();
        RD5.Name = 'Integrated Home-Based Care Models';
        Insert RD5;
        
        Roundtable_Data__c RD6 = new Roundtable_Data__c();
        RD6.Name = 'Digital-Forward Consumer Experience';
        Insert RD6;
        
        Roundtable_Data__c RD7 = new Roundtable_Data__c();
        RD7.Name = 'Personalized Health Ecosystem';
        Insert RD7;
        
        Roundtable_Data__c RD8 = new Roundtable_Data__c();
        RD8.Name = 'Confab for Advancing Women in Leadership';
        Insert RD8;
        
        Roundtable_Data__c RD9 = new Roundtable_Data__c();
        RD9.Name = 'Commercial Risk-Based Contracting';
        Insert RD9;
        
        
        Contact_Roundtable__c CR = new Contact_Roundtable__c();
        CR.Contact__c = CommunityContactData.Id;
        CR.Roundtable_Data__c = RD9.Id;
        
        Integer pageNumber =1;  Integer pageSize = 10;
        
        List<String> roundtableNames =new List<String>();
        roundtableNames.add(RD1.Name);
        roundtableNames.add(RD2.Name);
        roundtableNames.add(RD3.Name);
        roundtableNames.add(RD4.Name);
        roundtableNames.add(RD5.Name);
        roundtableNames.add(RD6.Name);
        roundtableNames.add(RD7.Name);
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Customer Community Login User2' Limit 1];
        
        User u = new User();
        u.FirstName = 'Community ';
        u.LastName = 'Contact';
        u.ContactId = CommunityContactData.Id;
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
        
        Event eventobj = new Event(Session__c = 'Demo', subject = 'Meeting',WhoId=CommunityContactData.Id,IsVisibleInSelfService=true,DurationInMinutes=50,ActivityDateTime=date.valueOf('2023-02-28'),StartDateTime=date.valueOf('2023-02-28'));
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
        cdl.LinkedEntityId = CommunityContactData.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        String eid = String.valueOf(eventobj.Id);
        String eDate = String.valueOf(eventobj.StartDateTime);
        
        Event eventobjNew = new Event(Session__c = 'Demo', subject = 'Meeting',WhoId=CommunityContactData.Id,IsVisibleInSelfService=true,DurationInMinutes=50,ActivityDateTime=date.valueOf('2023-02-28'),StartDateTime=date.valueOf('2023-02-28'));
        String eventString = JSON.serialize(eventobjNew);
        
        Test.startTest();
        LoginPageController.getContactData(pageNumber,pageSize,roundtableNames);
        LoginPageController.verifyUser('test@gmail.com','test@123','https://healthevolution--imgcloud.sandbox.my.site.com/healthRevolution');
        LoginPageController.forgetPassword('test@gmail.com');
        LoginPageController.ScheduleRoundtableData(u.Id);
        LoginPageController.ShowRoundtableData(roundtableNames);
        LoginPageController.setUserPhoto(documents[0].Id);
        LoginPageController.downloadFile('');
        LoginPageController.getAllEvents();
        LoginPageController.getAllRoundtableName();
        LoginPageController.getFellosData(CommunityContactData.Id);
        
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    Public static void Negativetest()
    {
        Test.startTest();
        LoginPageController.forgetPassword('');
        LoginPageController.verifyUser('','','');
        LoginPageController.ScheduleRoundtableData('');
        Test.stopTest();
        
    }
    
}