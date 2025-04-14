@isTest
private class TimeTrackingControllerTest {

    @testSetup
    static void setupData() {
        
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;
    }

    @isTest
    static void testGetProjects() {
       
        List<Project__c> projects = TimeTrackingController.getProjects();
        System.assertNotEquals(0, projects.size(), 'Should return at least one project');
        System.assertEquals('Test Project', projects[0].Name);
    }

    @isTest
    static void testSaveTimeLog() {
        Project__c project = [SELECT Id FROM Project__c LIMIT 1];

        Date logDate = Date.today();
        Decimal hoursWorked = 4.5;

        Test.startTest();
        TimeTrackingController.saveTimeLog(project.Id, logDate, hoursWorked);
        Test.stopTest();

        List<Time_Log__c> logs = [SELECT Id, Project__c, Log_Date__c, Hours_Logged__c, Employee__c FROM Time_Log__c];
        System.assertEquals(1, logs.size(), 'One time log should be inserted');
        System.assertEquals(project.Id, logs[0].Project__c);
        System.assertEquals(logDate, logs[0].Log_Date__c);
        System.assertEquals(hoursWorked, logs[0].Hours_Logged__c);
        System.assertEquals(UserInfo.getUserId(), logs[0].Employee__c);
    }
}