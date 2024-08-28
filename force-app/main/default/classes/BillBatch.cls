public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Id> receivesBillByEmail = new List<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //this is a method that will query for all accounts that are active and have a value
        //for Bill_By_Email__c (Account.Active__c = \'Yes\' AND Bill_By_Email != null)
        //using the Database.getQueryLocator(String) method. Return the result of this method.
        //Hint: be sure to escape the single quotes surrounding \'Yes\' in your dynamic query!
        //query for the following fields:
        //Id, Bill_By_Email__c
       // return null;
       return Database.getQueryLocator(
            'SELECT Id, Bill_By_Email__c FROM Account WHERE Active__c = \'Yes\''+
            'AND Bill_By_Email__c !=NULL'
         
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        //this is a method that will process the queried for records by preparing
        //a list of account Ids (this.receivesBillByEmail) to carry over to the finish method.
        //we will do this by iterating over scope and checking whether Bill_By_Email__c == TRUE.
        //This method will also call our BillAPI.getBills() method.
        
        //for all accounts in scope, add the account id to the receivesBillByEmail list
        for(Account account : scope){
            if(account.Bill_By_Email__c == TRUE){ 
                //if the Bill_By_Email__c is TRUE, add the account to the receivesBillByEmail list
                receivesBillByEmail.add(account.Id);
            }
        }
            	//this is a method that will use the BillAPI.getBills() method to execute the callout
        if(!receivesBillByEmail.isEmpty()){
            //getBills();
            BillAPI.getBills();
        }
        System.debug('Number of accounts to receive bill emails: ' + receivesBillByEmail.size());
        //this is a method that we have defined in the BillAPI class. The method is called getBills().
    }

    public void finish(Database.BatchableContext bc) {
        //this is the final method of the class, that will be called after all processing in the
        //start and execute methods is complete. We will use this method to send an email to each
        //customer in the receivesBillByEmail list. First, we must query for the recently created bills for
        //each account with the following nested query:
        //[SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :this.receivesBillByEmail]
        // Query for recently created bills for each account in receivesBillByEmail
        List<Account> accountsWithBills = [
            SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) 
            FROM Account 
            WHERE Id IN :this.receivesBillByEmail
        ];
         

        //We will then iterate over the results of this query and associate the Id of the most recent bill (value) with the
        //corresponding Id of the account Id (key) in a Map<Id, Id> that we will call billMap, using the .put(Id, Id)
        //method of the Map class:
        //https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm
        //we will also create a Map<Id, String> called emailMap, where we'll hold the Account Id (key) and account email (value).
        
         // Create a map to hold the most recent bill Id associated with each account
        Map<Id, Id> billMap = new Map<Id, Id>();
        // Create a map to hold the account Id and email
        Map<Id, String> emailMap = new Map<Id, String>();
        
        //Iterate over the accountsWithBills list, and use the .get(0) method to get the first value in the Bills__r list
        //for each account
        for(Account account : accountsWithBills){
            //Check if the bills__r list has values
            if(!account.Bills__r.isEmpty()){
                //if there is a value in the bills__r list, add the most recent bill Id to the billMap, using the
                //.put(Id, Id) method
                billMap.put(account.Id, account.Bills__r.get(0).Id);
                //add the account Id to the emailMap, using the .put(Id, String) method
                emailMap.put(account.Id, account.Bill_By_Email__c);
            }
        }

        //Next, we are going to prepare to call our BillEmailer.sendEmails(Map<String, Blob> emailsWithBills)
        //method. The String in the map, which we'll call sendMap,will be the Account.Email__c field result, and the Blob
        //will be the PDF attachment we are sending. We will achieve this by iterating over the keyset for
        //billMap, putting the email from the account in the key of the key-value pair, and use the following
        //to generate a PDF for each bill Id in the value of the key-value pair:
        //PageReference pageRef = new PageReference('/apex/BillVFP?id=' + [BILLID]);
        //Blob pdfBlob = pageRef.getContentAsPDF();
        //hint: you'll need to use the .get() method of the Map class a couple of times here.
        
        // Create a map to hold the email address and the blob of the email
        Map<String, Blob> sendMap = new Map<String, Blob>();
        
        // Iterate over the values for the billMap, which contains the billIds for each account
        for(Id accountId : billMap.keySet()){
            
            //use the .get(Id accountId) method to return the value for a given key

            Id billId = billMap.get(AccountId);
            
            // Use the .get(Id accountId) method to return the value for a given key
            String emailAddress = emailMap.get(AccountId);
            
             // Generate the PDF for the bill
            PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
            Blob pdfBlob = pageRef.getContentAsPDF();  
            
            // Add the email address to the emailMapWithBlob map, using the .put(String, Blob) method
            sendMap.put(emailAddress, pdfBlob);
        }

        //finally, we will call our BillEmailer.sendEmails(sendMap) method. Remember, this method is VOID,
        //so there will be no return value;
        
        // Send the emails
        BillEmailer.sendEmails(sendMap);
    }
}