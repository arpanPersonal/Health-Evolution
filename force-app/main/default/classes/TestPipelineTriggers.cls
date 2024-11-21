@isTest
public with sharing class TestPipelineTriggers {
/*
    Created Groove Analytics LLC 9/11/2012
    Test class for trgUpdateTopStage trigger on Pipeline object.
*/

     private static testMethod void testSinglePipe(){
    
       //SOQL to get company record type id
        RecordType rType1 = [Select Name From RecordType Where SobjectType = 'Account' And Name = 'Company' And IsActive = true];
        Id idCompanyRecordType = rType1.id;

        //insert company account
        Account accCompany = new Account(Name = 'Test Investor', RecordTypeId = idCompanyRecordType);
        insert accCompany;
        
        Pipeline__c p = new Pipeline__c(Company__c = accCompany.id, Stage__c = '0. Portfolio Company');
        insert p;
        
        Pipeline__c p1 = new Pipeline__c(Company__c = accCompany.id); //null stage
        insert p1;
        
        p1.Stage__c = '0. Portfolio Company';
        update p1;
        
        clsStopRecursiveTrigger.runTrigger = true;
        
        p1.Stage__c = '4. Investigation';
        update p1;

     }
     
     private static testMethod void testBulkPipe(){
    
        //SOQL to get company record type id
        RecordType rType1 = [Select Name From RecordType Where SobjectType = 'Account' And Name = 'Company' And IsActive = true];
        Id idCompanyRecordType = rType1.id;

        //insert company account
        Account accCompany = new Account(Name = 'Test Investor', RecordTypeId = idCompanyRecordType);
        insert accCompany;
        
        list<Pipeline__c> listP = new list <Pipeline__c>();
        
        for (integer i=0;i<250;i++){
            
            Pipeline__c p = new Pipeline__c(Company__c = accCompany.id, Stage__c = '0. Portfolio Company');
            listP.add(p);
        }
        
        if (listP.size() > 0){
            insert listP;
            
            for (Pipeline__c p : listP){
                p.Stage__c = '4. Investigation';
            }
            update listP;
        }

     }

}