@isTest
public class BillTriggerHandlerTest {

    @testSetup
    static void setup() {
        // Create accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Create open opportunities for some accounts
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities.add(new Opportunity(
            AccountId = accounts[0].Id, 
            Name = 'Existing Opportunity', 
            StageName = 'Prospecting',  // This stage is considered "open"
            CloseDate = System.today().addMonths(1)
        ));
        existingOpportunities.add(new Opportunity(
            AccountId = accounts[1].Id, 
            Name = 'Existing Opportunity', 
            StageName = 'Negotiation',  // This stage is considered "open"
            CloseDate = System.today().addMonths(1)
        ));
        insert existingOpportunities;
    }

    // method to test Opportunity Creation When No Open Opportunities
    @isTest
    static void testOpportunityCreationWhenNoOpenOpportunities() {
        // Fetch accounts from setup
        List<Account> accounts = [SELECT Id, Name FROM Account];

        // Create bills for accounts without open opportunities
        List<Bill__c> bills = new List<Bill__c>();
        bills.add(new Bill__c(Account__c = accounts[2].Id, Balance__c = 1000));
        bills.add(new Bill__c(Account__c = accounts[3].Id, Balance__c = 2000));
        bills.add(new Bill__c(Account__c = accounts[4].Id, Balance__c = 3000));
        insert bills;

        // Query and assert that opportunities are created for the right accounts
        List<Opportunity> newOpportunities = [
    SELECT Id, AccountId, Name, Amount
    FROM Opportunity
    WHERE AccountId IN (:bills[0].Account__c, :bills[1].Account__c,:bills[2].Account__c)
];

        System.assertEquals(3, newOpportunities.size(), 'Exactly 3 opportunities should be created.');
    }
	// method to test no oppourtunities are created for accounts with open oppurtunites
    @isTest
    static void testNoOpportunityCreationForAccountsWithOpenOpportunities() {
        // Fetch accounts from setup
        List<Account> accounts = [SELECT Id, Name FROM Account];

        // Create bills for accounts with existing open opportunities
        List<Bill__c> bills = new List<Bill__c>();
        bills.add(new Bill__c(Account__c = accounts[0].Id, Balance__c = 4000)); // Already has an open opportunity
        bills.add(new Bill__c(Account__c = accounts[1].Id, Balance__c = 5000)); // Already has an open opportunity
        insert bills;

        // Query and assert that no new opportunities are created for these accounts
        List<Opportunity> newOpportunities = [SELECT Id FROM Opportunity WHERE AccountId IN (:bills[0].Account__c, :bills[1].Account__c) AND Name LIKE 'Test Account%'];
        System.assertEquals(0, newOpportunities.size(), 'No opportunities should be created for accounts with existing open opportunities.');
    }

  /*  @isTest
    static void testBulkInsert() {
        // Fetch accounts from setup
        List<Account> accounts = [SELECT Id, Name FROM Account];

        // Create a bulk list of bills for all accounts
        List<Bill__c> bills = new List<Bill__c>();
        for (Account acc : accounts) {
            bills.add(new Bill__c(Account__c = acc.Id, Balance__c = 1000));
        }
        insert bills;

        // Query and assert the correct number of opportunities created (only for accounts without existing open opportunities)
        List<Opportunity> newOpportunities = [SELECT Id, AccountId FROM Opportunity WHERE Name LIKE 'Test Account%'];
        System.assertEquals(3, newOpportunities.size(), 'Exactly 3 new opportunities should be created.');
    }
*/
    @isTest
    static void testBillWithoutAccount() {
        // Create a bill with no associated account
        Bill__c billWithoutAccount = new Bill__c(Balance__c = 5000);

        Test.startTest();
        try {
            insert billWithoutAccount;
            System.assert(false, 'An exception should have been thrown due to missing Account__c.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Account__c is required.'), 'Correct error message should be thrown.');
        }
        Test.stopTest();
    }
   
    /*
    @isTest
    static void testHandlerMethods() {
         List<Bill__c> bills = new List<Bill__c>();
        
        // Create a few Bill records for testing
        bills.add(new Bill__c(Account__c = [SELECT Id FROM Account LIMIT 1].Id, Balance__c = 1000));
        
         Test.startTest();
         // Call beforeUpdate
        BillTriggerHandler.beforeUpdate(new Map<Id, sObject>(), new Map<Id, sObject>());

        // Call afterUpdate
        BillTriggerHandler.afterUpdate(new Map<Id, sObject>(), new Map<Id, sObject>());

        // Call beforeDelete
        BillTriggerHandler.beforeDelete((List<sObject>)bills, new Map<Id, sObject>());

        // Call afterDelete
        BillTriggerHandler.afterDelete(new Map<Id, sObject>());

        // Call afterUnDelete
        BillTriggerHandler.afterUnDelete((List<sObject>)bills, new Map<Id, sObject>());
        
        Test.stopTest();
        
      
    }
*/
}