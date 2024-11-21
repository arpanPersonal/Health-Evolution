public class BoxFolderHandler implements Database.allowsCallouts {
    
    
    /// OPPORTUNITIES ///

	@future(callout=true)
    public static void moveOppFolder(Set<String> oppIds) {
        box.Toolkit bt = new box.Toolkit();
    	List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: oppIds];
		
        for (Opportunity opp : opps) {
            // get/create account box folder
            String accFolderId = bt.getFolderIdByRecordId(opp.AccountId);
            if (accFolderId == null) { accFolderId = bt.createFolderForRecordId(opp.AccountId, null, true); }
            
            // get/create opportunity box folder
            String oppFolderId = bt.getFolderIdByRecordId(opp.Id);
            if (oppFolderId == null) { oppFolderId = bt.createFolderForRecordId(opp.Id, null, true); }
            
            // move opportunity folder under account folder
            bt.moveFolder(oppFolderId, accFolderId, null);  
            
            // rename opportunity folder
            renameBoxFolder(oppFolderId, opp.Name, bt);
        }        
        
		bt.commitChanges();
    }
    
    @future(callout=true) 
    public static void updateOpp(Set<String> oppIds) {
        box.Toolkit bt = new box.Toolkit();
        
        List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id =: oppIds];
        
        for (Opportunity opp : opps) {
            String oppFolderId = bt.getFolderIdByRecordId(opp.Id);
            if (oppFolderId != null) { 
                renameBoxFolder(oppFolderId, opp.Name, bt); 
                                
                String accFolderId = bt.getFolderIdByRecordId(opp.AccountId);
            	if (accFolderId == null) { accFolderId = bt.createFolderForRecordId(opp.AccountId, null, true); }
                bt.moveFolder(oppFolderId, accFolderId, null);
            }
        }
        bt.commitChanges();
    }
    
    
    /// CONTACTS ///
    
    @future(callout=true)
    public static void moveContactFolder(Set<String> contactIds) {
        box.Toolkit bt = new box.Toolkit();
    	List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact WHERE Id =: contactIds];
		
        for (Contact contact : contacts) {
            // get/create account box folder
            String accFolderId = bt.getFolderIdByRecordId(contact.AccountId);
            if (accFolderId == null) { accFolderId = bt.createFolderForRecordId(contact.AccountId, null, true); }
            
            // get/create contact box folder
            String contactFolderId = bt.getFolderIdByRecordId(contact.Id);
            if (contactFolderId == null) { contactFolderId = bt.createFolderForRecordId(contact.Id, null, true); }
            
            // move contact folder under account folder
            bt.moveFolder(contactFolderId, accFolderId, null);
			
            // rename contact folder
			renameBoxFolder(contactFolderId, contact.Name, bt);            
        }        
        
		bt.commitChanges();
    }
    
    @future(callout=true) 
    public static void updateContact(Set<String> contIds) {
        box.Toolkit bt = new box.Toolkit();
        
        List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact WHERE Id =: contIds];
        
        for (Contact cont : conts) {
            String contFolderId = bt.getFolderIdByRecordId(cont.Id);
            if (contFolderId != null) { 
                renameBoxFolder(contFolderId, cont.Name, bt); 
                
                String accFolderId = bt.getFolderIdByRecordId(cont.AccountId);
            	if (accFolderId == null) { accFolderId = bt.createFolderForRecordId(cont.AccountId, null, true); }
                bt.moveFolder(contFolderId, accFolderId, null);
            }
            
            
        }
        bt.commitChanges();
    }
    
    /// ACCOUNTS /// 
    
    @future(callout=true) 
    public static void updateAccountName(Set<String> accIds) {
        box.Toolkit bt = new box.Toolkit();
        
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Id =: accIds];
        
        for (Account acc : accs) {
            String accFolderId = bt.getFolderIdByRecordId(acc.Id);
            if (accFolderId != null) { renameBoxFolder(accFolderId, acc.Name, bt); }
        }
        bt.commitChanges();
    }
    
    @future(callout=true)
    public static void handleMergedAccount(Set<String> accIds) {
        box.Toolkit bt = new box.Toolkit();
        
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Id =: accIds];
        
        for (Account acc : accs) {
            // create account folder
        	String accFolderId = bt.getFolderIdByRecordId(acc.Id);
            if (accFolderId == null) { accFolderId = bt.createFolderForRecordId(acc.Id, null, true); }
            
            // move contact folders
            List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId =: acc.Id];
            
            for (Contact cont : conts) {
            	String contFolderId = bt.getFolderIdByRecordId(cont.Id);
                if (contFolderId != null) { bt.moveFolder(contFolderId, accFolderId, null); }
            }
            
            // move opportunity folders
            List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId =: acc.Id];
            
            for (Opportunity opp : opps) {
            	String oppFolderId = bt.getFolderIdByRecordId(opp.Id);
                if (oppFolderId != null) { bt.moveFolder(oppFolderId, accFolderId, null); }
            }                       
        }
        
        bt.commitChanges();        
    }
    
    /// UTILS ///
    
	public static HttpResponse renameBoxFolder(String boxFolderId, String folderName, box.Toolkit boxToolkit){
        // rename box folder using Box API
        HttpRequest request = new HttpRequest();
        request.setEndpoint(
            'https://api.box.com/2.0/folders/' + boxFolderId
        );
        request.setMethod('PUT');
        request.setBody('{"name": "' + folderName + '"}');
        HttpResponse response;
        if(Test.isRunningTest()){
        	response = BoxMockHttpResponseGenerator.respond(request);
        } else {
        	response = boxToolkit.sendRequest(request);
        }

        return response;
  	}

}