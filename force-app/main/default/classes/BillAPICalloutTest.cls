@isTest
public with sharing class BillAPICalloutTest {
    @isTest
    public static void getBillCallout() {
        // Create test accounts that match the names in the mock response
        Account acc1 = new Account(Name = 'Account A', Active__c = 'Yes');
        Account acc2 = new Account(Name = 'Account B', Active__c = 'Yes');
        insert new List<Account>{ acc1, acc2 };

        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.

        // call the future method
        Test.startTest() ;
        BillAPI.getBills();
        Test.stopTest();
        // Verify that a fake response is sent
        // from the class that implements HttpCalloutMock.
         // Verify response received contains fake values
        //  String contentType = response.getHeader('Content-Type');
        //  System.assert(contentType == 'application/json','The content type value is not application/json');
        //  String result = response.getBody();
        // string expectedResult='[{"billId": "B001", "accountName": "Account A", "balance": "1000.00"}, {"billId": "B002", "accountName": "Account B", "balance": "500.00"}]';
        // System.assertEquals(result, expectedResult,'Result is wrong.');

        // After Test.stopTest(), the future method will have completed
        // Now we can validate the records were created correctly
        List<Bill__c> insertedBills = [SELECT Account__c, Balance__c, Invoice_Number__c FROM Bill__c];
        System.assertEquals(2, insertedBills.size(), 'Two bills should have been inserted.');
        
        // Validate the details of the first inserted bill
        Bill__c firstBill = insertedBills[0];
        System.assertEquals('1000.00', String.valueOf(firstBill.Balance__c), 'Balance should be 1000.00');
        System.assertEquals('B001', firstBill.Invoice_Number__c, 'Invoice number should be B001');
           
        }
    }
