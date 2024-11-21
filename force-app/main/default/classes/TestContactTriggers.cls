@isTest
public with sharing class TestContactTriggers {


/*
    Created Groove Analytics LLC 4/4/2013
    Test class for OnContact trigger.  
*/

     private static testMethod void testSingleContact(){
 
        //insert account
        Account a = new Account(Name = 'Test Company');
        insert a;
        
        //insert contact
        Contact c = new Contact(AccountId = a.id, FirstName = 'FirstName', LastName = 'LastName',Outlook_Categories__c = 'Category1;Category2');
        insert c;
        
        //test category update
        c.Outlook_Categories__c = 'Category1;Category2;Category3';
        update c;
        
        //test non-category update
        c.LastName = 'Different';
        update c;

     }
     
    private static testMethod void testBulkContact(){

        //insert company account
        Account a = new Account(Name = 'Test Company');
        insert a;
        
        list<Contact> contactList = new list<Contact>();
        
        for (integer i = 0; i < 300; i++)
        {
        	Contact c = new Contact(AccountId = a.id, FirstName = 'Firstname',LastName='Lastname' + string.valueof(i),Outlook_Categories__c = 'Category1;Category2');
        	contactList.add(c);
        }
        
        //insert contacts
        insert contactList;
        
        
        for (Contact c : contactList)
        {
        	c.Outlook_Categories__c = 'Category1;Category2;Category3';
        }
        
        //update contacts
        update contactList;

     }
}