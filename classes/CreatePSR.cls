public without sharing class CreatePSR {
    @InvocableMethod (label='PSR on Case' description='Create and Delete PSR on Case.' )
     public static void CreatePSROnCase(List<CreatePsrForCase> listOfCreatePsrForCase) {
        List<Case>  listOfCaseForPsr = listOfCreatePsrForCase[0].caseList;
        Set<Id> caseIdSet = new Set<Id>();
        List<PendingServiceRouting> psrToCreate = new  List<PendingServiceRouting>();
        Integer currentIndex = 0;
        Integer routPriority = 0;
        for (case  cas : listOfCaseForPsr) {
            caseIdSet.add(cas.Id);
        }

        List<PendingServiceRouting> psrToDelete = [SELECT id FROM PendingServiceRouting WHERE WorkItemId In :caseIdSet];
        if (!caseIdSet.isEmpty()) {
            delete psrToDelete;
        }
        
        for (case cas : listOfCaseForPsr) {
            if (String.isNotBlank(cas.Urgency__c)) {
                if (cas.Urgency__c == 'Violation') {
                    routPriority = 1;
                } else if (cas.Urgency__c == 'Warning') {
                    routPriority = 2;
                } else {
                    routPriority = 3;
                }
            }else {
                routPriority = 4;
            }

            currentIndex += 1;
            PendingServiceRouting psr = new PendingServiceRouting();
                    psr.CapacityWeight = 1;
                    psr.IsPreferredUserRequired = true;
                    psr.IsReadyForRouting = true;
                    psr.PreferredUserId  = cas.OwnerId;
                    psr.PushTimeout = 0;
                    psr.RoutingModel = 'MostAvailable';
                    psr.RoutingPriority = routPriority;
                    psr.SecondaryRoutingPriority = currentIndex;
                    psr.RoutingType = 'SkillsBased';
                    psr.ServiceChannelId = System.Label.Service_Channel_Id;
                    psr.WorkItemId = cas.Id;
                    psrToCreate.add(psr);
        }

        if (!psrToCreate.isEmpty()) {
            insert psrToCreate;
        }
    }

    public class CreatePsrForCase {
        @InvocableVariable 
        public List<Case> caseList;

    }

}