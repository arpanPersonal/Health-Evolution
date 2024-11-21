/**
* @company        
* @author        
* @date         08/30/2016
* @description  Support class for NoteTrigger trigger.
* @modifications
* 09/23/2016     Added code that creates accounts when notes contain specially formatted body.
* 07/13/2017     Added code to move Title, Assistant Email to Contact record
*/

public class NoteTriggerSupport {
    
    /**    
    * @date         08/30/2016
    * @description  Looks for Notes with particular criteria and creates
    *               Summit_Status__c records as needed.
    *
    */
    public static void createSummitStatusRecords(List<Note> newList){
        
        String WOOFOOTITLE = 'Apply to Participate';
        String WOOFOOOBJECTTYPE = 'Contact';
        String WOOFOOSTATUS = 'New invite request';
        String WOOFOOACTION = 'Review';
        String COMPANYSTART = 'STARTCOMPANY-->'; //start of company name in note body
        String COMPANYEND = '<--ENDCOMPANY';
        Integer l = COMPANYEND.length();
        String UNKNOWNCOMPANY = 'Unknown';
        String TITLESTART = 'STARTTITLE-->';//start of title in note body
        String TITLEEND = '<--ENDTITLE';
        String ASSTSTART = 'STARTASST-->'; //start of Assistant's Name in note body
        String ASSTEND = '<--ENDASST';
        String ASSTEMAILSTART = 'STARTASSTEMAIL-->'; //start of Assistant's email in note body
        String ASSTEMAILEND = '<--ENDASSTEMAIL';
        String cTitle;
        String cAsst;
        String cAsstEmail;
        List<Summit_Status__c> insertList = new List<Summit_Status__c>();
        Map<Date,Id> dmap = new Map<Date,Id>();
        Map<Date,Date> cmap = new Map<Date,Date>();
        Map<Id,Account> contactMap = new Map<Id,Account>();
        Map<Id,String> conMap = new Map<Id,String>();
        List<Contact> contactList = new List<Contact>();
        Map<String,Id> accMap = new Map<String,Id>();
        Set<String> accSet = new Set<String>();
        Id unknownId;
        Id companyRT;
        
        //there needs to be an 'unknown' account
        if (newList.size() > 0){
            List<Account> la = [Select Id From Account Where Name = :UNKNOWNCOMPANY Limit 1];
            if (la.size() < 1){
                Account a = new Account(Name = UNKNOWNCOMPANY);
                insert a;
                unknownId = a.Id;
            } else {
                unknownId = la[0].Id;
            }
            
            companyRT = [Select Id
                            From RecordType 
                            Where sobjecttype = 'Account' 
                            And Name = 'Company' 
                            Limit 1].Id;
        }
        
        //Get list of all summit__c records so we can match notes with them
        List<Summit__c> ls = [Select Id, Begin_Date__c
                              From Summit__c
                              Order by Begin_Date__c];

        //Populates maps that will allow us to perform the matching
        for (integer i = 0;i < ls.size();i++){
            dmap.put(ls[i].Begin_Date__c,ls[i].Id);
            if (i == ls.size() - 1){
                cmap.put(ls[i].Begin_Date__c,date.today().AddDays(1)); //if there is no subsequent record, create a date in the future
            } else {
                cmap.put(ls[i].Begin_Date__c,ls[i+1].Begin_Date__c);
            }
        }

        //loop through notes and create summit_status__c records
        for (Note n : newList){
            //we only care about Notes related to Contacts
            String parentType;
            Schema.SObjectType token = n.ParentId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            parentType = dr.getName();
            
            system.debug('Note body: ' + n.Body);
            if (n.Title.contains(WOOFOOTITLE) && parentType == WOOFOOOBJECTTYPE){
                system.debug(loggingLevel.ERROR,'Note passes title and parenttype tests.');
                Boolean found = false;
                for (Date dt : cmap.keySet()){
                    if (n.CreatedDate >= dt && n.CreatedDate < cmap.get(dt) ){
                        found = true;
                        
                        //get account name if it exists and put in map with contact
                        String s = n.Body;
                        integer i = s.indexOf(COMPANYSTART);
                        integer e = s.indexOf(COMPANYEND);
                        Account a = new Account();
                        String aName;
                        if (s.contains(COMPANYSTART) && s.contains(COMPANYEND) && e > i)
                        {
                            aName = s.substring(i,e).replace(COMPANYSTART,'').trim();
                        } else {
                            aName = UNKNOWNCOMPANY;
                        }
                        accSet.add(aName);
                        a.Name = aName;
                        system.debug('Account Name: ' + aName);
                        contactMap.put(n.parentId,a);
                        
        //get contact's title if it exists and put in map with contact
                        
                        integer i2 = s.indexOf(TITLESTART);
                        integer e2 = s.indexOf(TITLEEND);
                      
                        if (s.contains(TITLESTART) && s.contains(TITLEEND) && e2 > i2)
                        {
                            cTitle = s.substring(i2,e2).replace(TITLESTART,'').trim();
                        } else {
                            cTitle = NULL;
                        }
                        system.debug('Contact Title: ' + cTitle);
                        conMap.put(n.parentId,cTitle); 
                     
        //get contact's Assistant's Name if it exists and put in map with contact
                        
                        integer i3 = s.indexOf(ASSTSTART);
                        integer e3 = s.indexOf(ASSTEND);
                      
                        if (s.contains(ASSTSTART) && s.contains(ASSTEND) && e3 > i3)
                        {
                           cAsst = s.substring(i3,e3).replace(ASSTSTART,'').trim();
                        } else {
                           cAsst = NULL;
                        }
                        system.debug('Contact Assistant\'s Name: ' + cAsst);
                        conMap.put(n.parentId,cAsst); 
                    

        //get contact's Assistant's Email if it exists and put in map with contact
                        
                        integer i4 = s.indexOf(ASSTEMAILSTART);
                        integer e4 = s.indexOf(ASSTEMAILEND);
                      
                        if (s.contains(ASSTEMAILSTART) && s.contains(ASSTEMAILEND) && e4 > i4)
                        {
                           cAsstEmail = s.substring(i4,e4).replace(ASSTEMAILSTART,'').trim();
                        } else {
                           cAsstEmail = NULL;
                        }
                        system.debug('Contact Assistant\'s Email: ' + cAsstEmail);
                        conMap.put(n.parentId,cAsstEmail); 
                        
                                               
        //create new Summit_Status__c record and add to insert list
                        Summit_Status__c ss = new Summit_Status__c (Created_by_Wufoo__c = 'Yes',
                                                                    Summit__c = dmap.get(dt),
                                                                    Applicant__c = n.ParentId,
                                                                    Action_Needed__c = WOOFOOACTION,
                                                                    Status__c = WOOFOOSTATUS);
                        insertList.add(ss);
                        break;
                    }
                    else system.debug(loggingLevel.ERROR,'Note does not pass all tests.');
                }
                if (!found){
                    system.debug('Warning: createSummitStatusRecords: no matching Summit record found for Note! Details follow.');
                    system.debug('Note Title: ' + n.Title);
                    system.debug('Note Id: ' + n.Id);
                }
            }
            else system.debug(loggingLevel.ERROR,'Note does not pass ANY tests.');
        }//for loop
        
        //get existing accounts with relevant names
        List<Account> la = [Select Id, Name 
                            From Account 
                            Where Name In :accSet];
        
        //put accounts in map by name    
        for (Account a : la){
            if (accMap.get(a.Name) == null){
                accMap.put(a.Name,a.Id);
            }    
        }
        
        la.clear();
        
        //create accounts if they don't exist
        for (String s : accSet){
            if (accMap.get(s) == null){
                Account a = new Account(Name = s,
                                        Created_by_Wufoo__c = 'Yes',
                                        RecordTypeId = companyRT);
                la.add(a);
            }
        }
        
        if (la.size() > 0){
            insert la;
        } 
        
        //put set of new accounts into map
        for (Account a : la){
            if (accMap.get(a.Name) == null){
                accMap.put(a.Name,a.Id);
            }    
        }
        
        //modify contacts for update operation
        //need to make sure contacts already related to accounts don't get updated
        contactList = [Select Id, AccountId, Created_by_Wufoo__c
                       From Contact 
                       Where Id In :contactMap.keyset()];
        
        for (Contact c : contactList){
            if (accMap.get(contactMap.get(c.Id).Name) != null){
                system.debug(loggingLevel.ERROR,'Account name exists in contactMap.');
                if (c.AccountId == null){
                    system.debug(loggingLevel.ERROR,'AccountId for contact is null.');
                    c.AccountId = accMap.get(contactMap.get(c.Id).Name);
                    c.Title = cTitle;
                    c.AssistantName = cAsst;
                    c.Asst_Email__c = cAsstEmail;
                                    }
                else system.debug(loggingLevel.ERROR,'AccountId for contact is NOT null.');
                if (c.Created_by_Wufoo__c == null || c.Created_by_Wufoo__c != 'Yes'){
                    c.Created_by_Wufoo__c = 'Yes';
                }                
            }
            else system.debug(loggingLevel.ERROR,'Account name DOES NOT EXIST in contactMap.');
        }
        
        try {
            if (insertList.size() > 0){
                insert insertList;
                update contactList;
            }
        } catch (exception ex) {
            system.debug('An error occurred attempting to insert Summit_Status__c records: ' + ex.getMessage());   
        }
    }
}