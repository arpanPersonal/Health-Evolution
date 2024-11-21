/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 03-24-2024
 * @last modified by  : surya.thakur
**/
public without sharing class B2B_PaymentRedirectController {
   /* public B2B_PaymentRedirectController() {

    }*/

    @AuraEnabled
    public static Map<String,Object> getPaymentLink(Map<String,Object> mapParams){
        try {
            B2B_PaymentRedirectService.getPaymentLink(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }
}