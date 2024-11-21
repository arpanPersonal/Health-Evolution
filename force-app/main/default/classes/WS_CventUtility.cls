/*-********************************************************************************************************
* Name         : WS_CventUtility
* @Author      : Vikram Singh(vikram@wiserspread.com)
* @Date        : 23-May-2017
* @Description : This apex class does  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            vikram                       23-May-2017                   Initial Creation 
****************************************************************************************************************/
global class WS_CventUtility implements Database.Batchable<sobject> , database.allowscallouts, database.stateful {
	public list<list<string>> IdListToPassToBatch;
	global database.QueryLocator start(Database.BatchableContext bc){
    	string query = 'select id from user limit 1';
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<user> scope){
    	//database.executeBatch(new ws_BatchToUpdateContactImage(contactListToUpdate), 1);
    	try{
    		IdListToPassToBatch = new list<list<string>>();
	        //public schemasCventComApi200611.V200611Soap cvent = new schemasCventComApi200611();
	        schemasCventComApi200611.V200611Soap sc = new schemasCventComApi200611.V200611Soap();
	        schemasCventComApi200611.GetUpdatedResult contactIdArray = new schemasCventComApi200611.GetUpdatedResult();
	        
	        schemasCventComApi200611.LoginResult loginResult = new schemasCventComApi200611.LoginResult();
	        
	        
	        //if(!Test.isRunningTest()){
	            loginResult = sc.Login('HEMCLCA001', 'HEMCLCA001Api', '3KXqYHpkcZc');
	            System.debug('***loginResult***'+loginResult);
	        //}
	        
	        schemasCventComApi200611.CventSessionHeader sessHeader = new schemasCventComApi200611.CventSessionHeader();
	        sessHeader.CventSessionValue = loginResult.CventSessionHeader;
	        
	        sc.CventSessionHeader = sessHeader;
	        
	        system.debug('=tempLoginData===='+loginResult.ServerURL);
	        system.debug('=tempLoginData CventSessionHeader===='+loginResult.CventSessionHeader);
	        
	        
	        
	      // if(!Test.isRunningTest()){
	            contactIdArray = sc.GetUpdated('Invitee', system.now().addDays(-30), system.now());
	           // system.debug('****contactIdArray***'+contactIdArray );
	       // }
	       string[] tempIdList = new list<string>();
	       tempIdList = contactIdArray.id;
	        //ids.Id = contactIdArray.id;
	        //ids.Id.addAll(mapOfSourceIdVsInvitee.keySet());
	       /* ids.Id.add('747e4775-3bc1-4dd3-aa48-a8239e1af330'); 
	        ids.Id.add('c8bbe8e0-88cd-4bda-8c5a-456ccf57a4d7');
	        ids.Id.add('43b66170-e08c-4c2b-b158-8a116839b64a');
	       */ 
	        
	        //-------getting invitees here
	        
	       // if(!Test.isRunningTest()){
	       
	       if(tempIdList != null && tempIdList.size() > 100){
	       		integer i = 0;
	       		
	       		list<string> newlist = new list<string>();
	       		for(string s : tempIdList){
	       			newList.add(s);
		        	
		        	if(newList.size() == 100){
		        		IdListToPassToBatch.add(newlist);
		        		newlist = new list<string>();
		        		
		        	}
		        }
		        if(newlist != null && !newlist.isEmpty() && newlist.size() > 0){
		        	system.debug('---templist is '+newlist.size()+'=='+newlist);
		        	IdListToPassToBatch.add(newlist);
		        }
	       }else if(tempIdList != null && tempIdList.size() > 0){
	       		IdListToPassToBatch.add(tempIdList);
	       }
       
        
        }catch(exception e){system.debug('--exception is -'+e.getmessage()+e.getLinenumber());}
    }
    global void finish(Database.BatchableContext BC){
    	system.debug('---- inside finish'+IdListToPassToBatch);
		if(IdListToPassToBatch != null && !IdListToPassToBatch.isEmpty()){
			system.debug('---- inside finish'+IdListToPassToBatch);
       		database.executeBatch(new WS_CventHelper(IdListToPassToBatch), 1);
       }
    }
       
}