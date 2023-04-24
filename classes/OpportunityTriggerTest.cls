@isTest
private class OpportunityTriggerTest {
    @isTest
    static void testsendReviewEmail() {
        
         Account Accnt = TestDataFactory.getAccount();
        
        insert Accnt;
        
        // Create test Opportunity record
        Opportunity opp = TestDataFactory.getOpportunity(Accnt.id);
        insert opp;
        
        
        
        // Create test Opportunity Line Items
        List<product__c> products = TestDataFactory.getproducts();
                    insert products;
        
        // Create test Opportunity Line Items
        List<quote_item__c> oppLineItems = TestDataFactory.getQuoteItems(opp,products);
                    insert oppLineItems;

      
        opp.StageName='Negotiation/Review';
        update opp;


    }
}