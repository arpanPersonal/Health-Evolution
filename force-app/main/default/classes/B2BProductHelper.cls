public without sharing class B2BProductHelper {
    private static string CLASS_NAME = 'B2BProductHelper';
    public static ProductValidation getPricingResponseItem(String productId){
        string METHOD_NAME = 'getPricingResponseItem';
        ProductValidation objReturn = new ProductValidation();

        System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' productId ' + productId );
        try {
            // The first thing is to check if the product have the SKU filled
            String productSku = String.valueOf([
                SELECT StockKeepingUnit FROM Product2 WHERE Id = :productId
            ]?.StockKeepingUnit);

            // System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' productSku ' + productSku );
            if (String.isBlank(productSku)) return new ProductValidation(false, 'SKU Unavailable');

            String effectiveAccountId = B2BUtils.getUserAccountID();
            // Create apricing request
            // System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' effectiveAccountId ' + effectiveAccountId );
            commercestorepricing.PricingRequest objPriceRequest = new commercestorepricing.PricingRequest();
            objPriceRequest.setEffectiveAccountId(effectiveAccountId);
    
            commercestorepricing.PricingRequestItem objProduct = new commercestorepricing.PricingRequestItem(productId);
            objPriceRequest.addPricingRequestItem(objProduct);
    
            // Call the processPrice() method
            B2BCustomPricingService customPricingService = new B2BCustomPricingService();
            commercestorepricing.PricingResponse objResponse = customPricingService.processPrice(objPriceRequest);
            // System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' objResponse ' + objResponse );
            commercestorepricing.PricingResponseItem responseItem = objResponse.getPricingResponseItems().get(0);
            // System.debug(CLASS_NAME + ' - ' + METHOD_NAME + ' responseItem ' + responseItem );
            objReturn.isValid = responseItem.isSuccess();
            if (! objReturn.isValid) objReturn.validationMessage = 'Price Unavailable';
            
        } catch (Exception objEx) {
            string strMessage = CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage();
            System.debug( strMessage);
            throw new AuraHandledException(strMessage);
        } 
        
        return objReturn;
    }

    public class ProductValidation{
        @AuraEnabled
        public Boolean isValid = false;
        @AuraEnabled
        public String validationMessage = '';

        public ProductValidation(){}
        public ProductValidation(Boolean isValid, String validationMessage){
            this.isValid = isValid;
            this.validationMessage = validationMessage;
        }

    }
}