public class TimeLogHandler {
    
    public static void validateHours(List<Time_Log__c> newLogs) {
        for (Time_Log__c log : newLogs) {
            if (log.Employee__c != null && log.Log_Date__c != null && log.Hours_Logged__c != null) {

                // Query total hours for that employee on that date (excluding current log)
                List<Time_Log__c> existingLogs = [
                    SELECT Id, Hours_Logged__c
                    FROM Time_Log__c
                    WHERE Employee__c = :log.Employee__c
                    AND Log_Date__c = :log.Log_Date__c
                ];

                Decimal totalHours = log.Hours_Logged__c;

                for (Time_Log__c existing : existingLogs) {
                    if (existing.Id != log.Id && existing.Hours_Logged__c != null) {
                        totalHours += existing.Hours_Logged__c;
                    }
                }

                if (totalHours > 8) {
                    log.addError('You cannot log more than 8 hours for the same date.');
                }
            }
        }
    }
}