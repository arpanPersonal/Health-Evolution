/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : surya.thakur
**/
public without sharing class B2BCreateHistrorcialSubs_PaymentLinks implements Database.Batchable<sObject>, Database.Stateful, schedulable{

    public Id recordId;
 
    public B2BCreateHistrorcialSubs_PaymentLinks(){
        
    }

    public B2BCreateHistrorcialSubs_PaymentLinks(Id recId){
        recordId = recId;
    }
 
    public Database.QueryLocator start(Database.BatchableContext bc){
        if( ! String.isBlank(recordId) ){
            return Database.getQueryLocator([
                SELECT Id, Historical_Subscription__c, Inital_Payment_Amount__c, Annual_Payment_Amount__c, Total_Amount__c, 
                Payments_Made__c, Type__c, Contact__r.AccountId
                FROM Subscription__c 
                WHERE Id =: recordId
            ]);
        }

        return Database.getQueryLocator([
            SELECT Id, Historical_Subscription__c, Inital_Payment_Amount__c, Annual_Payment_Amount__c, Total_Amount__c, 
            Payments_Made__c, Type__c, Contact__r.AccountId
            FROM Subscription__c 
            WHERE Historical_Subscription__c = true
        ]);
    }
 
    public void execute(Database.BatchableContext bc, List<Subscription__c> scope){
        List<PaymentLink> payLinksToInsert = new List<PaymentLink>();
        String paymentMethodSetId = '';
        try {
            // Query to select Id from MerchAccPaymentMethodSet
            MerchAccPaymentMethodSet paymentMethodSet = [SELECT Id FROM MerchAccPaymentMethodSet LIMIT 1];
            if (paymentMethodSet != null) {
                paymentMethodSetId = paymentMethodSet.Id;
            }
        }
        catch (QueryException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        for(Subscription__c sub : scope){
            if( sub.Type__c.contains('Annual') ){
                String subTermString = sub.Type__c.contains('3') ? '3' : sub.Type__c.contains('2') ? '2' : '1';
                Integer subTerm = Integer.valueOf(subTermString);
                Integer paidAlready = Integer.valueOf(sub.Payments_Made__c);
                for(Integer i = 0; i < subTerm; i++){
                    String statusVal = 'Active';
                    if( i + 1 == paidAlready ){
                        statusVal = 'Disabled';
                    }
                    Decimal amnt;
                    if(i == 0){
                        amnt = sub.Inital_Payment_Amount__c;
                    }else{
                        amnt = sub.Annual_Payment_Amount__c;
                    }
                    String payYear = i == 0 ? 'Year 1' : i == 1 ? 'Year 2' : 'Year 3';
                    PaymentLink link = new PaymentLink(
                        Payment_Year__c = payYear,
                        Subscription__c = sub.Id,
                        AccountId = sub.Contact__r.AccountId,
                        PaymentMethodSetId = paymentMethodSetId,
                        Amount = amnt,
                        UsageType = 'SingleUse',
                        Status = statusVal
                    );
                    payLinksToInsert.add(link);
                }
            }else{
                String subTermString = sub.Type__c.contains('3') ? '3' : sub.Type__c.contains('2') ? '2' : '1';
                Integer subTerm = Integer.valueOf(subTermString);
                Integer paidAlready = Integer.valueOf(sub.Payments_Made__c);
                String payYear = 'Year 1';
                Decimal amnt = sub.Total_Amount__c;
                String statusVal = paidAlready == 0 ? 'Active' : 'Disabled';
                PaymentLink link = new PaymentLink(
                        Payment_Year__c = payYear,
                        Subscription__c = sub.Id,
                        AccountId = sub.Contact__r.AccountId,
                        PaymentMethodSetId = paymentMethodSetId,
                        Amount = amnt,
                        UsageType = 'SingleUse',
                        Status = statusVal
                    );
                payLinksToInsert.add(link);
            }
        }
        System.debug('payLinksToInsert------ '+payLinksToInsert);
        insert payLinksToInsert;
    }
 
    public void finish(Database.BatchableContext bc){

    }

    public void execute(SchedulableContext sc)
    {   
        //batch size 1.
        database.executeBatch(new B2BCreateHistrorcialSubs_PaymentLinks(),1);
    }
 }