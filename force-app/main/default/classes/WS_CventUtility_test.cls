@isTest(SeeAllData = true)
private class WS_CventUtility_test {
    static testMethod void test(){
 
        Database.BatchableContext BC; 
        Test.setMock(WebServiceMock.class, new CallOutsGeneraterMock());
        
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        Test.startTest();
        TestHelper.unitRun();
        //WS_CventUtility.getUpdatedContacts();
        schemasCventComApi200611.GetUpdatedResult objGet = new schemasCventComApi200611.GetUpdatedResult();
        WS_CventUtility  ws = New WS_CventUtility();
        DataBase.executeBatch(ws);
        ws.finish(BC);
        Test.stopTest();
        
    }
    
   
}