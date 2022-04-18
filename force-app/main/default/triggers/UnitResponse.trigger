trigger UnitResponse on Unit_Response__c (before update) {
    UnitResponseTrigger.onBeforeUpdate(Trigger.new);
}