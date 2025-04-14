@isTest
public class TimeLogMonitorTest {

    @testSetup
    static void setupData() {
        // Query  Profile and Role
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Time logger profile' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Time logger' LIMIT 1];

        // Created test user
        User user1 = new User(
            Username = 'uniqueuser1@example.com',
            Email = 'gaurav26.joshi1998@gmail.com',
            Alias = 'userone',
            ProfileId = profile.Id,
            UserRoleId = role.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            FirstName = 'Test',
            LastName = 'Logger',
            CompanyName = 'TimeLoggers Inc.'
        );
        insert user1;

        User user2 = new User(
            Username = 'uniqueuser2@example.com',
            Email = 'gaurvansh1998@gmail.com',
            Alias = 'usertwo',
            ProfileId = profile.Id,
            UserRoleId = role.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            FirstName = 'Missing',
            LastName = 'Logger',
            CompanyName = 'TimeLoggers Inc.'
        );
        insert user2;
    }

    @isTest
    static void testTimeLogMonitor_AllLogsPresent() {
        User user1 = [SELECT Id, Email FROM User WHERE Username = 'uniqueuser1@example.com' LIMIT 1];

        Test.startTest();

        Project__c project = new Project__c(Name = 'Project One');
        insert project;

        List<Time_Log__c> logs = new List<Time_Log__c>{
            new Time_Log__c(
                Employee__c = user1.Id,
                Project__c = project.Id,
                Log_Date__c = Date.today(),
                Hours_Logged__c = 8
            ),
            new Time_Log__c(
                Employee__c = user1.Id,
                Project__c = project.Id,
                Log_Date__c = Date.today().addDays(-1),
                Hours_Logged__c = 8
            )
        };
        insert logs;

        System.schedule('DailyTimeLogMonitor', '0 0 18 * * ?', new TimeLogMonitor());
        Test.stopTest();
    }

    @isTest
    static void testTimeLogMonitorWithMissingLogs() {
        User user2 = [SELECT Id, Email FROM User WHERE Username = 'uniqueuser2@example.com' LIMIT 1];

        Test.startTest();

        Project__c project = new Project__c(Name = 'Project Two');
        insert project;

        // Log only yesterday - today is missing
        Time_Log__c log = new Time_Log__c(
            Employee__c = user2.Id,
            Project__c = project.Id,
            Log_Date__c = Date.today().addDays(-1),
            Hours_Logged__c = 8
        );
        insert log;

        System.schedule('WeeklyTimeLogMonitor', '0 0 18 ? * FRI', new TimeLogMonitor());
        Test.stopTest();
    }
}