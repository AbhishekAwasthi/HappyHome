@isTest
public class TestDataFactory {
    
    
    public static Account getAccount() {
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
        Account acc = new Account(
            RecordTypeID=recordTypeId,
            FirstName= 'Test FName',
            LastName= 'Test LName',
            PersonEmail = 'test@yahoo.com');
        return acc;
    }
    
    
    public static Opportunity getOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(Name='Test Opportunity', StageName='Prospecting', CloseDate=Date.today(), Amount=10000,Accountid = accountId);
        return opp;
    }
    
    public static List<product__c> getproducts() {
        List<product__c> products = new List<product__c>{
            new product__c(Availability__c='Available',Description__c='This apartment is in heart of Pankow with lots of sunlight',
                           Location__c='Pankow',Name='1 BHK in Pankow',Price__c=3500.0,Zip_Postal_Code__c='13187',
                           Types_of_houses__c='Apartment',
                           Picture_URL__c='https://images.pexels.com/photos/439391/pexels-photo-439391.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                
                
                new product__c(Availability__c='Available',Description__c='This apartment is in heart of Pankow with lots of sunlight',
                               Location__c='Pankow',Name='1 BHK in Pankow',Price__c=3500.0,Zip_Postal_Code__c='13187',
                               Types_of_houses__c='Apartment',
                               Picture_URL__c='https://images.pexels.com/photos/439391/pexels-photo-439391.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1')
                };

                    return products;
    }
    
    
    public static List<quote_item__c> getQuoteItems(opportunity opp,list<Product__c> products) {
        // Create test Opportunity Line Items
        List<quote_item__c> quoteLineItems = new List<quote_item__c>{
            new quote_item__c(Opportunity__c=opp.Id,Product__c=products[0].id,Price__c=3500.0),
                new quote_item__c(Opportunity__c=opp.Id,Product__c=products[1].id,Price__c=3500.0)
                };
                    
                    return quoteLineItems;
    }
}