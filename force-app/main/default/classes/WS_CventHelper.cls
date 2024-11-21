/*-********************************************************************************************************
* Name         : WS_CventHelper
* @Author      : Vikram Singh(vikram@wiserspread.com)
* @Date        : 18-Oct-2017
* @Description : This apex class does  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            vikram                       18-Oct-2017                   Initial Creation 
****************************************************************************************************************/

global class WS_CventHelper implements Database.Batchable<list<string>> , database.allowscallouts {
    public list<list<string>> idListForInvitee;
    
    global WS_CventHelper(list<list<string>> idlist){
        
        idListForInvitee = new list<list<string>>();
        this.idListForInvitee = idlist;
        //system.debug('---idListForInvitee--'+idListForInvitee);
    }
    
    global Iterable<list<string>> start(Database.BatchableContext bc){
        //system.debug('---idListForInvitee--'+idListForInvitee);
        
        return idListForInvitee;
    } 
    
    global void execute(Database.BatchableContext BC, List<list<string>> scope){
     try{
        for(list<string> batchList : scope){
            //system.debug('----scope size is --'+batchList.size());
            //system.debug('----scope size is --'+batchList);
            schemasCventComApi200611.ArrayOfInvitee invitees = new schemasCventComApi200611.ArrayOfInvitee();
            schemasCventComApi200611.IdArray ids = new schemasCventComApi200611.IdArray();
            
            schemasCventComApi200611.V200611Soap sc = new schemasCventComApi200611.V200611Soap();
            schemasCventComApi200611.LoginResult loginResult = new schemasCventComApi200611.LoginResult();
                loginResult = sc.Login('HEMCLCA001', 'HEMCLCA001Api', '3KXqYHpkcZc');
            
            schemasCventComApi200611.CventSessionHeader sessHeader = new schemasCventComApi200611.CventSessionHeader();
            sessHeader.CventSessionValue = loginResult.CventSessionHeader;
            
            sc.CventSessionHeader = sessHeader;
             
            ids.id = batchList;
            
            invitees = sc.RetrieveInvitees(ids);
            map<string, schemasCventComApi200611.Invitee> mapOfContactIdVsInvitee = new map<string, schemasCventComApi200611.Invitee>();
            map<string, schemasCventComApi200611.Invitee> mapOfSourceIdVsInvitee = new map<string, schemasCventComApi200611.Invitee>();
            
            if( invitees !=null && invitees.Invitee !=null ){
                for(schemasCventComApi200611.Invitee i : invitees.Invitee){
                    if(mapOfSourceIdVsInvitee != null && !mapOfSourceIdVsInvitee.containsKey(i.contactId)){
                        mapOfSourceIdVsInvitee.put(i.contactId , i);
                        mapOfContactIdVsInvitee.put(i.sourceId , i);
                        //system.debug('===invitee is '+i);
                    }
                }
            }
            invitees = new schemasCventComApi200611.ArrayOfInvitee();
            //system.debug('----mapOfSourceIdVsInvitee---'+mapOfSourceIdVsInvitee);
            //-------mapOfSourceIdVsInvitee.keySet() contains contact Id from cvent
            
            schemasCventComApi200611.ArrayOfContact contacts = new schemasCventComApi200611.ArrayOfContact();
            if(mapOfSourceIdVsInvitee !=null && (!mapOfSourceIdVsInvitee.isEmpty() )){
               // ids.Id.addAll(mapOfSourceIdVsInvitee.keySet());
               list<String> tempList = new list<String>();
               tempList.addAll(mapOfSourceIdVsInvitee.keySet());
               schemasCventComApi200611.IdArray contactIds = new schemasCventComApi200611.IdArray();
               contactIds.Id = tempList;
                //if(!Test.isRunningTest()){
                    contacts = sc.RetrieveContacts(contactIds);
               // }
            }
            
            list<schemasCventComApi200611.CustomFieldDetail> customFields = new list<schemasCventComApi200611.CustomFieldDetail>();
            
            
            map<string, map<string, string>> contactVsCustomFieldsMap = new map<string, map<string, string>>();
            
            map<string, schemasCventComApi200611.Contact> sourceIdVsContactMap = new map<string, schemasCventComApi200611.Contact>();
            
            map<string, string> contactIdVsParentIdsForSummitMap = new map<string, string>();
            
            if( contacts !=null && contacts.contact != null ){
                for(schemasCventComApi200611.Contact con : contacts.contact){
                    if(sourceIdVsContactMap != null && !sourceIdVsContactMap.containsKey(con.sourceId)){
                        sourceIdVsContactMap.put(con.sourceId , con);
                        //system.debug('===contact is is '+con.sourceId);
                        customFields =  con.CustomFieldDetail;
                        map<string, string> tempFieldsMap = new map<string, string>();
                        for(schemasCventComApi200611.CustomFieldDetail s : customFields){
                           // system.debug('==field is =='+s.FieldName+'   '+s.FieldValue);
                            tempFieldsMap.put(s.FieldName , s.FieldValue);
                        }
                        contactIdVsParentIdsForSummitMap.put(con.sourceId , con.sourceId+tempFieldsMap.get('Summit Status ID (Salesforce)'));
                        
                        contactVsCustomFieldsMap.put(con.sourceId , tempFieldsMap);
                        //======sourceId is salesforce id of the contact
                    }
                }
            }
            
            
            //-------retrieveing registrations here
            schemasCventComApi200611.ArrayOfRegistration registrations = new schemasCventComApi200611.ArrayOfRegistration();
            //system.debug('===registrations = '+sc.RetrieveRegistrations(ids));
            //if(!Test.isRunningTest()){
                registrations = sc.RetrieveRegistrations(ids);
            //}
            
            
            map<string, list<string>> contactIdVsRegistrations = new map<string, list<string>>();
            
            if( registrations !=null && registrations.Registration !=null ){
                for(schemasCventComApi200611.Registration reg : registrations.Registration){
                    if(contactIdVsRegistrations != null && !contactIdVsRegistrations.containsKey(reg.SourceId)){
                        
                        map<string, string> RegisteredOrders = new map<string, string>();
                        set<string> cancelledOrders = new set<string>();
                        if(reg.OrderDetail != null){
                            for(schemasCventComApi200611.OrderDetail o : reg.OrderDetail){
                                if(o.Action == 'Registered'){
                                    RegisteredOrders.put(o.productId , o.productName);
                                }else if(o.Action == 'Cancelled'){
                                    cancelledOrders.add(o.productId);
                                }
                            }   
                            
                            for(string s : cancelledOrders){
                                if(RegisteredOrders != null && RegisteredOrders.containsKey(s)){
                                    RegisteredOrders.remove(s);
                                }
                            }
                            
                            contactIdVsRegistrations.put(reg.SourceId, RegisteredOrders.values());
                        }
                        
                        
                        
                    }
                }
            }
            
            //system.debug('-=-contactIdVsRegistrations=='+contactIdVsRegistrations);
            //------contactIdVsRegistrations.keyset() contains SourceId
            
            list<contact> sfdcContactList = new list<Contact>();
            sfdcContactList = [select id, ContactID__c , firstname, lastname, email, Status__c, Asst_Email__c, Recommended_by__c, Communications_Contact_Email__c, 
                                 Recommender_CC__c, Bio_Registration__c, Headshot__c, Company_Bio__c, Registered_Sessions__c, Image_Url__c  
                                 from contact where id IN:sourceIdVsContactMap.keySet()];
            
            
            list<Summit_Status__c> summitStatusList = new list<Summit_Status__c>();
            summitStatusList = [Select Summit__c, Status__c, Name, Id, Created_by_Wufoo__c, 
                                Applicant_s_Title__c, Applicant_s_Organization__c, Applicant_s_Organization_ID__c, 
                                Applicant__c, Action_Needed__c, ParentIds__c, Label__c, JPM_Inviting_Sponsor__c,Inviting_Sponsor_Name__c,
                                Sponsor_CC__c, JPM_Sponsor_CC__c, Recommended_by__c, Recommender_CC__c
                                From Summit_Status__c 
                                where Applicant__c IN:sourceIdVsContactMap.keySet() and ParentIds__c IN: contactIdVsParentIdsForSummitMap.values()];
            
            list<contact> contactListToUpdate = new list<Contact>();
            
            map<string, list<Summit_Status__c>> contactVsSummitStatusList = new map<string, list<Summit_Status__c>>();
            for(Summit_Status__c s : summitStatusList){
                if(contactVsSummitStatusList != null && !contactVsSummitStatusList.containsKey(s.Applicant__c)){
                    list<Summit_Status__c> tempList = new list<Summit_Status__c>();
                    tempList.add(s);
                    contactVsSummitStatusList.put(s.Applicant__c , tempList);
                }else{
                    list<Summit_Status__c> tempList = new list<Summit_Status__c>();
                    tempList = contactVsSummitStatusList.get(s.Applicant__c);
                    tempList.add(s);
                    contactVsSummitStatusList.put(s.Applicant__c , tempList);
                }
            }
            
            
            list<summit_status__c> summitStatusListToUpdate = new list<Summit_Status__c>();
            list<summit_status__c> summitStatusListToInsert = new list<Summit_Status__c>();
            
            for(contact con : sfdcContactList){
                if(sourceIdVsContactMap != null && sourceIdVsContactMap.containsKey(con.Id)){
                    schemasCventComApi200611.Contact cventContact = new schemasCventComApi200611.Contact();
                    cventContact =  sourceIdVsContactMap.get(con.Id);
                    
                    //system.debug('----contact email is '+cventContact.EmailAddress);
                    con.email = cventContact.EmailAddress;
                    con.Asst_Email__c = cventContact.CCEmailAddress;
                    //con.Contact_Type__c = cventContact.contactType;
                    
                    
                    if(contactIdVsRegistrations != null && contactIdVsRegistrations.containsKey(con.Id)){
                        string s = '';
                        for(string str : contactIdVsRegistrations.get(con.Id)){
                            s += str+';';
                        }
                        if(s != null && s.length() > 0){
                            s = s.substring(0, s.length() - 1);
                        }
                        
                        con.Registered_Sessions__c = s;
                        //system.debug('---sessions -- '+contactIdVsRegistrations.get(con.Id));
                    }
                    
                    
                    if(mapOfContactIdVsInvitee != null && mapOfContactIdVsInvitee.containsKey(con.Id)){
                        schemasCventComApi200611.Invitee cventInvitee = new schemasCventComApi200611.Invitee();
                        cventInvitee = mapOfContactIdVsInvitee.get(con.Id);
                        
                        //-----if summit status is present in salesforce
                        if(contactIdVsParentIdsForSummitMap != null && contactIdVsParentIdsForSummitMap.containsKey(con.Id) && contactVsSummitStatusList.containskey(con.id)){
                            for(Summit_Status__c s : contactVsSummitStatusList.get(con.Id)){
                                if(s.parentIds__c == contactIdVsParentIdsForSummitMap.get(con.Id)){
                                    s.Status__c = cventInvitee.Status;
                                    s.Registration_Date__c = cventInvitee.OriginalResponseDate;
                                    
                                    if(contactVsCustomFieldsMap != null && contactVsCustomFieldsMap.containsKey(con.Id)){
                                        map<string, string> tempFieldsMap = new map<string, string>();
                                        tempFieldsMap = contactVsCustomFieldsMap.get(con.Id);
                                        s.Contact_Type__c = cventContact.contactType;
                                        s.Inviting_Sponsor_Name__c = tempFieldsMap.get('Inviting Sponsor Name');
                                        s.JPM_Inviting_Sponsor__c = tempFieldsMap.get('Inviting JPM Sponsor Name');
                                        s.Label__c = tempFieldsMap.get('Label');
                                        s.Sponsor_CC__c = tempFieldsMap.get('Sponsor CC');
                                        s.JPM_Sponsor_CC__c = tempFieldsMap.get('JPM Sponsor CC');
                                        //s.Recommended_by__c = tempFieldsMap.get('Recommended By');
                                        //s.Recommender_CC__c = tempFieldsMap.get('Recommender CC'); 
                                        s.Registered_Sessions__c = con.Registered_Sessions__c;
                                    }
                                    system.debug('===summit is =='+s); 
                                    summitStatusListToUpdate.add(s);
                                }
                            } 
                        }else{
                            if(contactVsCustomFieldsMap != null && contactVsCustomFieldsMap.containsKey(con.Id)){
                                map<string, string> tempFieldsMap = new map<string, string>();
                                tempFieldsMap = contactVsCustomFieldsMap.get(con.Id);
                                Summit_Status__c s = new Summit_Status__c();
                                s.Applicant__c = con.Id;
                                s.Registration_Date__c = cventInvitee.OriginalResponseDate;
                                if(tempFieldsMap.get('Summit Status ID (Salesforce)') != null && tempFieldsMap.get('Summit Status ID (Salesforce)').startsWith('a0S')){
                                    s.Summit__c = tempFieldsMap.get('Summit Status ID (Salesforce)');
                                }
                                s.Status__c = cventInvitee.Status;
                                s.Contact_Type__c = cventContact.contactType;
                                s.Inviting_Sponsor_Name__c = tempFieldsMap.get('Inviting Sponsor Name');
                                s.JPM_Inviting_Sponsor__c = tempFieldsMap.get('Inviting JPM Sponsor Name');
                                s.Label__c = tempFieldsMap.get('Label');
                                s.Sponsor_CC__c = tempFieldsMap.get('Sponsor CC');
                                s.JPM_Sponsor_CC__c = tempFieldsMap.get('JPM Sponsor CC');
                                //s.Recommended_by__c = tempFieldsMap.get('Recommended By');
                                //s.Recommender_CC__c = tempFieldsMap.get('Recommender CC'); 
                                s.Registered_Sessions__c = con.Registered_Sessions__c;
                                if(tempFieldsMap.get('Summit Status ID (Salesforce)') != null && tempFieldsMap.get('Summit Status ID (Salesforce)').startsWith('a0S')){
                                    summitStatusListToInsert.add(s);
                                }
                                
                            }
                        }   
                        
                    }
                    
                    if(contactVsCustomFieldsMap != null && contactVsCustomFieldsMap.containsKey(con.Id)){
                        map<string, string> tempFieldsMap = new map<string, string>();
                        tempFieldsMap = contactVsCustomFieldsMap.get(con.Id);
                        con.Recommended_by__c = tempFieldsMap.get('Recommended By');
                        con.Recommender_CC__c = tempFieldsMap.get('Recommender CC');
                        con.Bio_Registration__c = tempFieldsMap.get('Professional Biography for Summit App');
                        con.Company_Bio__c = tempFieldsMap.get('Company Description for Summit App');
                        //con.Inviting_Sponsor_Name__c = tempFieldsMap.get('Inviting Sponsor Name');
                        //con.Label__c = tempFieldsMap.get('Label');
                        //con.Sponsor_CC__c = tempFieldsMap.get('Sponsor CC');
                        //con.JPM_Sponsor_CC__c = tempFieldsMap.get('JPM Sponsor CC');
                        //con.JPM_Inviting_Sponsor__c = tempFieldsMap.get('Inviting JPM Sponsor Name');
                        
                    }
                    
                    if(cventContact.ImageURL != null){
                        con.Image_Url__c = cventContact.ImageURL;
                        con.Headshot__c = '<img alt="User-added image" src="'+con.Image_Url__c+'"></img>';
                    }
                    
                    
                    
                    contactListToUpdate.add(con);
                    
                }
            }
             
            
            if(contactListToUpdate != null && !contactListToUpdate.isEmpty()){
                update contactListToUpdate; 
            }
            if(contactListToUpdate != null && !contactListToUpdate.isEmpty()){
                system.debug('--summitStatusListToUpdate--'+summitStatusListToUpdate);
                if(summitStatusListToInsert != null && !summitStatusListToInsert.isEmpty()){
                    set<Summit_Status__c> tempSet1 = new set<Summit_Status__c>();
                    tempset1.addAll(summitStatusListToInsert);
                    summitStatusListToInsert = new list<Summit_Status__c>();
                    summitStatusListToInsert.addAll(tempset1);
                    insert summitStatusListToInsert;
                    //database.insert(summitStatusListToInsert, false);
                }
                if(summitStatusListToUpdate != null && !summitStatusListToUpdate.isEmpty()){
                    set<Summit_Status__c> tempSet1 = new set<Summit_Status__c>();
                    tempset1.addAll(summitStatusListToUpdate);
                    summitStatusListToUpdate = new list<Summit_Status__c>();
                    summitStatusListToUpdate.addAll(tempset1);
                    //update summitStatusListToUpdate;
                    database.update(summitStatusListToUpdate, false); 
                }
                
            }
        }
        
      }catch(Exception e){
          System.debug('******Exception'+e);
      }  
        //database.executeBatch(new ws_BatchToUpdateContactImage(contactListToUpdate), 1);
    }
    global void finish(Database.BatchableContext BC){

       }
       
}