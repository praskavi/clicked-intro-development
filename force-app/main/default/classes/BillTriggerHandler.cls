public class BillTriggerHandler implements TriggerInterface {

    public void beforeInsert(List<sObject> newRecordsList) {
        BillTriggerHelper.handleBeforeInsert((List<Bill__c>) newRecordsList);
    }

    public void afterInsert(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        BillTriggerHelper.handleAfterInsert((List<Bill__c>) newRecordsList);
    }

   /*
     public static void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        
    }
     public static void afterUpdate(Map<Id, sObject> newRecordsMap,  Map<Id, sObject> oldRecordsMap){
     }
    
	public static void beforeDelete(List<sObject> oldRecordsList , Map<Id, sObject> oldRecordsMap){
        
       }
    public static void afterDelete(Map<Id, sObject> oldRecordsMap){
    }
     public static void afterUnDelete(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap) {
     }
*/
}