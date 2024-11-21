public without sharing class B2BProductDetail {
    
    @AuraEnabled(cacheable=true)
    public static FellowshipPriceWrapper getFellowPrice(String productId) {
        String effectiveContactId = B2BUtils.getUserContactId();
        
        Contact contact = [SELECT Id, Fellow_Level__c FROM Contact WHERE Id = :effectiveContactId LIMIT 1];
        
        List<Fellowship_Price__c> fpList = [
            SELECT Id, Price__c, Renewal_Price__c, Initial_Payment_Amount__c 
            FROM Fellowship_Price__c 
            WHERE Fellowship__c = :contact.Fellow_Level__c 
            AND ProductId__c = :productId 
            AND Paid_Upfront__c = false 
            LIMIT 1
        ]; 
        if (fpList.isEmpty()) {
            return null;
        }  
        Fellowship_Price__c fp = fpList[0];
        FellowshipPriceWrapper fpw = new FellowshipPriceWrapper();
        fpw.totalPrice = fp.Price__c;
        fpw.initalPaymentAmount = fp.Initial_Payment_Amount__c;
        fpw.renewalPrice = fp.Renewal_Price__c;
        return fpw;
    }
    public class FellowshipPriceWrapper {
        @AuraEnabled
        public Decimal totalPrice;
        @AuraEnabled
        public Decimal initalPaymentAmount;
        @AuraEnabled
        public Decimal renewalPrice;
    }
}