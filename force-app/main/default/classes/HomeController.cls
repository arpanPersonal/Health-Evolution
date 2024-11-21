public  without sharing class HomeController {
    
    /*******************Getting all the area of interest multiselect picklist values **************************/
    @AuraEnabled
    public static List<String> getFellowInfoWithAOI(){
        
        List<String> AreaOfInterest = new List<String>();
        Schema.DescribeFieldResult fieldDetail =Contact.Areas_of_Interest__c.getDescribe(); 
        for (Schema.PicklistEntry vs : fieldDetail.getPicklistValues() )
        {
            if(vs.isActive() == true )
            {
                
                AreaOfInterest.add(vs.getValue());
            }
            
        }
        system.debug('AreaOfInterest values ========= '+AreaOfInterest);
        return AreaOfInterest;
    } 
    /*******************update Contact with selected Aera of Interset**************************/
    @AuraEnabled
    public static String UpdateAreaOfInterest(String uid, List<String> Areaofinterestlist){
        try{
            system.debug(' User Id ======'+uid );
            system.debug(' AOI ====  ' + Areaofinterestlist );
            system.debug('Areaofinterestlist.toString() '+Areaofinterestlist.toString());
            List<Contact> UpdateContList =new List<Contact>();
            User listofUser = [select id, ContactId from user Where Id =:uid ];
            String ReturnVal ='';
            List<Contact> ContList = [select id,Areas_of_Interest__c from contact where id=:listofUser.ContactId ];
            for(Contact ct : ContList)
            { 	
                if(Areaofinterestlist.size() == 0)
                {
                    ct.Areas_of_Interest__c = ReturnVal;
                    UpdateContList.add(ct);
                    system.debug('updateContact loop 1.1   '+UpdateContList);
                }
                else if(ct.Areas_of_Interest__c != Areaofinterestlist.toString())
                {
                    system.debug('String.join loop   '+String.join(Areaofinterestlist, ';'));
                    ct.Areas_of_Interest__c = String.join(Areaofinterestlist, ';');
                    UpdateContList.add(ct);
                    system.debug('updateContact loop   '+UpdateContList);
                }
                
            }
            if(UpdateContList.Size() > 0)
            {
                update UpdateContList;
                system.debug('UpdateContList ======'+UpdateContList);
            }
            return 'Success';
        }
        catch(Exception e)
        {
            system.debug('Error  '+e.getMessage());
            return e.getMessage();
        }        
    } 
    
    
    
    /*******************get Contact roundtable list related to  user **************************/
    
    @AuraEnabled
    public static List<Contact_Roundtable__c> getRoundtableslist(String userid){
        System.debug('userid ' +userid);
        String usercontactId = [SELECT Id,ContactId,Contact.Roundtables__c,Name,Email FROM User WHERE Profile.Name = 'Customer Community Login User2' AND Id =:userid].ContactId;
        System.debug('user contact Id' +usercontactId);
        
        List<Contact_Roundtable__c> contrtlist = new List<Contact_Roundtable__c>();
        if(usercontactId!=null){
        contrtlist=[SELECT Id, Contact__c, Roundtable_Data__c,Roundtable_Data__r.Name,Roundtable_Data__r.Roundtable_Icons__c,Roundtable_Data__r.Sub_Heading__c, Roundtable_Data__r.LinkedIn_URL__c FROM Contact_Roundtable__c where Contact__c=:usercontactId ORDER BY Roundtable_Data__r.Name];
            SYstem.debug('!!!!!!!!!!contact roundtable list' +contrtlist);
        }
        return contrtlist;  
        
        
    }
    
    
    /*******************get contact list related to roundtable record **************************/
    
    @AuraEnabled
    public static List<Contact_Roundtable__c> getContactslist(String rtID){
        System.debug('rtID ' +rtID);
        
        List<Contact_Roundtable__c> crtlist = new List<Contact_Roundtable__c>();
        if(rtID!=null){
        crtlist=[SELECT Id,Contact__c,Contact__r.AccountName__c, Contact__r.Name, Contact__r.Email_Visibility__c ,Contact__r.Title,Contact__r.Email,Contact__r.Phone,Roundtable_Data__c FROM Contact_Roundtable__c where Roundtable_Data__c=:rtId ORDER BY Contact__r.Name];
        SYstem.debug('!!!!!!!!!!contact roundtable list' +crtlist);
    }
        return crtlist;
        
    }
    
    /*******************get roundtable record values **************************/
    
    @AuraEnabled
    
    public static Roundtable_Data__c getRoundtable(String rtID){
        System.debug('rtID ' +rtID);
        
        Roundtable_Data__c rtobj = new Roundtable_Data__c();
        if(rtID!=null){
            rtobj=[SELECT Id, Name,Sub_Heading__c,LinkedIn_URL__c FROM Roundtable_Data__c where Id=:rtID];
            SYstem.debug('!!!!!!!!!!roundtable data' +rtobj);
        }
        return rtobj;
    }
    
    /*******************get files list related to roundtable record **************************/
    
    @AuraEnabled
    
    public static List<ContentDocumentLink> getRoundtableFiles(String rtID){
        System.debug('rtID ' +rtID);
        
        List<ContentDocumentLink> rtfiles = new List<ContentDocumentLink>();
        if(rtID!=null){
            rtfiles=[SELECT ContentDocumentId, LinkedEntityId ,ContentDocument.title  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Roundtable_Data__c Where Id=:rtId ) and LinkedEntity.Type='Roundtable_Data__c' ORDER BY ContentDocument.title DESC];
            SYstem.debug('!!!!!!!!!!roundtable files' +rtfiles);
        }
        return rtfiles;
        
    } 
    
    /*******************get Events files list related to roundtable record **************************/
    
    @AuraEnabled
    
    public static List<ContentDocumentLink> getEventsFiles(String rtID){
        System.debug('rtID ' +rtID);
        Map<Id, List<ContentDocumentLink>> parentToChildren = new Map<Id, List<ContentDocumentLink>>();
        
        List<Event> rtevents = new List<Event>();
        rtevents =[SELECT Id,What.Name,IsVisibleInSelfService,whatId FROM Event WHERE What.Type='Roundtable_Data__c' AND WhatId=:rtId AND IsVisibleInSelfService=true];
        //SYstem.debug('!!!!!!!!!!output rtevents' +rtevents);
        
        set<Id> eventsId = new set<Id>();
        
        for(Event et:rtevents){
            eventsId.add(et.Id);
            //System.debug('event id after adding in set' +et.Id);
        } 
        //System.debug('EventsIds are' +eventsId);  
            
        
        List<ContentDocumentLink> eventsfiles = new List<ContentDocumentLink>();
       
        
        for(String eventId:eventsId){
            System.debug('eventId is' +eventId);
            List<ContentDocumentLink> eventfiles=[SELECT ContentDocumentId, LinkedEntityId ,ContentDocument.title  FROM ContentDocumentLink where LinkedEntityId=:eventId ORDER BY ContentDocument.title];
            eventsfiles.addAll(eventfiles);
            System.debug('eventsFiles are' +eventfiles);
        }
        return eventsfiles;
    } 
    /*******************get url to download file **************************/
    
    @AuraEnabled
    
    public static string DownloadAttachment(Id DownloadAttachmentID)
    {
        String URLdwnload;
        if(DownloadAttachmentID!=null){
            ContentVersion oldCV = [Select Id,Title from ContentVersion Where ContentDocumentId=:DownloadAttachmentID];
            System.Debug('cv id :'+ oldCV.Id);
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
            String URlDownload = fullFileURL+'/sfc/servlet.shepherd/version/download/'+oldCV.Id;
            system.debug('Download URL:' +URlDownload);
            URLdwnload=URlDownload;
        }
        return URLdwnload;
        
    } 
    
    /*******************get events related to roundtable record **************************/
    
    @AuraEnabled
    public static List<Event> getRoundTableEvents(String rtId,String userid)
    {
        System.debug('rtID ' +rtId);
        System.debug('userid in getroundtableevents ' +userid);
        String usercontactId = [SELECT Id,ContactId FROM User WHERE Profile.Name = 'Customer Community Login User2' AND Id =:userid].ContactId;
        System.debug('user contact Id' +usercontactId);
        
        List<Event> rtevents = new List<Event>();
        if(rtId!=null){
        // rtevents =[SELECT Id, Subject,StartDateTime,Session__c,Type,EndDateTime, What.Type,WhoId,IsVisibleInSelfService, What.Name, whatId FROM Event WHERE What.Type='Roundtable_Data__c' AND WhatId=:rtId AND WhoId=:usercontactId AND IsVisibleInSelfService=true];
        rtevents =[SELECT Id, Subject,StartDateTime,Session__c,Type,EndDateTime, What.Type,WhoId,IsVisibleInSelfService, What.Name, whatId FROM Event WHERE What.Type='Roundtable_Data__c' AND WhatId=:rtId AND IsVisibleInSelfService=true];
        SYstem.debug('!!!!!!!!!!rtevents' +rtevents);
        }
        return rtevents;
    }  
    
    
    @AuraEnabled
    public static boolean CurrentRoundtable(String rtId){
        return true;
    } 
    
    /***********  get fellow information  **********/
    @AuraEnabled
    public static List<User> fellowInformation(String userid){
        System.debug('userid ' +userid);
        List<user> userobj = new List<user>();
        if(userid!=null){
         userobj = [SELECT Id,ContactId,Contact.Areas_of_Interest__c,Contact.AccountName__c,SmallPhotoUrl,Contact.Fellowship_End_Date__c,FullPhotoUrl,Contact.Name,Contact.Active_Fellowship__c,Contact.Email,Contact.Title,Contact.Email_Visibility__c,Contact.Contact_Organization__c,MediumPhotoUrl, Name,Email FROM User WHERE Profile.Name = 'Customer Community Login User2' AND Id =:userid];
        System.debug('user obj value' +userobj);
            }
        return userobj;
    } 
    
    @AuraEnabled
    public static List<Contact> getContacts(String rtID){
        System.debug('rtID ' +rtID);
        
        List<String> contids = new List<String>();
        
        List<Contact_Roundtable__c> crtlist = new List<Contact_Roundtable__c>();
        crtlist=[SELECT Id,Contact__c,Contact__r.AccountName__c, Contact__r.Name,Contact__r.Title,Contact__r.Email,Contact__r.Phone,Roundtable_Data__c FROM Contact_Roundtable__c where Roundtable_Data__c=:rtId];
        SYstem.debug('!!!!!!!!!!contact roundtable list' +crtlist);
        
        for(Contact_Roundtable__c cr:crtlist){
            contids.add(cr.Contact__c);
        }
        System.debug('contact ids are' +contids);
        
        List<Contact> contlist = new List<Contact>();
        contlist=[SELECT Id,Name,title,Email,Contact_Organization__c FROM Contact where id in:contids];
        SYstem.debug('!!!!!!!!!!contact roundtable list' +contlist);
        return contlist;
        
    }
    @AuraEnabled
    public static List<User> setUserPhoto(String contentDocumentId){
        
        System.debug('!!!!!contentdocumentid value!!!!!!!!!' +contentDocumentId);
        
        ContentVersion contentVersion = [SELECT Id, VersionData, FileType, Title 
                                         FROM ContentVersion  
                                         WHERE ContentDocumentId =: contentDocumentId 
                                         LIMIT 1
                                        ];
        System.debug('!!!!!!!contentVersion value!!!!!' +contentVersion);
        
        String lowerCaseFileType = contentVersion.FileType.toLowerCase();
        System.debug('!!!!!!!lowerCaseFileType value !!!!!' +lowerCaseFileType);
        
        ConnectApi.UserProfiles.setPhoto(null, UserInfo.getUserId(), new ConnectApi.BinaryInput(contentVersion.VersionData,'image/' + lowerCaseFileType , contentVersion.Title + '.' + lowerCaseFileType));
        String url;
        List<User> userObj = [SELECT Id,ContactId,Contact.Title,Contact.Name,Contact.Email,Contact.Company_Name__c,Contact.Email_Visibility__c, MediumPhotoUrl FROM User Where Id=:UserInfo.getUserId()];
        for(User us : userObj)
        {
            url = us.MediumPhotoUrl;
        }
        return userObj;
    }
    
    /************************* Send Email to User for renewing his profile********************/
    
    @AuraEnabled
    public static String sendEmail(String userid){
        try
        {
            List<user> userrec = new List<User>();
            List<String> RoundtableName = new List<String>();
            Set<String> RemoveDuplicateRoundtable = new Set<String>();
            String ContactFellowshipEnd_Date;
            //Getting User Details
            userrec=[SELECT Id,ContactId,Contact.Name,Contact.company_Name__c,Contact.Fellowship_End_Date__c,contact.Email FROM User WHERE Id =:userid];
            System.debug('user obj value' +userrec);
            
            //Getting Roundtable Names	       
            List<Contact_Roundtable__c> contRoundtable = [SELECT Id, Name, Contact__c, Roundtable_Data__r.Name FROM Contact_Roundtable__c Where Contact__c=:userrec[0].ContactId];
            for(Contact_Roundtable__c ct : contRoundtable)
            {
                RemoveDuplicateRoundtable.add(ct.Roundtable_Data__r.Name);
            }
            RoundtableName.addAll(RemoveDuplicateRoundtable);
            
            //Remove Brackets in List
            string sRoundtableName= string.valueOf(RoundtableName).remove('(');
            string finalRoundtableName= sRoundtableName.remove(')');
            
            //Variable 
            String ContactName;
            String ContactEmail;
            String ContactCompany;
            String ExpirationDate;
            
            if(userrec[0].Contact.Name != null)
            {
                ContactName = userrec[0].Contact.Name;
            }
            if(userrec[0].Contact.company_Name__c != null)
            {
                ContactCompany = userrec[0].Contact.company_Name__c;
            }
            if(userrec[0].Contact.Fellowship_End_Date__c != null)
            {
                ExpirationDate = String.valueOf(userrec[0].Contact.Fellowship_End_Date__c).removeEnd(' 00:00:00');
            }
            if(userrec[0].contact.Email != null)
            {
                ContactEmail = userrec[0].contact.Email;
            }
            //Get Client Email
            String StaticEmail = System.Label.HealthEvolutionRenewalEmail; //fellowship@healthevolution.com
            
            //Send Email For HE
            Messaging.SingleEmailMessage semail1 = new Messaging.SingleEmailMessage();
            List<String> sendingToClient = new List<String>();
            sendingToClient.add(StaticEmail);
            semail1.setToAddresses(sendingToClient);
            semail1.setSubject('Fellowship Renewal request from '+ ContactName );
            String body1 = 'Name: '+ContactName+'<br/>';
            body1 += 'Company: '+ContactCompany+'<br/>';
            body1 += 'Expiration Date: '+ExpirationDate+'<br/>';
            body1 += 'Roundtables: '+finalRoundtableName+'<br/>';
            semail1.setHtmlBody(body1);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail1});   
            system.debug(' semail1  '+semail1);
            
            
            system.debug(' ContactName  '+ContactName);
            system.debug(' ContactCompany  '+ContactCompany);
            system.debug(' ExpirationDate  '+ExpirationDate);
            system.debug(' ContactEmail  '+ContactEmail);
            
            //Getting Fellow's Email List
            Set<String> emaillist = new Set<String>();
            emaillist.add(ContactEmail);
            
            System.debug('email list of current user with helath evolution mail' +emaillist);
            
            for(String emailval:emaillist){
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                
                String[] sendingToFellow = new String[]{emailval};
                    semail.setToAddresses(sendingToFellow);
                semail.setSubject('Your renewal request has been sent');
                String body = 'Your Fellowship renewal request has been submitted to the Health Evolution team.'+'<br/>';                
                body += 'Someone from Health Evolution will be in touch regarding next steps.'+'<br/>'; 
                semail.setHtmlBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});  
                system.debug(' semail  '+semail);
                
                
                //semail.setPlainTextBody('Hello'+ username+ '<br/> We have received your renewal Request.<br/> Thanks');  
            }
            return 'Success'; 
        }catch(Exception e)
        {
            system.debug(e.getMessage());
            return e.getMessage();
        }
        
    }
    
    /************************* for email visible on fellow card  **********************************/
    
    @AuraEnabled
    public static String updateContactcheck(boolean emailVal,String userid){
        system.debug('emailval' +emailVal);
        system.debug('userid' +userid);
        
        try{
            User userobj =  [SELECT Id,ContactId FROM User WHERE Id =:userid];
            List<Contact> contList = [SELECT Id,Email_Visibility__c  FROM Contact Where Id=:userobj.ContactId];
            List<contact> updateContact =new List<Contact>();
            for(Contact ct : contList)
            {
                if(emailVal == true)
                {
                    ct.Email_Visibility__c = true;
                }
                else if(emailVal == false)
                {
                    ct.Email_Visibility__c = false;
                }
                updateContact.add(ct);
            }
            if(!updateContact.isEmpty())
            {
                system.debug('========= '+updateContact);
                update updateContact;
            }
            return 'Success';
        }
        catch(Exception e){
            System.debug('exception is' +e);
            return e.getMessage();
        }
        
    } 
    
    /* public class fileWrap{
public Contact_Roundtable__c crTable;
public ContentDocument rtFile;
}  */
    
    
}