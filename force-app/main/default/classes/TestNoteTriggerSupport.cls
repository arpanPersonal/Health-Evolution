/**
* @company        
* @author        
* @date         08/30/2016
* @description  Test class for NoteTrigger -> NoteTriggerSupport
* @modifications
* 9/23/2016	Now adds Accounts based on text in body of Notes.	
*/

@isTest
private class TestNoteTriggerSupport {

    static testMethod void testSingle(){
        String WOOFOOTITLE = 'Apply to Participate';
        String TESTACCOUNT = 'Test Account2';
        String COMPANYSTART = 'STARTCOMPANY-->';
        String COMPANYEND = '<--ENDCOMPANY';
        String TESTBODY = 'lorem ipsum' + COMPANYSTART + TESTACCOUNT + COMPANYEND + 'lorem ipsum';
        
        Contact c = new Contact (LastName = 'LastName');
        insert c;
        Contact c1 = new Contact (LastName = 'LastName1');
        insert c1;
        
        Account a = new Account (Name = 'TestAccount');
        insert a;
 
        Summit__c sm = new Summit__c (Begin_Date__c = date.today().addDays(365));
        insert sm;
        sm = new Summit__c (Begin_Date__c = date.today().addDays(-1));
        insert sm;
        sm = new Summit__c (Begin_Date__c = date.today().addDays(-366));
        insert sm;       
        
        Note n = new Note(ParentId = a.id,Title = 'Some Nonsense', Body = 'lorem ipsum');
        insert n;
        
        n = new Note(ParentId = a.id,Title = WOOFOOTITLE, Body = 'lorem ipsum');
        insert n;
        
        List<Summit_Status__c> ss = [Select Id From Summit_Status__c];
        
        system.assertEquals(0,ss.size());
        
        n = new Note(ParentId = c.id,Title = WOOFOOTITLE, Body = TESTBODY);
        insert n;
        
        ss = [Select Id From Summit_Status__c];
        
        system.assertEquals(1,ss.size());
        
        c = [Select Id, AccountId, Created_by_Wufoo__c From Contact Where Id = :c.Id];
        a = [Select Id, Name From Account Where Name = :TESTACCOUNT Limit 1];
        
        system.assertEquals('Yes',c.Created_by_Wufoo__c);
        system.assertEquals(a.Id,c.AccountId);
        system.assertEquals(TESTACCOUNT,a.Name);
        
        n = new Note(ParentId = c1.id,Title = WOOFOOTITLE, Body = 'lorem ipsum'); //should get attached to unknown account
        insert n;
        
        c = [Select Id, AccountId, Created_by_Wufoo__c From Contact Where Id = :c1.Id];
        a = [Select Id, Name From Account Where Name = 'Unknown' Limit 1];
        
        system.assertEquals('Yes',c.Created_by_Wufoo__c);
        system.assertEquals(a.Id,c.AccountId);
    }
 
    static testMethod void testBulk(){
        
        String WOOFOOTITLE = 'Apply to Participate';
        String UNKNOWNACCOUNT = 'Unknown';
        String COMPANYSTART = 'STARTCOMPANY-->';
        String COMPANYEND = '<--ENDCOMPANY';
        
        List<Contact> lc = new List<Contact>();
        for (integer i = 0; i < 100; i++){
         	Contact c = new Contact (LastName = 'LastName' + String.valueOf(i)); 
         	lc.add(c);
        }
        insert lc;
        
        Account a = new Account(Name = 'Some Account');
        insert a;
     
		List<Summit__c> ls = new List<Summit__c>();
        for (integer i = 20; i > 0; i--){
        	Summit__c sm = new Summit__c (Begin_Date__c = date.today().addYears(-i));
        	ls.add(sm);        
        }
        Summit__c sm = new Summit__c (Begin_Date__c = date.today().addYears(1));
        ls.add(sm); 
        insert(ls);     
        
        test.startTest();
        
        //this loop should add 200 notes, causing 100 accounts to be created, and 100 contacts to be updated
        List<Note> ln = new List<Note>();
        for (integer i = 0; i < 100; i++){
            String body = 'lorem ipsum ' + COMPANYSTART + 'TestAccount' + String.valueOf(i) + COMPANYEND + ' lorem ipsum';
  			Note n = new Note(ParentId = lc[i].id,Title = WOOFOOTITLE, Body = body); 
            ln.add(n);
            n = new Note(ParentId = a.id,Title = 'Some Nonsense', Body = 'lorem ipsum'); 
            ln.add(n);
        }
        insert(ln);
     
        List<Summit_Status__c> ss = [Select Id From Summit_Status__c];      
        system.assertEquals(100,ss.size());  
        
        List<Account> la = [Select Id,Name From Account];
        system.assertEquals(102,la.size()); //100 from loop, one 'Some Account', one 'Unknown'
        
        lc.clear();
        lc = [Select Id, Name, AccountId, Created_by_Wufoo__c From Contact];
        for (Contact c : lc){
         	system.assertEquals('Yes',c.Created_by_Wufoo__c);           
        }

        la.clear();
        la = [Select Id From Account Where Id = :lc[0].AccountId];
        system.assertEquals(1,la.size());
        
        test.stopTest();

    }
}