@isTest
public with sharing class BillBatchTest {

    // // Mocking the email sending
    // public class MockBillEmailer implements BillEmailer {
    //     public static Integer emailCount = 0;  // Track the number of emails sent
    //     public static Map<String, Blob> capturedEmails = new Map<String, Blob>();  // Capture email data

    //     public static void sendEmails(Map<String, Blob> emailsWithBills) {
    //         // Capture the email count and data
    //         emailCount = emailsWithBills.size();
    //         capturedEmails = emailsWithBills;
    //     }
    // }
     // Mocking the callout response
     public class MockBillCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"billId": "001", "accountName": "Test Account 0A", "balance": "$100.00"},' +
                        '{"billId": "002", "accountName": "Test Account 1A", "balance": "$200.00"}]');
            res.setStatusCode(200);
            return res;
        }
    }
     // Mock PDF generation
    //  public class MockPDFUtil {
    //     public static Blob generatePDF(String billId) {
    //         return Blob.valueOf('mock-pdf-content'); // Return mock PDF content
    //     }
    // }
    // public class MockPDFGenerator implements IPDFGenerator {
    //     public Blob generatePDF(String billId) {
    //         return Blob.valueOf('mock-pdf-content'); // Return mock PDF content
    //     }
    // }

   @isTest
    public static void billBatchTestAccounts() {
        List<Account> acc = new List<Account>();
        for(Integer i = 0; i < 5; i++){
            Account ac = new Account();
            ac.Name = 'Test Account ' + i + 'A';
            ac.Active__c = 'Yes';
            ac.Bill_By_Email__c = true;
            ac.Email__c = 'test' + i + '@gmail.com';
            acc.add(ac);
        }
        insert acc;
        
         // Create test bill records
         List<Bill__c> bills = new List<Bill__c>();
         for (Integer i = 0; i < 2; i++) {
             Bill__c bill = new Bill__c();
             bill.Account__c = acc[i].Id;
             bill.Balance__c = 100.00 + i * 100;
             bill.Invoice_Number__c = 'INV' + i;
             bills.add(bill);
         }
         insert bills;
         // Set up the mock callout
         Test.setMock(HttpCalloutMock.class, new MockBillCallout());
        //      // Set up the mock emailer
        //  Test.setMock(BillEmailer.class, new BillEmailerMock());

          // Create an instance of the batch with a mock PDF generator
        // IPDFGenerator mockPDFGenerator = new MockPDFGenerator();
        // BillBatch b = new BillBatch(mockPDFGenerator);

         // Start test, execute the batch, and stop test
        Test.startTest();
        // PDFUtil.generatePDF = MockPDFUtil.generatePDF; // Mock PDF generation
        // IPDFGenerator mockPDFGenerator = new MockPDFGenerator();

        BillBatch b = new BillBatch();
        Id batchId = Database.executeBatch(b);
        Test.stopTest();

        // Get the list of bills inserted along with accounts associated
        // List<Bill__c> insertedBills = [SELECT Account__c, Balance__c, Email__c FROM Bill__c
        //                                 WHERE Account__c IN :acc];
         // Assert that the bills were inserted correctly
         System.assertEquals(2, [SELECT COUNT() FROM Bill__c WHERE Account__c IN :acc], 'Two bills should have been inserted.');

         // Assert emails sent
         System.Assert.areEqual(2, Limits.getEmailInvocations(), 'Two emails should have been sent.');
        //  System.assertEquals(2, sendMap.keySet().size(), 'Two emails should have been sent.');
        // Check the email count captured by the mock class
        // System.assertEquals(2, ((BillEmailerMock) Test.getMock(BillEmailer.class)).emailCount, 'Two emails should have been sent.');
        // System.assertEquals(2, MockBillEmailer.emailCount, 'Two emails should have been sent.');

        // Check captured email data
        // System.debug('Captured Emails: ' + MockBillEmailer.capturedEmails);
        
        // // Optionally, check email content
        // for (String emailAddress : MockBillEmailer.capturedEmails.keySet()) {
        //     Blob emailBlob = MockBillEmailer.capturedEmails.get(emailAddress);
        //     // Add your checks for the PDF content here if needed
        //     System.debug('Email sent to: ' + emailAddress);
        //     System.debug('PDF Blob size: ' + emailBlob.toString().length() + ' bytes');

         
}
}

