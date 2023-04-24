public with sharing class QuoteController {
    @AuraEnabled(Cacheable=true)
    public static Quote_Item__c[] getQuoteItems(Id opportunityId) {
        return [
            SELECT
                Id,
                Quantity__c,
                Price__c,
                Product__r.Name,
                Product__r.Price__c,
                Product__r.Picture_URL__c,
                Opportunity__r.Total_Quote_Price__c,
                Opportunity__r.Number_of_Items__c
            FROM Quote_Item__c
            WHERE Opportunity__c = :opportunityId
            WITH SECURITY_ENFORCED
        ];
    }
}