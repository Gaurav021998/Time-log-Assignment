public with sharing class TimeTrackingController {

    // This method fetches all projects for the employee to log hours against
    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjects() {
        return [SELECT Id, Name FROM Project__c];
    }

    // This method saves the time log record
    @AuraEnabled
    public static void saveTimeLog(String projectId, Date logDate, Decimal hoursWorked) {
        // Create new Time_Log__c record
        Time_Log__c timeLog = new Time_Log__c(
            Project__c = projectId,
            Log_Date__c = logDate,
            Hours_Logged__c = hoursWorked,
            Employee__c = UserInfo.getUserId()
        );

        try {
            // Insert the time log record
            insert timeLog; // The trigger will handle the 8-hour validation
        } catch (DmlException e) {
            throw new AuraHandledException('Error while saving time log: ' + e.getMessage());
        }
    }
}