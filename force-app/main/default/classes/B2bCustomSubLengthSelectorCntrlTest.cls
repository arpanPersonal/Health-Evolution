@isTest
public class B2bCustomSubLengthSelectorCntrlTest {
	@isTest
    static void setup() {
        // Setup a Custom Label for the test
        String customLabelValue = '2 Year Fellowship,3 Year Fellowship';

        // Insert test products
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = '2 Year Fellowship'));
        products.add(new Product2(Name = '3 Year Fellowship'));
        insert products;
    }
    
     @isTest
    static void testGetDisplayOptionsSuccess() {
        setup();
        String customLabelValue = '2 Year Fellowship';
        // Setup the parameters for the method
        Map<String, Object> mapParams = new Map<String, Object>();

        // Call the method
        mapParams = B2bCustomSubscriptionLengthSelectorCntrl.getDisplayOptions(mapParams);

        // Assertions
        //System.assertEquals(true, mapParams.get('isSuccess'));
        //System.assertNotNull(mapParams.get('respOptionVal'));
        B2bCustomSubscriptionLengthService.ResponseVO respOptionVal = (B2bCustomSubscriptionLengthService.ResponseVO)mapParams.get('respOptionVal');
        System.assertEquals(2, respOptionVal.respMap.size());
    }

   
   
    
    @isTest
    static void testGetDisplayOptions_Exception() {
        // Arrange: Set up test data
        Map<String, Object> testParams = new Map<String, Object>();
        testParams.put('key1', 'value1');
        
        // To simulate an exception, we need to use some workaround as Apex does not support mocking.
        // One way is to use an invalid input that you know will cause an exception.
        
        // For example, let's assume that passing null might cause an exception in the service method.
        Map<String, Object> result;
        
        Test.startTest();
        result = B2bCustomSubscriptionLengthSelectorCntrl.getDisplayOptions(null);
        Test.stopTest();
        
        // Assert: Verify the expected outcome
        System.assertNotEquals(null, result);
        System.assertEquals(false, result.get('isSuccess'));
        System.assertNotEquals(null, result.get('message'));
    }
}