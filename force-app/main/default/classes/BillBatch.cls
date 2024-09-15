public with sharing class BillAPI {
    //@future(callout=true)
    public static void getBills() {
        try{
            // Perform the callout to get bills
            List<Bill__C> insertBills = getBillsCallout();
            
            // Check if the callout is successful, if not return an error
            if (insertBills.size() == 0) {
                System.debug('Callout unsuccessful.');
            }
            // If successful insert all bills into the database
            else {
                upsert insertBills;
            }
            
                    
        }
    
    catch(Exception e){
        System.debug('Exception: ' + e.getMessage());
    }
        }

    
        /* 
        Start by creating an HttpRequest object and set the endpoint and method.
        Endpoint: https://my-json-server.typicode.com/grizzleevelyn/231017_dev_clicked/db
        Method: GET
        Learn more about HTTPRequest: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
        */

        // Set up an Http object and an HTTPResponse object, then use the .getBody() method to get the response body.
        // Method to perform the HTTP callout and retrieve active accounts
       private static List<Bill__c> getBillsCallout(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://my-json-server.typicode.com/walters954/clicked-intro-development-server/bills');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        String jsonResponse = response.getBody();
        try {
            
         // Deserialize the JSON response into a list of BillWrapper objects.
          // Create a list to hold the bills we will insert into Salesforce.
          
        if(response.getStatusCode() == 200) {
       
            List<String> uniqueAccNames = new List<String>();
            List<BillWrapper> bwList = (List<BillWrapper>) JSON.deserialize(jsonResponse, List<BillWrapper>.class);
            System.debug('BillWrapper List: ' + bwList);
        
            // Collect account names and bills from the response
            // Create a map to store accountName as the key and a list of billIds as the value
Map<String, List<String>> accountBillMap = new Map<String, List<String>>();

// Loop through the list of BillWrapper objects
for (BillWrapper bw : bwList) {
    // Check if the account already exists in the map
    if (!accountBillMap.containsKey(bw.accountName)) {
        // If not, create a new list for the bills of this account
        accountBillMap.put(bw.accountName, new List<String>());
    }
    
    // Add the billId to the account's bill list
    accountBillMap.get(bw.accountName).add(bw.billId);
}


            // Debug the account names collected
            System.debug('Account Names from BillWrapper: ' + UniqueAccNames);
            // Now accountBillMap contains accountName as the key and corresponding billIds as the value
System.debug('Account-Bill Map: ' + accountBillMap);

       

        // Query for accounts that match the account name from the bill wrapper list.
         //for active accounts (Active__c = 'Yes') and there related bills.
        
        List<Account> accList = [SELECT Id, Name,(SELECT Id from Bills__r) FROM Account WHERE Name IN :accountBillMap.keySet() AND Active__c = 'Yes' WITH SECURITY_ENFORCED];
        if (accList != null && !accList.isEmpty()) {
            // create a map of account and its related bills
            
            
            // for (string accname : accountBillMap.keySet()) {{
            //     System.debug('Account Name: ' + accname);
            
            //     System.debug(' - Bill ID: ' + accname.values());
            //     }
            
            
            List<Bill__c> bills = billsToInsertMethod(accList,accountBillMap);
            return bills;
             
    }
            
        
        else {
            System.debug('There are no acctive accounts.');
        }
    }
        
        else {
        
            System.debug('Response Status code is not 200. Error: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
    }
        
        catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        return null;
    }
    
   
    
        // Create a map to hold active account names and their IDs.
        // Iterate over the list of active accounts and add their name and ID to the map.
        private Static List<Bill__c>  billsToInsertMethod(List<Account> accList, Map<String, List<String>> accountBillMap){
        Map<String, String> accMap = new Map<String, String>();
        for (Account acc : accList) {
            accMap.put(acc.Name, acc.Id);
        }

        // Create a list to hold the bills we will insert into Salesforce.
        List<Bill__c> billsToInsert = new List<Bill__c>();

        /*
        Iterate over the list of BillWrapper objects and create a new Bill__c record for each.
        Match the new bill fields with the properties of the BillWrapper class.
        For example, for Bill__c.Balance__c, use Decimal.valueOf(bw.balance.replace('$', '')) to convert the balance to a decimal.
        */
        // Iterate through the BillWrapper list and create Bill__c objects for each active account.
        for (BillWrapper bill : bwList) {
            // Check if the account name exists in the accMap (i.e., it's an active account).
            if (accMap.containsKey(bill.accountName)) {
                // Create a new Bill__c object.
                Bill__c newBill = new Bill__c();
                
                // Set the fields of the Bill__c object.
                newBill.Account__c = accMap.get(bill.accountName); // Set the Account lookup field.
                newBill.Balance__c = Decimal.valueOf(bill.balance.replace('$','')); // Convert the balance string to a decimal.
                newBill.Invoice_Number__c = bill.billId; // Assuming BillId__c is a custom field on Bill__c.

                // Add the Bill__c object to the billsToInsert list.
                billsToInsert.add(newBill);
            }
        }
            System.debug('Number of Bills to Insert: ' + billsToInsert.size());
        return billsToInsert;
    }
       
    /*  
    This is a wrapper class. A wrapper class allows us to create an instance of a class with the properties we specify.
    In this case, we are creating a class that will hold the properties for BillId, AccountName, and Balance.
    These properties will be populated from the JSON structure stored in our external data source.
    Once we get the body of our HTTP callout, we will use the following line of code to transform the response body into a list of instances of our wrapper class, BillWrapper:
    List<BillWrapper> bwList = (List<BillWrapper>)JSON.deserialize(responseBody, List<BillWrapper>.class);
    Once we have a list of BillWrapper objects (bwList), we will iterate over the bwList, create a new Bill__c record, and assign the values of the BillWrapper properties to the fields on the Bill__c record.
    */
    public class BillWrapper {
        public String billId;
        public String accountName;
        public String balance;
    }

        }