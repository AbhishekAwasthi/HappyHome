public class OpportunityTriggerHandler {
    
    public static void sendReviewEmail(list<Opportunity> newOpportunityList,map<Id,Opportunity> oldOpportunityMap){
        list<id> OpporutnityId = new List<id>();
        list<id> accountId = new List<id>();
        for(Opportunity item : newOpportunityList){
            if(item.StageName == 'Negotiation/Review'  && item.StageName != oldOpportunityMap.get(item.id).StageName){
                OpporutnityId.add(item.id);
                accountId.add(item.AccountId);
            }
        }
        
        // Get the Opportunity record and its quote  Items
        list<Opportunity> opptunityList = [SELECT Id, Name, StageName,AccountId,Account.PersonEmail,Account.PersonContactId ,Account.Name,owner.email,Total_Quote_Price__c,Number_of_Items__c,OwnerId, (SELECT Id , Product__r.Name,Product__r.Description__c,Product__r.Picture_URL__c,Product__r.Zip_Postal_Code__c,
                                                                                                                                                             Product__c, Price__c,Product__r.Location__c FROM QuoteItems__r) FROM Opportunity WHERE Id in :OpporutnityId];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for(Opportunity item : opptunityList){
            {
                if(item.Account.PersonEmail != null){
                    Id templateId = null;
                    String[] toAddresses = new String[] {item.Account.PersonEmail};
                        //  String[] ccAddresses = new String[] {'insurance@sennder.com'};   
                        //String[] ccAddresses = new String[]();
                        
                        // Create the email message
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Happy Homes Quote for: ' + Item.Account.Name);
                    email.setToAddresses(toAddresses);    
                    email.setReplyTo(Item.owner.email);
                    email.setTargetObjectId(item.Account.PersonContactId);
                    
                    
                    // Build the email body
                    String emailBody = '<html><body>'
                        + '<p>Hi Please find below the Quote for your Inquiry, Please let us know if you want to proceed with the booking so we can create a contract.</p>' + '<br/>'
                        + '<p>Below are the quote Details : </p><br/>'
                        + '<table style="border-collapse: collapse; border: 1px solid black;"><thead><tr>'
                        +'<th>Listing Name</th>'
                        + '<th style="border: 1px solid black; padding: 5px;">Price</th>'
                        + '<th style="border: 1px solid black; padding: 5px;">Zip /Postal Code</th>'
                        + '<th style="border: 1px solid black; padding: 5px;">Location</th>'
                        + '<th style="border: 1px solid black; padding: 5px;">Image</th>'
                        + '<th style="border: 1px solid black; padding: 5px;">Description</th>'
                        + '</tr style="border: 1px solid black; padding: 5px;"></thead><tbody>';
                    
                    for (Quote_Item__c qli : item.QuoteItems__r) {
                        emailBody  += '<tr><td style="border: 1px solid black; padding: 5px;">' + qli.Product__r.Name + '</td>'
                            + '<td style="border: 1px solid black; padding: 5px;">' + qli.Price__c + '</td>'
                            + '<td style="border: 1px solid black; padding: 5px;">' + qli.Product__r.Zip_Postal_Code__c + '</td>'
                            + '<td style="border: 1px solid black; padding: 5px;">' + qli.Product__r.Location__c + '</td>'
                            + '<td style="border: 1px solid black; padding: 5px;">' + '<img src="'+qli.Product__r.Picture_URL__c+'" style="width: 120px; height: 120px;"/>' + '</td>'
                            + '<td style="border: 1px solid black; padding: 5px;">' + qli.Product__r.Description__c + '</td></tr>';
                    }
                    
                    emailBody += '</tbody></table>'
                        + '<p>No of houses :'+ item.Number_of_Items__c +'</p><br/>'
                        + '<p>Total quote Amount :'+ item.Total_Quote_Price__c +'</p><br/><br/><br/>'
                        + '<p>Regards</p><br/>'
                        + '<p>Happy Home Team</p><br/>'
                        + '</body></html>';
                    
                    
                    // Set the email body and send the email
                    email.setHtmlBody(emailBody);
                    
                    
                    
                    email.setSaveAsActivity(true); //or true if you want to save as an activity
                    emailsToSend.add(email);
                }
                
            }
            
        }
        Try {
            Messaging.sendEmail(emailsToSend);
        }
        catch(exception ex){
            
            list<Task> taskInserList = new list<Task>();
            Task obj;
            for(Opportunity item : opptunityList){
                obj = new Task(Subject = 'Subject: Failed to Send Qoute Email ', OwnerId = item.OwnerId, WhatId = item.Id, Type = 'Email', ActivityDate = Date.today(), Description = ex.getMessage() + ex.getStackTraceString()
                );
                taskInserList.add(obj);
            }
            
            Database.insert(taskInserList);
            
            
            
        }
    }
    
}