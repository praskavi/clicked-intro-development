public class BillTriggerHelper {

    public static void handleBeforeInsert(List<Bill__c> newBills) {
        for (Bill__c bill : newBills) {
            // Ensure the Account__c field is not blank
            if (bill.Account__c == null) {
                bill.addError('Account__c is required.');
            }

            // Populate Invoice Number if not already set
            if (bill.Invoice_Number__c == null) {
                bill.Invoice_Number__c = UUID.randomUUID().toString().substring(0, 8);
            }
        }
    }

    public static void handleAfterInsert(List<Bill__c> newBills) {
        System.debug('Handling after insert for bills: ' + newBills);

        // Collect Account Ids to check for existing open opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Bill__c bill : newBills) {
            if (bill.Account__c != null) {
                accountIds.add(bill.Account__c);
            }
        }

        System.debug('Account IDs: ' + accountIds);

        // Query for existing open opportunities
        Map<Id, Opportunity> existingOpenOpportunitiesMap = new Map<Id, Opportunity>(
            [SELECT Id, AccountId 
             FROM Opportunity 
             WHERE AccountId IN :accountIds AND IsClosed = false]
        );

        System.debug('Existing Open Opportunities Map: ' + existingOpenOpportunitiesMap);

        // Set of account Ids that have open opportunities
        Set<Id> accountsWithExistingOpportunities = new Set<Id>();
        for (Opportunity opp : existingOpenOpportunitiesMap.values()) {
        accountsWithExistingOpportunities.add(opp.AccountId); 
    }

        System.debug('Accounts with existing open opportunities: ' + accountsWithExistingOpportunities);

        // List to hold new opportunities to insert
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();

        for (Bill__c bill : newBills) {
            if (bill.Account__c != null && !accountsWithExistingOpportunities.contains(bill.Account__c)) {
                // Create an opportunity if no open opportunities exist for the account
                Opportunity opp = new Opportunity();
                opp.AccountId = bill.Account__c;
                opp.Name = bill.Account__r.Name + ' - Opportunity ' + bill.Invoice_Number__c;
                opp.Amount = bill.Balance__c;
                opp.StageName = 'Prospecting';  // Or another appropriate open stage
                opp.CloseDate = System.today().addMonths(1);

                opportunitiesToCreate.add(opp);
            }
        }

        System.debug('Opportunities to be created: ' + opportunitiesToCreate.size());

        if (!opportunitiesToCreate.isEmpty()) {
            insert opportunitiesToCreate;
        }
    }

}