@isTest
public with sharing class BillAPICalloutTest {
    @isTest
    public static void getBillCallout() {
        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.


        HttpResponse response = BillAPI.getBillsHttpCallout();
         // Verify response received contains fake values
         String contentType = response.getHeader('Content-Type');
         System.assert(contentType == 'application/json','The content type value is not application/json');
         String result = response.getBody();
        string expectedResult='[{"billId": "B001", "accountName": "Account A", "balance": "1000.00"}, {"billId": "B002", "accountName": "Account B", "balance": "500.00"}]';
        System.assertEquals(result, expectedResult,'Result is wrong.');
    }
        
}