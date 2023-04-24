public with sharing class HomeProductController {
    static Integer PAGE_SIZE = 9;

    public class Filters {
        @AuraEnabled
        public String searchKey { get; set; }
        @AuraEnabled
        public String searchLocality { get; set; }
        @AuraEnabled
        public Decimal maxPrice { get; set; }
        @AuraEnabled
        public String[] typeOfHouses { get; set; }

    }
	//get products based on filters 
    @AuraEnabled(Cacheable=true scope='global')
    public static PagedResult getProducts(Filters filters, Integer pageNumber) {
        String key,locality, whereClause = '';
        string availability = 'Available';
        Decimal maxPrice;
        String[] typeOfHouses,criteria = new List<String>{};
        if (filters != null) {
            maxPrice = filters.maxPrice;
            criteria.add('Types_of_houses__c != null');
            criteria.add('Availability__c = :availability');
            if (!String.isEmpty(filters.searchKey)) {
                key = '%' + filters.searchKey + '%';
                criteria.add('Name LIKE :key');
            }
            if (!String.isEmpty(filters.searchLocality)) {
                locality = '%' + filters.searchLocality + '%';
                criteria.add('(Location__c LIKE :locality or Zip_Postal_Code__c LIKE :locality) ');
            }
            if (filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('Price__c <= :maxPrice');
            }
            if (filters.typeOfHouses != null) {
                typeOfHouses = filters.typeOfHouses;
                criteria.add('Types_of_houses__c IN :typeOfHouses');
            }
            if (criteria.size() > 0) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND ');
            }
        }
        Integer pageSize = HomeProductController.PAGE_SIZE;
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.totalItemCount = Database.countQuery(
            'SELECT count() FROM Product__c ' + whereClause
        );
        result.records = Database.query(
            'SELECT Id, Name, Price__c, Description__c, Picture_URL__c,Types_of_houses__c,Location__c,Zip_Postal_Code__c FROM Product__c ' +
                whereClause +
                ' WITH SECURITY_ENFORCED' +
                ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );
        return result;
    }


}