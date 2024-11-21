global class InboundVCardProcessor implements Messaging.InboundEmailHandler {
 /*
 
    Created by ASC Groove Analytics LLC
    
    TODO: mapContactFields should be public member of support class 
 
 */

 
     
  global messaging.Inboundemailresult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) 
  {
 	String FROMADDRESS = 'invalid@email.address';
 	String ToAddress;
 	String SenderAddress;
 	map<string,string> mapHeaders = new map<string,string>();
 	map<string,string> mapContactFields = new map<string,string>();
 	
 	for (integer i = 0; i < email.Headers.size(); i++)
    {
    	system.debug(email.Headers[i].name);
    	system.debug(email.Headers[i].value);
    	mapHeaders.put(email.Headers[i].name,email.Headers[i].value);
    }
 	
 	//not using the envelope members intentionally
 	SenderAddress = mapHeaders.get('From');
 	ToAddress = mapHeaders.get('To');
 	
    //original email may have been sent to a distribution list or contact which fowarded to the email service
    //need to determine the correct addresses to get the proper VCConfig	    	
	if (mapHeaders.get('X-Forwarded-To') != null || mapHeaders.get('Resent-From') != null)
	{	
		if(mapHeaders.get('Delivered-To') != null) 
		{
			ToAddress = mapHeaders.get('Delivered-To');
		}
	}
    
    //just in case
    if (SenderAddress == null) SenderAddress = envelope.FromAddress;
    if (ToAddress == null) ToAddress = envelope.ToAddress;
    
    //Clean up addresses
    if (SenderAddress.contains(' '))
	{
		//need to get rid of non email address stuff (e.g. name) in the From header
		//seems like the easiest way to do it
		string[] s = SenderAddress.split(' ');
		SenderAddress = s[s.size() - 1];
	}

    if (ToAddress.contains(' '))
	{
		string[] s = ToAddress.split(' ');
		ToAddress = s[s.size() - 1];
	}
	
	SenderAddress = SenderAddress.remove('>').remove('<');
	ToAddress = ToAddress.remove('>').remove('<');
	
    //system.debug('look here');
    //system.debug('SenderAddress ' + SenderAddress);
	//system.debug('envelope from address: ' + envelope.FromAddress);
	//system.debug('ToAddress ' + ToAddress);
	//system.debug('envelope to address ' + envelope.ToAddress);
	//SenderAddress = 'scamozzi@grooveanalytics.com';
    //system.debug(email.plainTextBody);

    //instantiate support class
    InboundVCardSupport ivcs = new InboundVCardSupport(ToAddress);
    
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    
    if (ivcs.VCConfig == null)
    {
    	system.debug('ERROR: VCConfig is null! Bailing.');
	    boolean bReturnCode = ivcs.sendNotificationEmail(ivcs.constructNotificationString('Error processing vCard:\r\nNo VCard Configuration found for ' + ToAddress + '.\r\n',mapContactFields), SenderAddress, FROMADDRESS); 		
    	return result;
    }

    if (email.textAttachments != null && email.textAttachments.size() > 0 && email.textAttachments.size() < 11)
    {
        for (integer i = 0 ; i < email.textAttachments.size() ; i++) 
        {
            //only process attachments with the right mime types
            if(email.textAttachments[i].mimeTypeSubType == 'text/vcard'
                || email.textAttachments[i].mimeTypeSubType == 'text/directory' //deprecated according to rfc
                || email.textAttachments[i].mimeTypeSubType == 'text/directory;profile=vCard' //deprecated according to rfc
                || email.textAttachments[i].mimeTypeSubType == 'text/x-vcard' //deprecated according to rfc. Of course Outlook 2010 uses it.
              )
            {
          		//split attachment body into an array of lines
            	String[] sLineArray = email.textAttachments[i].body.split('\n'); 
            	
            	//parse array and put fields and values in map
               	mapContactFields = ivcs.parseVCardArray(sLineArray);
               
               	//check for completeness of vcard. go to next attachment if incomplete.
               	if (!ivcs.isVCardComplete(mapContactFields))
               	{
               		boolean bReturnCode = ivcs.sendNotificationEmail(ivcs.constructNotificationString('Error processing vCard:\r\nContact must contain Firstname, Lastname, Email and Company. Person must contain Firstname, Lastname, and Email.\r\n',mapContactFields), SenderAddress, FROMADDRESS);
               		continue;
               	}
               
                //check if contact already exists. if it does, continue to next attachment.
                String sPreviousContactResult = ivcs.doGetPreviousContact(mapContactFields);
                
                if (sPreviousContactResult != 'OK')
                {
                	boolean bReturnCode = ivcs.sendNotificationEmail(ivcs.constructNotificationString('Error processing vCard:\r\nAt least one matching contact already exists. First match: ' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api.', '.') + '/' + sPreviousContactResult,mapContactFields), SenderAddress, FROMADDRESS);
                 	continue;
                }
                
                //handle the contact parent account if necessary
                if (ivcs.VCConfig.PersonAccount__c == false)
                {
                	ivcs.doGetParentAccountId(mapContactFields);
                }
                
                //insert contact/person
                string sRetVal = ivcs.doInsertContact(mapContactFields, envelope.fromaddress);
                
                if (sRetVal.left(6) == 'ERROR:')
                {
               		boolean bReturnCode = ivcs.sendNotificationEmail(ivcs.constructNotificationString('Error processing vCard: An Exception Occurred: ' + sRetVal,mapContactFields), envelope.fromaddress, FROMADDRESS);
                }
                else
                {
 					boolean bReturnCode = ivcs.sendNotificationEmail(ivcs.constructNotificationString('Contact successfully added to Salesforce: ' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api.', '.') + '/' + sRetVal,mapContactFields), SenderAddress, FROMADDRESS);
                           	
                }             
            } 
            else
            {
            	system.debug('unexpected mime type'); //don't die, skip to next attachment
                //boolean bReturnCode = ivcs.sendNotificationEmail('Error processing vCard: Unable to process text attachment type.\r\nFilename: ' + email.textAttachments[i].filename + '\r\n', SenderAddress, FROMADDRESS);        
                continue;
            } 
         } 
    } 
    else if (email.textAttachments != null && email.textAttachments.size() > 10)
    {
    	boolean bReturnCode = ivcs.sendNotificationEmail(ivcs.constructNotificationString('Error processing vCard message: Too Many Attachments. Max is 10. Reduce the number of attachments in your message and try again.',mapContactFields), SenderAddress, FROMADDRESS);                  
    	return result;
    }
    else
    {
    	system.debug('no attachments found');
    	//boolean bReturnCode = ivcs.sendNotificationEmail('Error processing vCard: No vCard attachments found.', SenderAddress, FROMADDRESS);        
    	return result;
    } 
    
    return result;   
  }

 
}