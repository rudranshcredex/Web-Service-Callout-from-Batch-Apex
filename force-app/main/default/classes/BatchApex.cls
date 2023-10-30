global class BatchApex implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'select Id from Animal__c limit 10';
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<Animal__c> scope) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        system.debug('reponse----->'+response);
    
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> animals = (List<Object>) results.get('animals');
            
            List<Animal__c> animalRecords = new List<Animal__c>();
            for (Object animal : animals) {
                if (animal instanceof Map<String, Object>) {
                    Map<String, Object> animalMap = (Map<String, Object>) animal;
                    
                    Animal__c a = new Animal__c(
                        Name = (String) animalMap.get('animals') 
                    );
                    animalRecords.add(a);
                }
            }
            system.debug('animal records----->'+animalRecords);
            insert animalRecords;
        }
    }
    global void finish(Database.BatchableContext context) {}
}
