public class InboundVCardSupport
{
    /* 
        Created 12/24/2012    ASC    Groove Analytics LLC
        
        This code is Copyright 2012 Groove Analytics LLC.
        The Company owning the Salesforce organization in which this code is installed 
        by Groove Analytics is granted a perpetual license
        to use the code and modify it as they see fit for internal use only.  
        This license expressly forbids re-distribution of the code without written consent of Groove Analytics LLC.
        
        Support class for inbound vcard email service processing.
        
    */


   public VCard_Configuration__c VCConfig;
   public Id AccountRecordTypeId;
   public Id ParentAccountId;
   public Id ContactRecordTypeId;
   private static map<string,string> mapASCII = new map<string,string>();
    
    //constructor uses To address to fill field name values
   public InboundVCardSupport(string ToAddress)
   {
   		try
   		{
   			//get main configuration object and values
	        VCConfig = [Select v.WorkAddressZipField__c, 
	                           v.WorkAddressStateField__c, 
	                           v.WorkAddressField__c,
	                           v.WorkAddressCityField__c,
	                           v.WorkAddressCountryField__c,
	                           v.HomePhoneField__c,
	                           v.MobilePhoneField__c,
	                           v.TitleField__c, 
	                           v.SuffixField__c, 
	                           v.PersonCompanyField__c, 
	                           v.PersonAccount__c, 
	                           v.MIddleNameField__c, 
	                           v.Id, 
	                           v.EmailField__c, 
	                           v.Email3Field__c, 
	                           v.Email2Field__c, 
	                           v.AccountRecordTypeName__c,
	                           v.ContactRecordTypeName__c 
	                     From VCard_Configuration__c v 
	                     Where v.AddressedTo__c = :ToAddress
	                     Limit 1]; 
	                              
	    	//get the account record type id if applicable
	    	if (VCConfig.AccountRecordTypeName__c != null)
	    		AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(VCConfig.AccountRecordTypeName__c).getRecordTypeId(); 
			
			//get the contact record type id if applicable
			if (VCConfig.ContactRecordTypeName__c != null)
				ContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(VCConfig.ContactRecordTypeName__c).getRecordTypeId(); 
   		}
   		catch (exception ex)
   		{
   			system.debug(ex.getMessage());
   		}
   }

 
   

   public string constructNotificationString(string sReason, map<String,String> mapContactFields){
    //sort of generic method for constructing a notification string
        String sNotice = sReason;
        //output values if there are any
        if(mapContactFields.size() > 0)
        {
            sNotice += '\r\n\r\nYou sent a vCard with the following values:\r\n\r\n';
            list<String> listFields = new list<String>();
            listFields.addAll(mapContactFields.keySet());
            listFields.sort();
            for (String f : listFields)
            {
                sNotice += f + ': ' + mapContactFields.get(f) + '\r\n';
            }           
        }
        return sNotice; 
   }
  


