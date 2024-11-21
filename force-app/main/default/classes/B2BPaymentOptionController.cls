public with sharing class B2BPaymentOptionController {
    @AuraEnabled
    public static void updateWebCartPaymentOption(String cartId, Boolean isInvoiceOrder){

        WebCart wc = [SELECT Id,Invoice_Order__c FROM WebCart WHERE Id =: cartId];
        wc.Invoice_Order__c = isInvoiceOrder;
        update wc;
    }
}