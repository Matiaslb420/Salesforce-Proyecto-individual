public with sharing class UnitResponseTrigger {
    public static void onBeforeUpdate(List<Unit_Response__c> unitRespList){
        List<Unit_Response__c> answeredUnitRespList = new List<Unit_Response__c>();
        for(Unit_Response__c unitResp : unitRespList){
            if(unitResp.State__c == 'Answered'){
                answeredUnitRespList.add(unitResp);
            }
        }
    }
    private static void validateAnswers(List<Unit_Response__c> unitRespList){
        
    }
}
