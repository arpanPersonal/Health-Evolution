public without sharing class B2BCheckoutHelper {

    @AuraEnabled
    public static String setCartDeliveryGroup (String cartId) {
        List<CartDeliveryGroup> cdgs = [Select Id,  DeliveryMethodId, DeliverToName FROM CartDeliveryGroup where CartId =:cartId];
        List <OrderDeliveryMethod> odm = [Select id from OrderDeliveryMethod];
        cdgs[0].DeliverToName = 'Placeholder Name';
        cdgs[0].DeliveryMethodId = odm[0].Id;
        update cdgs[0];

        List<WebCart> wc = [Select Id from webcart WHERE Id =:cartId LIMIT 1];
        wc[0].PoNumber = 'NA';
        update wc[0];
        return cdgs[0].Id;
    }
}