   public map<String,String> parseVCardArray(String[] sLineArray){
    //method for parsing the vcard line array
        map<String,String> mapContactFields = new map<String,String>();
        
        if (mapASCII.size() == 0)
        {
        	//initialize ascii map if necessary
        	initASCIIMap();
        }
        
        //we are only going to try to handle certain fields. It would be good to make this all more generic. I don't like all the hard coding.
        //need special handling for certain fields though, e.g. address and email. 
 
        //first get version of vCard. Reject if version is not 2 or 3 (for now)
        for(string l : sLineArray){
            if (l.startsWith('VERSION:'))  
            {
                String[] sLineSplit = l.split(':'); 
                if (!sLineSplit[1].startsWith('3') && !sLineSplit[1].startsWith('2'))
                {
                    system.debug('Unsupported vcard version: ' + sLineSplit[1]);
                    return mapContactFields;
                } else system.debug('Vcard version: ' + sLineSplit[1]);
            } 
        }
            
        //a note about the file format - types may or may not be modified by following the type name with a semicolon
        //e.g. n;charset=utf-8:Myatt;Shannon;;;
        //note also that Mac Outlook seems to send all types in lowercase
        //http://tools.ietf.org/html/rfc6350

        for (integer i = 0; i < sLineArray.size(); i++)
        {
            
            string l = sLineArray[i];
            string sData = '';
            string sField = '';
            
            //look one line forward and see if it's a broken line. if so
            //keep walking forward and concatenating until you find a non-broken line
            if (i < sLineArray.size() - 1)
            {
                if (sLineArray[i+1].startsWith(' ') || sLineArray[i+1].startsWith('=') || sLineArray[i].endsWith('=') || sLineArray[i].endsWith('=\r\n'))
                {
                    //system.debug('found broken line');
                    for (integer x = i+1; x < sLineArray.size() - 1; x++){
                        if (sLineArray[i+1].startsWith(' ') || sLineArray[i+1].startsWith('=') || sLineArray[i].endsWith('=') || sLineArray[i].endsWith('=\r\n'))
                        {
                            //l += sLineArray[x].right(sLineArray[x].length()-1); //cut off leading space
                            l += sLineArray[x].trim();
                        } 
                        else 
                        { 
                            break;  
                        }  
                        i = x;                     
                    }                   
                }                   
            }
            
            //need to get rid of some junk in the line
            l = l.replace('\\,',',');
            //l = l.replace('\\n','');
            l = l.replace('\\:','-');
            
            //system.debug('replaced LINE:');
            //system.debug(l);

            String[] sLineSplit = l.split(':');  //split field name from data for each line
            
            //there should only be one field and one data value
            //sometimes, data value might contain colons, so we need to account for that
            if (sLineSplit.size() > 2)
            {
            	for (integer p = 2; p < sLineSplit.size(); p++)
            	{
            		sLineSplit[1] += sLineSplit[p];
            	}
            }
        
            if (sLineSplit != null && sLineSplit.size() > 1) { //if both field and data have data, split them
                            
                sData = sLineSplit[1]; 
                sField = sLineSplit[0]; 
                    
                //system.debug('sField');
                //system.debug(sField);
                //system.debug('sData');
                //system.debug(sData);
                    
                String[] sDataSplit = sData.split(';'); //split the data variable into values
                    
                //system.debug('sDataSplit.size');
                //system.debug(sDataSplit.size());
                //system.debug('sDataSplit[0]');
                //if (sDataSplit.size() > 0) system.debug(sDataSplit[0]);
                    
                if (sField == ('N') || sField.startsWithIgnoreCase('N;')){ //name
                    //system.debug('passed name test');
                    if (sDataSplit.size() > 0 && sDataSplit[0] != null) mapContactFields.put('Lastname',sDataSplit[0].replace('\'',''));
                    if (sDataSplit.size() > 1 && sDataSplit[1] != null) mapContactFields.put('Firstname',sDataSplit[1].replace('\'',''));
                    if (sDataSplit.size() > 2 && sDataSplit[2] != null) mapContactFields.put(VCConfig.MIddleNameField__c,sDataSplit[2]);
                    if (sDataSplit.size() > 3 && sDataSplit[3] != null) mapContactFields.put('Salutation',sDataSplit[3]);
                    if (sDataSplit.size() > 4 && sDataSplit[4] != null) mapContactFields.put(VCConfig.SuffixField__c,sDataSplit[4]);
                 } else if (sField == ('ORG') ||  sField.startsWithIgnoreCase('ORG;')){ //company
                        //system.debug('passed org test');
                        if (sDataSplit.size() > 0 && sDataSplit[0] != null && sDataSplit[0] != '') 
                        {
                        	if (VCConfig.PersonAccount__c) mapContactFields.put(VCConfig.PersonCompanyField__c,sDataSplit[0].replace('\'',''));
                        	else mapContactFields.put('Account.Name',sDataSplit[0].replace('\'',''));
                        }
                 } else if (sField == ('TITLE')  || sField.startsWithIgnoreCase('TITLE;')){ //title
                        if (sDataSplit.size() > 0 && sDataSplit[0] != null) mapContactFields.put(VCConfig.TitleField__c,sDataSplit[0]);
                 } else if ((sField == ('TEL') || sField.startsWithIgnoreCase('TEL;')) && (sDataSplit.size() > 0) && (sDataSplit[0] != null)){ //do different phone number types - default to Phone. 
                    string sTelType = 'Phone';
                    if (sField.containsIgnoreCase('CELL')){
                            sTelType = VCConfig.MobilePhoneField__c;
                    } else if (sField.containsIgnoreCase('HOME')){
                            sTelType = VCConfig.HomePhoneField__c;
                    } else if (sField.containsIgnoreCase('FAX') || sField.containsIgnoreCase('TYPE=WORK,FAX')){
                        sTelType = 'Fax';
                    }
                    //put phone in map
                    if (sDataSplit.size() > 0){
                        mapContactFields.put(sTelType,sDataSplit[0]);
                    }
                 } else if (sField == ('NOTE') || sField.startsWithIgnoreCase('NOTE;')){ //description
                        if (sField.containsIgnoreCase('ENCODING=QUOTED-PRINTABLE')){
                            if (sDataSplit.size() > 0 && sDataSplit[0] != null) mapContactFields.put('Description',decodeString(sDataSplit[0])); 
                        } else {
                            if (sDataSplit.size() > 0 && sDataSplit[0] != null) mapContactFields.put('Description',sDataSplit[0].replace('\\n','\r\n'));    
                        }
                 } else if ((sField.containsIgnoreCase('ADR:') || sField.containsIgnoreCase('ADR;')) && sField.containsIgnoreCase('WORK')){ //addresses
                        if (sField.containsIgnoreCase('ENCODING=QUOTED-PRINTABLE')){
                            if (sDataSplit.size() > 2 && sDataSplit[2] != null) mapContactFields.put(VCConfig.WorkAddressField__c,decodeString(sDataSplit[2]));   
                            if (sDataSplit.size() > 3 && sDataSplit[3] != null) mapContactFields.put(VCConfig.WorkAddressCityField__c,decodeString(sDataSplit[3]));   
                            if (sDataSplit.size() > 4 && sDataSplit[4] != null) mapContactFields.put(VCConfig.WorkAddressStateField__c,decodeString(sDataSplit[4]));   
                            if (sDataSplit.size() > 5 && sDataSplit[5] != null) mapContactFields.put(VCConfig.WorkAddressZipField__c,decodeString(sDataSplit[5]));   
                            if (sDataSplit.size() > 6 && sDataSplit[6] != null) mapContactFields.put(VCConfig.WorkAddressCountryField__c,decodeString(sDataSplit[6]));                           
                        } else { 
                            if (sDataSplit.size() > 2 && sDataSplit[2] != null) mapContactFields.put(VCConfig.WorkAddressField__c,sDataSplit[2].replace('\\n','\r\n'));
                            if (sDataSplit.size() > 3 && sDataSplit[3] != null) mapContactFields.put(VCConfig.WorkAddressCityField__c,sDataSplit[3]);
                            if (sDataSplit.size() > 4 && sDataSplit[4] != null) mapContactFields.put(VCConfig.WorkAddressStateField__c,sDataSplit[4]);
                            if (sDataSplit.size() > 5 && sDataSplit[5] != null) mapContactFields.put(VCConfig.WorkAddressZipField__c,sDataSplit[5]);
                            if (sDataSplit.size() > 6 && sDataSplit[6] != null) mapContactFields.put(VCConfig.WorkAddressCountryField__c,sDataSplit[6]);
                        }
                 } else if ((sField.containsIgnoreCase('EMAIL:') || sField.containsIgnoreCase('EMAIL;')) && (sDataSplit.size() > 0) && sDataSplit[0] != null){ //we'll take up to three email addresses, in order
                        //system.debug('passed email test');
                        //system.debug(VCConfig.EmailField__c);
                        if (mapContactFields.get(VCConfig.EmailField__c) == null){
                            //system.debug('populating email 1');
                            mapContactFields.put(VCConfig.EmailField__c,sDataSplit[0]);
                        } else if (mapContactFields.get(VCConfig.EmailField__c) != null && mapContactFields.get(VCConfig.Email2Field__c) == null){
                            mapContactFields.put(VCConfig.Email2Field__c,sDataSplit[0]);
                        } else if (mapContactFields.get(VCConfig.EmailField__c) != null && mapContactFields.get(VCConfig.Email2Field__c) != null && mapContactFields.get(VCConfig.Email3Field__c) == null){
                            mapContactFields.put(VCConfig.Email3Field__c,sDataSplit[0]);
                        } else system.debug('no email contingency match');
                 }  else { system.debug('did not pass any field test: ' + l);}//if l.startswith(outer)//l.startsWith(inner)
            } //if (sLineSplit[1] != null && sLineSplit[0] != null)
        } //for (integer i = 0; i < sLineArray.size(); i++){    
        return mapContactFields;
   }


 
   public boolean isVCardComplete(map<string,string> mapContactFields)
   {
   		//determines if minimum necessary fields appear in vcard map
   		string sCompanyKey = 'Account.Name'; //default for contact
   		string sEmailKey = VCConfig.EmailField__c;
   		
		if (VCConfig.PersonAccount__c == true)
   		{
   			sCompanyKey = VCConfig.PersonCompanyField__c;
   			if (mapContactFields.get('Lastname') == null || mapContactFields.get('Firstname') == null 
	        	|| mapContactFields.get(sEmailKey) == null
	            || mapContactFields.get('Lastname') == '' || mapContactFields.get('Firstname') == ''
	            || mapContactFields.get(sEmailKey) == '') 
        		return false; 
   		}
   		else	
   		{
	        if (mapContactFields.get('Lastname') == null || mapContactFields.get('Firstname') == null 
	        	|| mapContactFields.get(sCompanyKey) == null || mapContactFields.get(sEmailKey) == null
	            || mapContactFields.get('Lastname') == '' || mapContactFields.get('Firstname') == ''
	            || mapContactFields.get(sCompanyKey) == '' || mapContactFields.get(sEmailKey) == '') 
	        return false; 
   		}
   		//if we got here we're ok
   		return true;
   }   
 
 
 
   
   public string doGetPreviousContact(map<string,string> mapContactFields)
   {
   		//determines if contact/person already exists
   		String sSOQL;
   		String sRetVal = 'OK';
   		
   		//check for existence of matching contact
   		if (VCConfig.PersonAccount__c == false)
   		{
               sSOQL = 'Select Id From Contact Where ';
               sSOQL += '(Lastname = \'' + mapContactFields.get('Lastname') + '\''; 
               sSOQL += ' AND FirstName = \'' + mapContactFields.get('Firstname')  + '\''; 
               sSOQL += ' AND Account.Name = \'' + mapContactFields.get('Account.Name')  + '\')'; 
               sSOQL += ' OR Email = \'' + mapContactFields.get(VCConfig.EmailField__c).trim() + '\''; //sometimes email seems to have a linefeed   
   		}
   		else
   		{      
   		//check for existence of matching person
               sSOQL = 'Select Id From Account Where ';
               sSOQL += 'IsPersonAccount = true ';
               sSOQL += 'AND ((Lastname = \'' + mapContactFields.get('Lastname')  + '\''; 
               sSOQL += ' AND FirstName = \'' + mapContactFields.get('Firstname') + '\''; 
               sSOQL += ' AND ' + VCConfig.PersonCompanyField__c + ' = \'' + mapContactFields.get(VCConfig.PersonCompanyField__c)  + '\')'; 
               sSOQL += ' OR ' + VCConfig.EmailField__c + ' = \'' + mapContactFields.get(VCConfig.EmailField__c).trim() + '\')';
   		} 
   		
   		system.debug(sSOQL);
   		list<SObject> listResults = Database.query(sSOQL);
	
		if (listResults.size() > 0)
		{
			sRetVal = listResults[0].Id;
		}
   		
   		return sRetVal;      
   }



   
   public void doGetParentAccountId(map<string,string> mapContactFields)
   {
   		//If a contact parent account with the same name as the vcard (and same recordtype in some instances)
   		//exists, set ParentAccountId equal to it's id.  Otherwise, insert the account and set ParentAccountId to its id
   		string sSOQL = 'Select Id From Account Where Name = \'' + mapContactFields.get('Account.Name').replace('\'','')  + '\'';
   		if (AccountRecordTypeId != null)
   		{
   			sSOQL += ' AND RecordTypeId = \'' + AccountRecordTypeId + '\'';
   		}
   		
   		list<Account> listAccounts = Database.query(sSOQL);
                   
        //if account does not already exist; insert it
        if (listAccounts.size() == 0)
        {
        	account a = new Account(Name = mapContactFields.get('Account.Name'));
        	
        	//if account should have record id other than default....
        	if (AccountRecordTypeId != null && Schema.sObjectType.Account.fields.getMap().containsKey( 'RecordTypeId' ))     
            	a.put('RecordTypeId',AccountRecordTypeId);
            	
            try{
                //add address fields if they exist
                a.put('BillingStreet',mapContactFields.get(VCConfig.WorkAddressField__c));   
                a.put('BillingCity',mapContactFields.get(VCConfig.WorkAddressCityField__c));
                a.put('BillingState',mapContactFields.get(VCConfig.WorkAddressStateField__c));
                a.put('BillingPostalCode',mapContactFields.get(VCConfig.WorkAddressZipField__c));
                a.put('BillingCountry',mapContactFields.get(VCConfig.WorkAddressCountryField__c));
            } catch (Exception e){
                system.debug('Failed to add field to Account object: ' + e.getMessage());
            }
            insert a;
            ParentAccountId = a.id;
        }
        else 
        {
        	ParentAccountId = listAccounts[0].Id; //just picking the first account found
        }
        
   }



   
   public string doInsertContact(map<string,string> mapContactFields, string sFromAddress)
   {
   		string sRetVal = '';
   		
   		if (VCConfig.PersonAccount__c == false)
   		{
   			//insert contact
   			Contact c = new Contact(); 
   			c.AccountId = ParentAccountId;

			//record type id if applicable
   			if (ContactRecordTypeId != null && Schema.sObjectType.Contact.fields.getMap().containsKey( 'RecordTypeId' ))
   				c.put('RecordTypeId',ContactRecordTypeId);
   			
   			//loop through keyset and set contact fields equal to corresponding values
            for (String f : mapContactFields.keyset()){
                if (f != 'Account.Name'){ //already done
                    try{
                        c.put(f,mapContactFields.get(f));
                    } catch (Exception e){
                        system.debug('Failed to add field to Contact object: ' + e.getMessage());
                    }
                }
            }
           
            //add ownerid if you can find one
            Id idOwner = findSenderId(sFromAddress) ;
            if (idOwner != null){
                c.OwnerId = idOwner;
            }
            
            //do the insert                              
            if (c != null) 
            {
                try 
                {
                    insert c;
                } 
                catch(Exception e) 
                {
                    return 'ERROR: ' + e.getMessage();
                } 
                return string.valueOf(c.Id);
            } 
            else 
            {
                system.debug('c is null! what?');
                return 'ERROR: c is null! what?';
            }
            
   		}
   		else
   		{
   			//person account
   			Account a = new Account(); 
              
            //account id if applicable
            if (AccountRecordTypeId != null && Schema.sObjectType.Account.fields.getMap().containsKey( 'RecordTypeId' ))     
            	a.put('RecordTypeId',AccountRecordTypeId);
           
            //loop through keyset and set contact fields equal to corresponding values
            for (String f : mapContactFields.keyset())
            {
            	//since the db doesnt know this is a person account until insert, you can't put __pc fields in the object yet
            	if (f.Right(4) != '__pc')
            	{
	                try
	                {
	                	a.put(f,mapContactFields.get(f));
	                } 
	                catch (Exception e)
	                {
	                	system.debug('Failed to add field to Account object: ' + e.getMessage());
	                }
            	}
            }
           
           //add ownerid if you can find one
            Id idOwner = findSenderId(sFromAddress) ;
            if (idOwner != null){
                a.OwnerId = idOwner;
            }
                                      
            if (a != null) 
            {
                try 
                {
                    insert a;
                    
                    //now do __pc fields
                    for (String f : mapContactFields.keyset())
		            {
		            	if (f.Right(4) == '__pc')
		            	{
			                try
			                {
			                	a.put(f,mapContactFields.get(f));
			                } 
			                catch (Exception e)
			                {
			                	system.debug('Failed to add __pc field to Account object: ' + e.getMessage());
			                }
		            	}
		            }
		            
		            update a;
                } 
                catch(Exception e) 
                {
                	return 'ERROR: ' + e.getMessage();
                } 
                return string.valueOf(a.Id);
			} 
            else 
            {
                system.debug('a is null! what?');
                return 'ERROR: a is null! what?';
            }
            //should not get here
   			return 'ERROR: Unknown';
   		}
   }
     



