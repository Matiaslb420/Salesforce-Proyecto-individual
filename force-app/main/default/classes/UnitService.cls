public class UnitService {
    public class WrongDataException extends Exception {}

    public static Boolean UnitService(Id unitId, String JsonAnswer) {

        Savepoint sp = Database.setSavepoint();

        try{
            Id UserId = UserInfo.getUserId();
            Unit__c Unit = [ 
                SELECT Module__c,  
                (SELECT Id, Tries__c FROM Units_Responses__r WHERE Module_Response__r.User__c =: UserId ORDER BY Tries__c DESC LIMIT 1), 
                (SELECT Id, Name FROM Questions__r)
                FROM Unit__c WHERE Id = :unitId
            ];
            Module_Response__c Mresponse = [SELECT Id FROM Module_response__c WHERE (Module__c =: Unit.Module__c AND User__c =: UserId)];
                
            if(Mresponse == null){
                MResponse = new Module_Response__c(
                    User__c = UserId, 
                    Module__c = Unit.Module__c, 
                    Status__c = 'In progress'
                );
                insert MResponse;
            }
    
            Unit_Response__c UResponse = new Unit_Response__c(
                State__c = 'Draft',
                Unit__c = unitId,
                Module_Response__c = MResponse.Id
            );
            UResponse.Tries__c = !unit.Units_Responses__r.isEmpty() ? unit.Units_Responses__r[0].Tries__c + 1 : 1;
            insert UResponse;
    
            Map<Id, Id> AnswerMap = (Map<Id, Id>)JSON.deserializeStrict(JsonAnswer, Map<Id,Id>.class);
            List<Question_Response__c> QuestionRespList = new List<Question_Response__c>();
    
            for(Question__c question : unit.Questions__r){
                if(AnswerMap.containsKey(question.Id)){
                Question_Response__c questionResp = new Question_Response__c(
                    Question__c = question.Id,
                    Unit_Response__c = UResponse.id,
                    Option__c = AnswerMap.get(question.Id)
                );
                QuestionRespList.add(questionResp);
                }
                else{
                    throw new WrongDataException('La pregunta ' + question.Name + ' no fue respondida y es requerida.');
                }
            }
            insert QuestionRespList;
            UResponse.State__c = 'Answered';
            update UResponse;
        }catch(WrongDataException e){
            Database.rollback(sp);
            throw e;

        }
        return True;
    }
}
