@isTest
public with sharing class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://my-json-server.typicode.com/walters954/clicked-intro-development-server/bills', req.getEndpoint(),'Incorrect endpoint' );
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        System.assertEquals('GET', req.getMethod(),'Not get method' );
        res.setHeader('Content-Type', 'application/json');
               
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"billId": "B001", "accountName": "Account A", "balance": "1000.00"}, {"billId": "B002", "accountName": "Account B", "balance": "500.00"}]');
        response.setStatusCode(200);
        return response;
    }
}