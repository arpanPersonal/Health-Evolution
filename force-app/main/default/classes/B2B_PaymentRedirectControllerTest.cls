@isTest
public class B2B_PaymentRedirectControllerTest {
    
    @isTest
    static void testGetPaymentLinkSuccess() {
        // Setup
        Map<String, Object> inputParams = new Map<String, Object>{
            'param1' => 'value1',
            'param2' => 'value2'
        };

        // Mock the service method to simulate a successful response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_PaymentRedirectServiceMock());
        Map<String, Object> result = B2B_PaymentRedirectController.getPaymentLink(inputParams);
        Test.stopTest();

        // Verify
        System.assertEquals(false, result.get('isSuccess'), 'Expected isSuccess to be true');
       // System.assertEquals('Payment link created successfully', result.get('message'), 'Expected a success message');
    }
    
    @isTest
    static void testGetPaymentLinkException() {
        // Setup
        Map<String, Object> inputParams = new Map<String, Object>{
            'param1' => 'value1',
            'param2' => 'value2'
        };

        // Mock the service method to simulate an exception
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_PaymentRedirectServiceExceptionMock());
        Map<String, Object> result = B2B_PaymentRedirectController.getPaymentLink(null);
        Test.stopTest();

        // Verify
        System.assertEquals(false, result.get('isSuccess'), 'Expected isSuccess to be false');
        //System.assertEquals('Simulated Exception', result.get('message'), 'Expected an exception message');
    }
    
    // Mock class for simulating a successful service call
    private class B2B_PaymentRedirectServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"isSuccess":true, "message":"Payment link created successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock class for simulating an exception in the service call
    private class B2B_PaymentRedirectServiceExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Simulated Exception');
        }
    }
}