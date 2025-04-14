public class TimeLogMonitor implements Schedulable {
    public void execute(SchedulableContext sc) {
        TimeLogReminder.monitorAndNotify();
    }
}