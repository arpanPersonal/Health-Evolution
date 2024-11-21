/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 04-01-2024
 * @last modified by  : surya.thakur
 * TestClass : B2bCustomSubLengthSelectorCntrlTest
**/
public without sharing class B2bCustomSubscriptionLengthSelectorCntrl {
    /*public B2bCustomSubscriptionLengthSelectorCntrl() {

    }*/

    @AuraEnabled
    public static Map<String,Object> getDisplayOptions(Map<String,Object> mapParams){
        try {
            B2bCustomSubscriptionLengthService.getDisplayOptions(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }
}