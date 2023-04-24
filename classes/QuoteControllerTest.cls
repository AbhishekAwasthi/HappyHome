@isTest
public class QuoteControllerTest {
    
    @isTest
    static void testgetQuoteItems() {
   
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

        
       Quote_Item__c[] result =  QuoteController.getQuoteItems(opp.id);
        Assert.areEqual(2, result.size());
       
    }
    
    
    
   
        

 
    
    
}