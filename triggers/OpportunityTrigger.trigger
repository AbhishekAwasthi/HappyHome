trigger OpportunityTrigger on Opportunity (after update) {
    
    if(trigger.isAfter && trigger.isUpdate){
        OpportunityTriggerHandler.sendReviewEmail(trigger.new,trigger.oldMap);
    }

}