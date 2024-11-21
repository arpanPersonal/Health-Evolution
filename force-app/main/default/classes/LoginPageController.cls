public without sharing class LoginPageController {
    @AuraEnabled
    public static ContactDataTableWrapper getContactData(Integer pageNumber, Integer pageSize,List<String> roundtableNames) {
        system.debug('name roundtable '+roundtableNames);
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        system.debug('offset '+offset);
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM Contact_Roundtable__c Where Roundtable_Data__r.Name=:roundtableNames];
        Integer recordEnd = pageSize * pageNumber;
        system.debug('total record '+totalRecords);
        Map<Id,Set<Id>> mapofContactRoundtable =new Map<Id,Set<Id>>();
        Set<Contact_Roundtable__c> removeDup =new Set<Contact_Roundtable__c>();
        List<Contact_Roundtable__c> removeDuplicate =[SELECT Id,Contact__r.Name, Contact__r.Email_Visibility__c,Contact__r.Email, Contact__r.Account.Name,Contact__r.Id, Roundtable_Data__r.Name FROM Contact_Roundtable__c Where Roundtable_Data__r.Name=:roundtableNames ORDER BY Contact__r.Name LIMIT :pageSize OFFSET :offset];
        removeDup.addAll(removeDuplicate);
        system.debug(removeDup);
        //Instance of Contact DataTable Wrapper Class
        ContactDataTableWrapper objDT =  new ContactDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        //objDT.contactList = [SELECT Id, Name, Account.Name, Email FROM Contact Where Id=:communityContact ORDER BY Name LIMIT :pageSize OFFSET :offset];
        // objDT.contactRoundtableList = removeDup; //[SELECT Id,Contact__r.Name, Contact__r.Account.Name,Contact__r.Id, Roundtable_Data__r.Name FROM Contact_Roundtable__c Where Roundtable_Data__r.Name=:roundtableNames ORDER BY Contact__r.Name LIMIT :pageSize OFFSET :offset];
        Map<String,RoundtableWrapper> WrapperList =new Map<String,RoundtableWrapper>();
        Set<String> listRtable = new Set<String>();
        for(Contact_Roundtable__c ct : removeDuplicate)
        {
                if(WrapperList.containsKey(ct.Contact__r.Email))
                {
                    String rNames = WrapperList.get(ct.Contact__r.Email).CROuntableName;
                    rNames = rNames + ','+'\n'+ ct.Roundtable_Data__r.Name;
                    system.debug(' rNames  '+rNames);
                    WrapperList.get(ct.Contact__r.Email).CROuntableName = rNames;
                    system.debug('If WrapperList   '+ WrapperList.get(ct.Contact__r.Email).CROuntableName);
                    system.debug('If WrapperList 1   '+ WrapperList);
                }
                else
                {
                    listRtable.add(ct.Roundtable_Data__r.Name);
                    system.debug(listRtable);
                    RoundtableWrapper obj1 =new RoundtableWrapper(); 
                    obj1.CId = ct.Contact__r.Id;
                    obj1.CName = ct.Contact__r.Name;
                    obj1.CEmail = ct.Contact__r.Email; 
                    obj1.CCompanyName = ct.Contact__r.Account.Name;
                    obj1.CROuntableName = ct.Roundtable_Data__r.Name;
                    obj1.CEmailVisiblity = Boolean.valueOf(ct.Contact__r.Email_Visibility__c);
                    WrapperList.put(ct.Contact__r.Email,  obj1);
                    system.debug(' Else obj1   '+ obj1);
                    system.debug(' Else WrapperList   '+ WrapperList);
                }
                objDT.rObj = WrapperList;
          
        } 
        return objDT;
    }
    
    public class RoundtableWrapper {
        @AuraEnabled
        public String CId {get;set;}
        @AuraEnabled
        public String CName {get;set;}
        @AuraEnabled
        public String CEmail {get;set;}
        @AuraEnabled
        public String CCompanyName {get;set;}
        @AuraEnabled
        public String CROuntableName {get;set;}
        @AuraEnabled
        public String CView {get;set;}
        @AuraEnabled
        public Boolean CEmailVisiblity {get;set;}
    }
    
    //Wrapper Class For Contact DataTable  
    public class ContactDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<Contact> contactList {get;set;}
        
        //     public Set<Contact_Roundtable__c> contactRoundtableList {get;set;}
        @AuraEnabled
        public Map<String,RoundtableWrapper> rObj {get;set;}
    }
    
    
    @AuraEnabled
    public static String verifyUser(String email, String password, string startURL)
    {
        try{
            //List<User> UserList=[SELECT Id, Username, Name FROM User where Username=:email ];
            system.debug('Helloooo'+email+'   '+password+'   '+startURL);
            ApexPages.PageReference lgn = Site.login(email,password,startURL);
            aura.redirect(lgn);
            system.debug(lgn);
            return 'Success';
        }catch(Exception e)
        {
            system.debug(e.getMessage());
            return e.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static String forgetPassword(String email)
    {
        try{
            system.debug('Hello I am execute');
            User UserList=[SELECT Id, Username, Name FROM User where Username=:email ];
            String procesMsg = '';
            system.debug('Helloooo'+email);
            if(UserList != null) {
                if (Site.isValidUsername(UserList.Username)) {
                    Site.forgotPassword(UserList.Username);
                    procesMsg = 'LoginResetSuccess';
                } else {
                    procesMsg = 'LoginResetWarning';
                }
                
            }
            return procesMsg;
        }catch(Exception e)
        {
            system.debug(e.getMessage());
            return e.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static List<String>ScheduleRoundtableData(String userId)
    {
        try{
            system.debug('Hello I am ScheduleRoundtableData   '+userId);
            User UserList=[SELECT Id, Username, LastName, FirstName, ContactId, AccountId FROM User where Id=:userId ];
            List<Contact_Roundtable__c> contRoundtable = [SELECT Id, Name, Contact__c, Roundtable_Data__r.Name FROM Contact_Roundtable__c Where Contact__c=:UserList.ContactId];
            system.debug('contRoundtable   '+contRoundtable);
            List<String> RoundtableName = new List<String>(); 
            Set<String> RemoveDuplicateRoundtable = new Set<String>(); 
            for(Contact_Roundtable__c ct : contRoundtable)
            {
                RemoveDuplicateRoundtable.add(ct.Roundtable_Data__r.Name);
                
            }
            RoundtableName.addAll(RemoveDuplicateRoundtable);
            RoundtableName.sort();
            system.debug('RoundtableName   '+RoundtableName);
            return RoundtableName;
        }catch(Exception e)
        {
            system.debug(e.getMessage());
            List<String> Error = new List<String>();
            Error.add(e.getMessage());
            return Error;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EventWrapperData> ShowRoundtableData(List<String> RoundtableString)
    {
        system.debug('Hello I am RoundtableString   '+RoundtableString);
        list<Event> newEventlist = new list<Event>();
        Set<id> IdOfRoundtable = new Set<id>(); 
        List <Roundtable_Data__c> RoundtableList=[SELECT Id, Name FROM Roundtable_Data__c where Name=:RoundtableString ];
        system.debug('Roundtable_Data__c   '+RoundtableList);
        List<Event> EventList = [SELECT Id,  Location,WhatId,EndDateTime,StartDateTime,Subject,IsVisibleInSelfService, Type, Session__c FROM Event Where WhatId =:RoundtableList ];
        system.debug('Event   '+EventList);
        
         List<EventWrapperData> ListEventWrapperData = new List<EventWrapperData>(); 
        //List<Event> EventList = [SELECT Id, WhatId, StartDateTime, EndDateTime, Type, Session__c FROM Event Where Type!=null LIMIT 5 ];
        for(Event et : EventList)
        {
            EventWrapperData Ev =new EventWrapperData();
            Ev.Location = et.Location;
            DateTime StartDT = et.StartDateTime;
            String formattedStartDatetime = StartDT.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().getID());
            Ev.StartDateTime = formattedStartDatetime;
            system.debug('Ev.StartDateTime  ===  '+Ev.StartDateTime);
            DateTime EndDT = et.EndDateTime;
            String formattedEndDatetime = EndDT.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().getID());
            Ev.EndDateTime = formattedEndDatetime;
            system.debug('Ev.EndDateTime  ===  '+Ev.EndDateTime);

            Ev.Session = et.Session__c;
            Ev.Subject = et.Subject;
            Ev.Type = et.Type;
           
            ListEventWrapperData.add(Ev);
            newEventlist.add(et);
            
        }
        system.debug('newEventlist === '+newEventlist);
        return ListEventWrapperData;
        
    }
    
    @AuraEnabled
    public static String downloadFile(String urlFile){
        String fullFileURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        String URlDownload = fullFileURL+'/sfc/servlet.shepherd/version/download'+urlFile;
        return URlDownload;
    }
    public class EventWrapperData {
        @AuraEnabled
        public String Location {get;set;}
        @AuraEnabled
        public String StartDateTime {get;set;}
        @AuraEnabled
        public String EndDateTime {get;set;}
        @AuraEnabled
        public String Type {get;set;}
        @AuraEnabled
        public String Session {get;set;}  
        @AuraEnabled
        public String Subject {get;set;}
    }
    
    @AuraEnabled
    public static List<EventWrapperData> getAllEvents(){
        system.debug('I Event Fetch  ');
        List<Id> ContactId =new List<Id>();
        list<Event> newEventlist = new list<Event>();
        User UserList=[SELECT Id, Username, LastName, FirstName, ContactId, AccountId FROM User where Id=:Userinfo.getUserId() ];
        system.debug('UserList   '+UserList);
        List<Contact_Roundtable__c> contRoundtable = [SELECT Id, Name, Contact__r.Id, Roundtable_Data__c FROM Contact_Roundtable__c Where Contact__r.Id=:UserList.ContactId];
        system.debug('contRoundtable   '+contRoundtable);
        Set<id> RemoveDuplicateRoundtable = new Set<id>(); 
        for(Contact_Roundtable__c ct : contRoundtable)
        {
            RemoveDuplicateRoundtable.add(ct.Roundtable_Data__c);
        }
    	
       
        List<EventWrapperData> ListEventWrapperData = new List<EventWrapperData>(); 
        list<Event> eventlist =[Select id, Location, WhatId, EndDateTime, StartDateTime, Subject, IsVisibleInSelfService, Type, Session__c from Event Where WhatId=:RemoveDuplicateRoundtable];
        for(Event et : eventlist)
        {
            EventWrapperData Ev =new EventWrapperData();
            Ev.Location = et.Location;
            DateTime StartDT = et.StartDateTime;
            String formattedStartDatetime = StartDT.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().getID());
            Ev.StartDateTime = formattedStartDatetime;
            system.debug('Ev.StartDateTime  ===  '+Ev.StartDateTime);
            DateTime EndDT = et.EndDateTime;
            String formattedEndDatetime = EndDT.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().getID());
            Ev.EndDateTime = formattedEndDatetime;
            system.debug('Ev.EndDateTime  ===  '+Ev.EndDateTime);

            Ev.Session = et.Session__c;
            Ev.Subject = et.Subject;
            Ev.Type = et.Type;
           
            ListEventWrapperData.add(Ev);
            newEventlist.add(et);
    
        }
        system.debug('New Event List   '+newEventlist);
        system.debug('Event Wrapper  '+ListEventWrapperData);
        return ListEventWrapperData;
    }
    
    
    @AuraEnabled
    public static list<String> getAllRoundtableName(){
        List<Roundtable_Data__c> RoundtableNameList = [SELECT Name FROM Roundtable_Data__c ];
        List<String> NameOfRT =new List<String>();
        for(Roundtable_Data__c RT : RoundtableNameList)
        {
            NameOfRT.add(RT.Name);
        }
        return NameOfRT;
    }
    @AuraEnabled
    public static String setUserPhoto(String contentDocumentId){
        ContentVersion contentVersion = [SELECT Id, VersionData, FileType, Title 
                                         FROM ContentVersion  
                                         WHERE ContentDocumentId =: contentDocumentId 
                                         LIMIT 1
                                        ];
        
        String lowerCaseFileType = contentVersion.FileType.toLowerCase();
        ConnectApi.UserProfiles.setPhoto(null, UserInfo.getUserId(), new ConnectApi.BinaryInput(contentVersion.VersionData,'image/' + lowerCaseFileType , contentVersion.Title + '.' + lowerCaseFileType));
        String url;
        List<User> userObj = [SELECT Id,ContactId,Contact.Title,Contact.Name,Contact.Email,Contact.Company_Name__c,Contact.Email_Visibility__c, MediumPhotoUrl,FullPhotoUrl  FROM User Where Id=:UserInfo.getUserId()];
        for(User us : userObj)
        {
            url = us.MediumPhotoUrl;
        }
        return url;
    }
    
    @AuraEnabled
    public static ContactFellowsWrapper getFellosData(String currentContactId){
        system.debug('User Id ==  '+currentContactId);
        List<User> userObj = [SELECT Id,ContactId,Contact.Title,Contact.Name,Contact.AccountName__c,Contact.Email,Contact.Company_Name__c,Contact.Email_Visibility__c, MediumPhotoUrl,FullPhotoUrl  FROM User Where ContactId=:currentContactId];
        // List<Contact> ContactList=[SELECT Id, Name, Title, Email, Company_Name__c,Email_Visibility__c FROM Contact Where  Id=:currentContactId ];
        //system.debug('ContactList===    '+ContactList);
        ContactFellowsWrapper objDT =  new ContactFellowsWrapper(); 
        for(User us : userObj)
        {
            objDT.title = us.Contact.Title;
            objDT.company = us.Contact.AccountName__c; 
            objDT.email = us.Contact.Email;
            objDT.name = us.Contact.Name;
            objDT.emailVisible = us.Contact.Email_Visibility__c;
            objDT.imageURL = us.MediumPhotoUrl;
            objDT.userId = us.Id;
        }
        Set<String> removeDup = new Set<String>();
        List<String> roundtableName = new List<String>(); 
        List<Contact_Roundtable__c> contactRoundDataList= [SELECT Id, Contact__r.Id, Roundtable_Data__r.Name FROM Contact_Roundtable__c Where Contact__r.Id=:currentContactId  ];
        for(Contact_Roundtable__c ct : contactRoundDataList)
        {
            removeDup.add(ct.Roundtable_Data__r.Name);
        }
        roundtableName.addAll(removeDup);
        objDT.contactRoundtableName = roundtableName;
        system.debug('objDT===    '+objDT);
        return objDT;
    }
    //Wrapper Class For Fellow's  
    public class ContactFellowsWrapper {
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String company {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String imageURL {get;set;}
        @AuraEnabled
        public String userId {get;set;}
        @AuraEnabled
        public Boolean emailVisible {get;set;}
        @AuraEnabled
        public List<String> contactRoundtableName {get;set;}
    }
    
}