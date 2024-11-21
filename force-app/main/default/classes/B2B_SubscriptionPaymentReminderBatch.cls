/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 05-17-2024
 * @last modified by  : surya.thakur
**/
public without sharing class B2B_SubscriptionPaymentReminderBatch implements Database.Batchable<sObject>, Database.Stateful, schedulable{

    public Id recordId;
 
    public B2B_SubscriptionPaymentReminderBatch(){
        
    }

    public B2B_SubscriptionPaymentReminderBatch(Id recId){
        recordId = recId;
    }
 
    public Database.QueryLocator start(Database.BatchableContext bc){
        if( ! String.isBlank(recordId)){
            return Database.getQueryLocator([
                SELECT Id
                FROM Subscription__c 
                WHERE Id =: recordId
            ]);
        }

        Date todayDate = Date.Today();
        Date daysRemaining14 = todayDate.addDays(14);
        Date daysRemaining30 = todayDate.addDays(30);
        Date daysRemaining60 = todayDate.addDays(60);
        return Database.getQueryLocator([
            SELECT Id
            FROM Subscription__c 
            WHERE Next_Payment_Date__c =: todayDate OR Next_Payment_Date__c =: daysRemaining14 OR Next_Payment_Date__c =: daysRemaining30 OR Next_Payment_Date__c =: daysRemaining60
        ]);
    }
 
    public void execute(Database.BatchableContext bc, List<Subscription__c> scope){
        //dummy update, it will trigger the RTF.
        update scope;
     }
 
    public void finish(Database.BatchableContext bc){

    }

    public void execute(SchedulableContext sc)
    {   
        //batch size 1.
        database.executeBatch(new B2B_SubscriptionPaymentReminderBatch(),1);
    }
 }