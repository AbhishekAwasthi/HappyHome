@isTest
public class HomeProductControllerTest {
  
    
    @testSetup
    static void createProducts() {
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
    }
    
    @isTest
    static void getProducts_works() {
        HomeProductController.Filters filters = new HomeProductController.Filters();
        filters.searchKey = 'Pankow';
        filters.maxPrice = 4000;
        filters.typeOfHouses = new List<String>{ 'Apartment' };
        filters.searchLocality = 'Pankow';

        PagedResult result = HomeProductController.getProducts(filters, 1);
        Assert.areEqual(2, result.records.size());
        Assert.areEqual('1 BHK in Pankow', ((Product__c) result.records[0]).Name);
    }
   
}