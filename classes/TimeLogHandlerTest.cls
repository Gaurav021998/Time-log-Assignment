@isTest
public class TimeLogHandlerTest {

    @isTest
    private static void testValidateHours() {

        // Create an employee record 
        User testUser = new User(
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Created Time Log
        Time_Log__c timeLog1 = new Time_Log__c(
            Employee__c = testUser.Id,
            Log_Date__c = Date.today(),
            Hours_Logged__c = 4
        );
        insert timeLog1;

        // Create another valid Time Log, should pass as 4 + 4 = 8 hours
        Time_Log__c timeLog2 = new Time_Log__c(
            Employee__c = testUser.Id,
            Log_Date__c = Date.today(),
            Hours_Logged__c = 4
        );
        insert timeLog2;

        // Create invalid Time Log, should fail as total hours will be 12 (4 + 4 + 4)
        Time_Log__c timeLog3 = new Time_Log__c(
            Employee__c = testUser.Id,
            Log_Date__c = Date.today(),
            Hours_Logged__c = 4
        );

        try {
            insert timeLog3; 
            System.assert(false, 'Test failed, expected error not thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('You cannot log more than 8 hours for the same date.'));
        }

        // Update timeLog2 to exceed 8 hours
        timeLog2.Hours_Logged__c = 5;

        try {
            update timeLog2; 
            System.assert(false, 'Test failed, expected error not thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('You cannot log more than 8 hours for the same date.'));
        }
    }
}