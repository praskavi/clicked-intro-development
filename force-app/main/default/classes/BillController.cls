public with sharing class BillController {
    @AuraEnabled(Cacheable=true)
    public static List<Bill__c> getBills(Id accountId) {
        if(accountId == null){
            return [SELECT Id,Invoice_Number__c,Balance__c,Account__c FROM Bill__c];
        
        
    }
    else {
        return [SELECT Id,Invoice_Number__c,Balance__c,Account__c FROM Bill__c WHERE Account__c = :accountId];
    }

    }
}