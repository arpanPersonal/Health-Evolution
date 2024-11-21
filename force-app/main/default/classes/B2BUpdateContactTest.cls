@IsTest
public class B2BUpdateContactTest {
    @testSetup static void methodName() {
        Contact con = new Contact();
        con.FirstName = 'Test First Name';
        con.LastName = 'Test Last Name';
        con.Email = 'test@test.com';
        insert con;
    }
    
    @IsTest static void testMethod1(){
        Contact con = [Select Id from Contact Limit 1 ];
        List<Id> conIds = new List<Id>();
        conIds.add(con.Id);
        B2BUpdateContact.updateContactFields(conIds);
        Contact con1 = [Select Id,hasCommerceStoreAccess__c from Contact where Id =: conIds[0] ];

        
        

    }
}