   public boolean sendNotificationEmail(String sMessage, String sRecipient, String sSender){
    //method for sending single notification email
        system.debug(sSender);
        try 
        {
            Messaging.reserveSingleEmailCapacity(1);    //reserve resources
        } 
        catch(Exception e) 
        {
            system.debug(e.getMessage());
            return false; 
        } 
        
        list<String> listTo = new list<String>();
        listTo.add(sRecipient);
        
        try
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
            mail.setToAddresses(listTo);
            mail.setReplyTo(sSender); //I don't think this is working...
            mail.setSenderDisplayName('Salesforce vCard Processor');
            mail.setSubject('vCard Processing Notification');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody(sMessage);
                        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        } 
        catch (Exception e) 
        {
            return false;
        }   
        return true;            
   }
   



   public Id findSenderId(String sSenderEmail){
    //method to return the Id of the sender if it exists (if there is more than one user with sSenderEmail, record may be assigned to the wrong user.)
        list<User> listUser = [Select Id From User Where IsActive = true and Email = :sSenderEmail Limit 1];
        if (listUser.size() > 0)
        {
            return listUser[0].Id;
        } else return null;
   }
  
  
  
  public string decodeString(string sEncoded)
  {
	  	string sDecoded = sEncoded;
	  	//system.debug(sEncoded);
	  	//just loops through all chars in map keyset and replaces hex with ascii values
	  	//seems like the simplest, though perhaps not the most efficient, way to do this
	  	for (string s : mapASCII.keyset())
	  	{
			sDecoded = sDecoded.replace(s,mapASCII.get(s));
	  	}
	  	//system.debug(sDecoded);
	  	sDecoded = sDecoded.replace('=',''); //replace any left over equal signs
	  	return sDecoded;
  }
  
  
  
  public void initASCIIMap()
  {
  	//Initialize map of quoted-printable hex values to ASCII characters
  	//Obviously, not mapping the entire character set
	  	mapASCII.put('=20',' ');
		mapASCII.put('=21','!');
		mapASCII.put('=22','"');
		mapASCII.put('=23','#');
		mapASCII.put('=24','$');
		mapASCII.put('=25','%');
		mapASCII.put('=26','&');
		mapASCII.put('=27','\''); 
		mapASCII.put('=28','(');
		mapASCII.put('=29',')');
		mapASCII.put('=2A','*');
		mapASCII.put('=2B','+');
		mapASCII.put('=2C',',');
		mapASCII.put('=2D','-');
		mapASCII.put('=2E','.');
		mapASCII.put('=2F','/');
		mapASCII.put('=30','0');
		mapASCII.put('=31','1');
		mapASCII.put('=32','2');
		mapASCII.put('=33','3');
		mapASCII.put('=34','4');
		mapASCII.put('=35','5');
		mapASCII.put('=36','6');
		mapASCII.put('=37','7');
		mapASCII.put('=38','8');
		mapASCII.put('=39','9');
		mapASCII.put('=3A',':');
		mapASCII.put('=3B',';');
		mapASCII.put('=3C','<');
		mapASCII.put('=3D','=');
		mapASCII.put('=3E','>');
		mapASCII.put('=3F','?');
		mapASCII.put('=40','@');
		mapASCII.put('=41','A');
		mapASCII.put('=42','B');
		mapASCII.put('=43','C');
		mapASCII.put('=44','D');
		mapASCII.put('=45','E');
		mapASCII.put('=46','F');
		mapASCII.put('=47','G');
		mapASCII.put('=48','H');
		mapASCII.put('=49','I');
		mapASCII.put('=4A','J');
		mapASCII.put('=4B','K');
		mapASCII.put('=4C','L');
		mapASCII.put('=4D','M');
		mapASCII.put('=4E','N');
		mapASCII.put('=4F','O');
		mapASCII.put('=50','P');
		mapASCII.put('=51','Q');
		mapASCII.put('=52','R');
		mapASCII.put('=53','S');
		mapASCII.put('=54','T');
		mapASCII.put('=55','U');
		mapASCII.put('=56','V');
		mapASCII.put('=57','W');
		mapASCII.put('=58','X');
		mapASCII.put('=59','Y');
		mapASCII.put('=5A','Z');
		mapASCII.put('=5B','[');
		mapASCII.put('=5C','\\');
		mapASCII.put('=5D',']');
		mapASCII.put('=5E','^');
		mapASCII.put('=5F','_');
		mapASCII.put('=60','`');
		mapASCII.put('=61','a');
		mapASCII.put('=62','b');
		mapASCII.put('=63','c');
		mapASCII.put('=64','d');
		mapASCII.put('=65','e');
		mapASCII.put('=66','f');
		mapASCII.put('=67','g');
		mapASCII.put('=68','h');
		mapASCII.put('=69','i');
		mapASCII.put('=6A','j');
		mapASCII.put('=6B','k');
		mapASCII.put('=6C','l');
		mapASCII.put('=6D','m');
		mapASCII.put('=6E','n');
		mapASCII.put('=6F','o');
		mapASCII.put('=70','p');
		mapASCII.put('=71','q');
		mapASCII.put('=72','r');
		mapASCII.put('=73','s');
		mapASCII.put('=74','t');
		mapASCII.put('=75','u');
		mapASCII.put('=76','v');
		mapASCII.put('=77','w');
		mapASCII.put('=78','x');
		mapASCII.put('=79','y');
		mapASCII.put('=7A','z');
		mapASCII.put('=7B','{');
		mapASCII.put('=7C','|');
		mapASCII.put('=7D','}');
		mapASCII.put('=7E','~');
		mapASCII.put('=0D','\r');
		mapASCII.put('=0A','\n');
	
  }
   
}