public without sharing class B2BCustomPricingService extends commercestorepricing.PricingService {
    public override commercestorepricing.PricingResponse processPrice(commercestorepricing.PricingRequest request) {
        String methodName = 'processPrice';
        System.debug('Entering ' + methodName);

        String effectiveContactId = B2BUtils.getUserContactId();
        System.debug('Effective Contact ID: ' + effectiveContactId);

        Contact contact = [SELECT Id, Fellow_Level__c FROM Contact WHERE Id = :effectiveContactId];
        String fellowshipLevel = contact.Fellow_Level__c;
        System.debug('Fellowship Level: ' + fellowshipLevel);

        List<Fellowship_Price__c> fellowshipPrices = [SELECT Id, Price__c, ProductId__c, Non_Discounted_Price__c FROM Fellowship_Price__c WHERE Fellowship__c = :fellowshipLevel];
        System.debug('Fellowship Prices: ' + fellowshipPrices);

        commercestorepricing.PricingResponse response = new commercestorepricing.PricingResponse('USD');
        commercestorepricing.PricingRequestItemCollection items = request.getPricingRequestItems();
        System.debug('Pricing Request Items: ' + items);

        for (Integer i = 0; i < items.size(); i++) {
            commercestorepricing.PricingRequestItem item = items.get(i);
            String productId = item.getProductId();
            System.debug('Processing item with Product ID: ' + productId);

            Decimal productPrice = null;
            Decimal nonDiscountedPrice = null;
            for(Fellowship_Price__c fellowshipPrice : fellowshipPrices) {
                if(fellowshipPrice.ProductId__c == productId) {
                    productPrice = fellowshipPrice.Price__c;
                    nonDiscountedPrice = fellowshipPrice.Non_Discounted_Price__c;
                    System.debug('Matched Fellowship Price: ' + fellowshipPrice);
                    break;
                }
            }

            commercestorepricing.PricingResponseItem responseItem = new commercestorepricing.PricingResponseItem(productId, null, null, nonDiscountedPrice, productPrice);
            response.addPricingResponseItem(responseItem);
        }

        System.debug('Pricing Response: ' + response);
        System.debug('Exiting ' + methodName);
        return response;
    }

    public override commercestorepricing.TransactionalPricingResponse processTransactionalPrice(commercestorepricing.TransactionalPricingRequest request2) {
        String methodName = 'processTransactionalPrice';
        System.debug('Entering ' + methodName);

        String effectiveContactId = B2BUtils.getUserContactId();
        System.debug('Effective Contact ID: ' + effectiveContactId);

        Contact contact = [SELECT Id, Fellow_Level__c FROM Contact WHERE Id = :effectiveContactId];
        String fellowshipLevel = contact.Fellow_Level__c;
        System.debug('Fellowship Level: ' + fellowshipLevel);

        List<Fellowship_Price__c> fellowshipPrices = [SELECT Id, Price__c, ProductId__c FROM Fellowship_Price__c WHERE Fellowship__c = :fellowshipLevel];
        System.debug('Fellowship Prices: ' + fellowshipPrices);

        commercestorepricing.TransactionalPricingResponse objPricingResponse;
        if(!Test.isRunningTest()){
            objPricingResponse = super.processTransactionalPrice(request2);
        } else {
            objPricingResponse = B2BTransactionalPricingResponseMock.processTransactionalPrice();
        }
        System.debug('Transactional Pricing Response: ' + objPricingResponse);

        commercestorepricing.TxnPricingResponseItemCollection lstItemCollection = objPricingResponse.getTxnPricingResponseItems();
        System.debug('Transaction Pricing Response Items: ' + lstItemCollection);

        Decimal totalCartListPrice = 0;
        Decimal totalCartProductAmount = 0;

        for (Integer i = 0; i < lstItemCollection.size(); i++) {
            commercestorepricing.TransactionalPricingResponseItem txnItem = lstItemCollection.get(i);
            String productId = txnItem.getProductId();
            System.debug('Processing item with Product ID: ' + productId);

            Decimal productPrice = null;

            for (Fellowship_Price__c fellowshipPrice : fellowshipPrices) {
                if (fellowshipPrice.ProductId__c == productId) {
                    productPrice = fellowshipPrice.Price__c;
                    System.debug('Matched Fellowship Price: ' + fellowshipPrice);
                    break;
                }
            }

            if (productPrice != null) {
                txnItem.setUnitPrice(productPrice);
                txnItem.setListPrice(productPrice);
                Decimal totalPrice = txnItem.getQuantity() * productPrice;
                txnItem.setTotalLineAmount(totalPrice);
                txnItem.setTotalListPrice(totalPrice);
                txnItem.setTotalPrice(totalPrice);

                totalCartListPrice += totalPrice;
                totalCartProductAmount += totalPrice;
            }
        }

        objPricingResponse.setTotalListPrice(totalCartListPrice);
        objPricingResponse.setTotalProductAmount(totalCartProductAmount);
        objPricingResponse.setTotalAmount(objPricingResponse.getTotalProductAmount() + objPricingResponse.getTotalAdjustmentAmount());

        System.debug('Total List Price: ' + totalCartListPrice);
        System.debug('Total Product Amount: ' + totalCartProductAmount);
        System.debug('Total Amount: ' + objPricingResponse.getTotalAmount());
        System.debug('Exiting ' + methodName);

        return objPricingResponse;
    }
}