public class B2BUpdateContact {

    @InvocableMethod(label = 'Update Contact Record')
    public static void updateContactFields(List<Id> contactIds) {
        String contactId = contactIds.get(0);
        updateContact(contactId);
    }

    @future
    private static void updateContact(String contactId) {
        Contact contact = [SELECT hasCommerceStoreAccess__c FROM Contact WHERE Id =: contactId];
        contact.hasCommerceStoreAccess__c = true;

        update contact;
    }
}