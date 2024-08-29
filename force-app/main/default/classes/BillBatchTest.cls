@isTest
public with sharing class BillBatchTest {
     // Mocking the callout response
     public class MockBillCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"billId": "001", "accountName": "Test Account 0", "balance": "$100.00"},' +
                        '{"billId": "002", "accountName": "Test Account 1", "balance": "$200.00"}]');
            res.setStatusCode(200);
            return res;
        }
    }
   @isTest
    public static void billBatchTestAccounts() {
        List<Account> acc = new List<Account>();
        for(Integer i = 0; i < 5; i++){
            Account ac = new Account();
            ac.Name = 'Test Account ' + i;
            ac.Active__c = 'Yes';
            ac.Bill_By_Email__c = true;
            ac.Email__c = 'test' + i + '@gmail.com';
            acc.add(ac);
        }
        insert acc;
        
         // Set up the mock callout
         Test.setMock(HttpCalloutMock.class, new MockBillCallout());

         // Start test, execute the batch, and stop test
        Test.startTest();
        BillBatch b = new BillBatch();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();

        // Get the list of bills inserted along with accounts associated
        List<Bill__c> insertedBills = [SELECT Account__c, Amount__c, Email__c FROM Bill__c
                                        WHERE Account__c IN :acc];
         // Assert that the bills were inserted correctly
         System.assertEquals(2, insertedBills.size(), 'Two bills should have been inserted.');

         // Assert emails sent
        //  System.Assert.areEqual(2, Limits.getEmailInvocations(), 'Two emails should have been sent.');
         System.assertEquals(2, sendMap.keySet().size(), 'Two emails should have been sent.');

         
}
}