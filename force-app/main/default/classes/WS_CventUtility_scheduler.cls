global class WS_CventUtility_scheduler implements Schedulable, Database.AllowsCallouts {
     global void execute(SchedulableContext SC) {
         WS_CventUtility cv = new WS_CventUtility();
         Database.executeBatch(cv);
     }
}