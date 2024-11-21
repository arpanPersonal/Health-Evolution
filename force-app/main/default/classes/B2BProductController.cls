public without sharing class B2BProductController {
    @AuraEnabled
    public static B2BProductHelper.ProductValidation getPricingResponseItem(String productId){
        System.debug('B2BProductController');
        return B2BProductHelper.getPricingResponseItem( productId);
    }

    @AuraEnabled
    public static Boolean doesProductHasPrice(String productId) {
        Boolean result = false;
        String contactId = B2BUtils.getUserContactId();
        
        Contact contact = [SELECT Id, Fellow_Level__c FROM Contact WHERE Id = :contactId];
        String fellowshipLevel = contact.Fellow_Level__c;
            
        List<Fellowship_Price__c> fellowshipPrices = [SELECT Id, Price__c, ProductId__c, Non_Discounted_Price__c 
                                                      FROM Fellowship_Price__c 
                                                      WHERE ProductId__c =:productId AND Fellowship__c = :fellowshipLevel];

        if(fellowshipPrices.size() > 0) {
            if(fellowshipPrices[0].Price__c != null) {
                result = true;
            }
        }
        return result;
    }
}