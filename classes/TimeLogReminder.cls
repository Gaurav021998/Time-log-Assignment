public with sharing class TimeLogReminder {
    public static void monitorAndNotify() {
        Date today = Date.today();
        Date weekStart = today.toStartOfWeek(); // Monday
        Date weekEnd = weekStart.addDays(6);    // Sunday

        // Fetch all Time Logger users
        List<User> timeLoggerUsers = [SELECT Id, Name, Email FROM User WHERE UserRole.Name = 'Time Logger' AND Profile.Name = 'Time Logger' AND IsActive = true];

        Set<Id> userIds = new Set<Id>();
        for (User u : timeLoggerUsers) {
            userIds.add(u.Id);
        }

        // Fetch all time logs for this week
        Map<Id, Set<Date>> userToLoggedDates = new Map<Id, Set<Date>>();
        for (Time_Log__c log : [
            SELECT Employee__c, Log_Date__c
            FROM Time_Log__c
            WHERE Employee__c IN :userIds AND Log_Date__c >= :weekStart AND Log_Date__c <= :weekEnd
        ]) {
            if (!userToLoggedDates.containsKey(log.Employee__c)) {
                userToLoggedDates.put(log.Employee__c, new Set<Date>());
            }
            userToLoggedDates.get(log.Employee__c).add(log.Log_Date__c);
        }

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (User u : timeLoggerUsers) {
            Set<Date> missingDates = new Set<Date>();

            for (Integer i = 0; i <= 4; i++) { // Monday to Friday
                Date targetDate = weekStart.addDays(i);
                if (targetDate >= Date.today()) continue; // Skip today or future

                if (!userToLoggedDates.containsKey(u.Id) || !userToLoggedDates.get(u.Id).contains(targetDate)) {
                    missingDates.add(targetDate);
                }
            }

            // Only notify if there are missing logs
            if (!missingDates.isEmpty()) {
                String body = 'Dear ' + u.Name + ',\n\nYou have not submitted time logs for the following dates:\n';
                for (Date d : missingDates) {
                    body += '- ' + d.format() + '\n';
                }
                body += '\nPlease make sure to log your time.';

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { u.Email });
                email.setSubject('Missing Time Log Notification');
                email.setPlainTextBody(body);

                emailsToSend.add(email);
            }
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend, false);
        }
    }
}