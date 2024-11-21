/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 04-01-2024
 * @last modified by  : surya.thakur
 * @testClass : B2bCustomSubLengthSelectorCntrlTest
**/
public without sharing class B2bCustomSubscriptionLengthService {
    public B2bCustomSubscriptionLengthService() {

    }

    public static Map<String,Object> getDisplayOptions(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        String customLabelValue = System.Label.B2B_PDP_Display_Options;
        List<String> prodNameList = customLabelValue.split(',');
        System.debug('getDisplayOptions prodNameList---- '+ prodNameList);
        if( ! prodNameList.isEmpty() ){
            List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Name =: prodNameList];
            List<ResponseMap> respMapVal = new List<ResponseMap>();
            for(Product2 prod : prodList){
                ResponseMap obj = new ResponseMap();
                obj.value = prod.Id;
                obj.label = prod.Name;
                respMapVal.add(obj);
            }
            if( ! respMapVal.isEmpty() ){
                ResponseVO respOptionVal = new ResponseVO();
                respOptionVal.respMap = respMapVal;
                System.debug('getDisplayOptions respOptionVal---- '+ JSON.serialize(respOptionVal));
                mapParams.put('respOptionVal', respOptionVal);
                isSuccess = true;
            }
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public class ResponseVO{
        @AuraEnabled public List<ResponseMap> respMap;
    }

    public class ResponseMap{
        @AuraEnabled public String value;
        @AuraEnabled public String label;
    }
    
   
}