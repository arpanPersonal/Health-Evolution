public class TriggerSupportContact 
{

/*
    Created 4/4/2013  ASC     Groove Analytics LLC
    Central dispatch class for Contact object trigger.   
    


*/

    public static boolean TriggerIsExecuting  = false; 
    public static boolean AfterFired = false;
    public static boolean BeforeFired = false;

    
    public boolean IsBefore  = false; 
    public boolean IsAfter = false; 
    public boolean IsDelete = false; 
    public boolean IsInsert = false;  
    public boolean IsUpdate = false;  
    
    
    private list<Contact> listNew  = new list<Contact>(); 
    private list<Contact> listOld = new list<Contact>(); 
    private map<Id, Contact> mapNew = new map<Id, Contact>();
    private map<Id, Contact> mapOld = new map<Id, Contact>();
    
    //constructor
    public TriggerSupportContact(Boolean bBefore, Boolean bDelete,
                            Boolean bAfter, Boolean bInsert,Boolean bUpdate, 
                            List<Contact> newlist, Map<ID, Contact> newmap,
                            List<Contact> oldlist, Map<ID, Contact> oldmap) 
    {
        
        //fill members with passed variables
        IsBefore  = bBefore; 
        IsDelete = bDelete; 
        IsAfter = bAfter;  
        IsInsert = bInsert;  
        IsUpdate = bUpdate;
          
        if (newlist != null) listNew.AddAll(newlist);
        if (oldlist != null) listOld.AddAll(oldlist);
        if (newmap != null) mapNew = newmap;
        if (oldmap != null) mapOld = oldmap;
                            
    } 
    
    public void doMainEntry()
    {
        if (TriggerIsExecuting == False) 
        {
            TriggerIsExecuting = true;
        }
        
        if (IsBefore)
        {
            BeforeFired = true;
            
            if (IsInsert || IsUpdate)
            {
                //first get length of target field
                integer syncLength= Schema.SObjectType.Contact.fields.Outlook_Categories_Sync__c.getLength();  

                //if Outlook_Categories__c is not null and either this is an insert or it's changed, update Outlook_Categories_Sync__c with values
                for (Contact c : listNew)
                {
                    if (c.Outlook_Categories__c != null 
                        && (IsInsert || (IsUpdate && mapOld.get(c.Id).Outlook_Categories__c != mapNew.get(c.Id).Outlook_Categories__c)))
                            try
                            { 
                                c.Outlook_Categories_Sync__c = c.Outlook_Categories__c.Replace(';',',').left(syncLength) ; 
                            }
                            catch (exception ex)
                            {
                                system.debug(ex.getMessage());
                                c.AddError(ex.getMessage());
                            }
                }
                
            } //(IsInsert || IsUpdate)
        }
        else if (IsAfter)
        {
            AfterFired = true;
        } //IsAfter

    }//doMainEntry
   
}