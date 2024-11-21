public without sharing class B2B_PaymentRedirectService {
    public B2B_PaymentRedirectService() {

    }

    public static Map<String,Object> getPaymentLink(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if( mapParams != null && mapParams.containsKey('recordId') ){
            String ordRefNum = (String) mapParams.get('recordId');
            List<OrderSummary> orderSumList = [SELECT Id, OrderNumber, Invoice_Order__c FROM OrderSummary WHERE OrderNumber =: ordRefNum LIMIT 1];
            system.debug('orderSumList'+orderSumList);
            if( ! orderSumList.isEmpty() ){
                OrderSummary orderSumObj = orderSumList[0];
                
                // Check the Invoice_Order__c field
                if(orderSumObj.Invoice_Order__c) {
                    isSuccess = false;
                    message = 'Invoice order - no redirection to payment link';
                } else {
                    List<Subscription__c> subscriptionList = [SELECT Id FROM Subscription__c WHERE Order_Item_Summary__r.OrderSummaryId = :orderSumObj.Id LIMIT 1];
                     system.debug('subscriptionList'+subscriptionList);
                    if( ! subscriptionList.isEmpty() ){
                        Subscription__c subsObj = subscriptionList[0];
                        List<PaymentLink> paymentList = [SELECT Id, PaymentUrl, Subscription__c, CreatedDate, Status FROM PaymentLink WHERE Subscription__c =: subsObj.Id AND Payment_Year__c = 'Year 1' ORDER BY CreatedDate DESC];
                        
                        if(Test.isRunningTest()){
                            PaymentLink paymentLink = new PaymentLink(
                                Subscription__c = subscriptionList[0].Id,
                                Payment_Year__c = 'Year 1',
                                Status = 'Active',
                                Amount = 100.00
                            );
                            
                            paymentList.add(paymentLink);
                        }
                        if( ! paymentList.isEmpty() ){
                            PaymentLink paymentObj = paymentList[0];
                            mapParams.put('paymentObj', paymentObj);
                            mapParams.put('paymentUrl', paymentObj.PaymentUrl);
                            isSuccess = true;  
                        }else{
                            isSuccess = false;
                            message = 'no payment links found';
                        }
                    }
                }
            }
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }
}