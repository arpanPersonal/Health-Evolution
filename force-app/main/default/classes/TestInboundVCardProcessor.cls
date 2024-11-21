@IsTest
public class TestInboundVCardProcessor {

/*
    Test class for InboundVCardProcessor and InboundVCardPersonProcessor.  
*/

   public static testMethod void ProcessContactVCardTest(){
        
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //this is a real vcard sample
        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;\r\n';
        sAttachmentBody +=  ' United States of America\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'From';
        h.Value = 'invalid@email.address';
        
        email.headers[0]=h;        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';
 
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    }

   public static testMethod void ProcessContactVCardForwardedTest(){
        
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //this is a real vcard sample
        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;\r\n';
        sAttachmentBody +=  ' United States of America\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';

        email.headers=new Messaging.InboundEmail.Header[4];
        
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        h.Name = 'Resent-From';
        h.Value = 'invalid@email.address';
        email.headers[0]=h;        

        Messaging.InboundEmail.Header h1 = new Messaging.InboundEmail.Header();
        h1.Name = 'From';
        h1.Value = 'invalid@email.address';
        email.headers[1]=h1;    
        
        Messaging.InboundEmail.Header h2 = new Messaging.InboundEmail.Header();
        h2.Name = 'To';
        h2.Value = 'invalid@email.address';
        email.headers[2]=h2;            

        Messaging.InboundEmail.Header h3 = new Messaging.InboundEmail.Header();
        h3.Name = 'Delivered-To';
        h3.Value = 'invalid@email.address';
        email.headers[3]=h3;        

        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';
 
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    }
 
    @isTest(SeeAllData=true) 
    public static void ProcessPersonVCardTest(){
    
     //first determine if PersonAccounts are enabled
     Map<String, Schema.SObjectField> accFieldMap = Schema.sObjectType.Account.fields.getMap();
     
     if(accFieldmap.get('IsPersonAccount') != null)
     {    
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                PersonAccount__c = true,
                                                                PersonCompanyField__c = 'Company__pc',
                                                                EmailField__c = 'PersonEmail',
                                                                Email2Field__c = 'Email_2__pc',
                                                                Email3Field__c = 'Email_3__pc',
                                                                WorkAddressField__c = 'BillingStreet',
                                                                WorkAddressCityField__c = 'BillingCity',
                                                                WorkAddressStateField__c = 'BillingState',
                                                                WorkAddressZipField__c = 'BillingPostalCode',
                                                                WorkAddressCountryField__c = 'BillingCountry',
                                                                AccountRecordTypeName__c = 'Individual LP',
                                                                TitleField__c = 'PersonTitle',
                                                                MiddleNameField__c = 'Middle_Initial__pc',
                                                                SuffixField__c = 'Suffix__pc');
        insert vcc;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //this is a real vcard sample
        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;\r\n';
        sAttachmentBody +=  ' United States of America\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'From';
        h.Value = 'invalid@email.address';
        
        email.headers[0]=h;        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';
 
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
     }
    }
       
     public static testMethod void ProcessPersonVCardForwardedTest(){
        
             //first determine if PersonAccounts are enabled
     Map<String, Schema.SObjectField> accFieldMap = Schema.sObjectType.Account.fields.getMap();
     
     if(accFieldmap.get('IsPersonAccount') != null)
     {
     
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                PersonAccount__c = true,
                                                                PersonCompanyField__c = 'Company__pc',
                                                                EmailField__c = 'PersonEmail',
                                                                Email2Field__c = 'Email_2__pc',
                                                                Email3Field__c = 'Email_3__pc',
                                                                WorkAddressField__c = 'BillingStreet',
                                                                WorkAddressCityField__c = 'BillingCity',
                                                                WorkAddressStateField__c = 'BillingState',
                                                                WorkAddressZipField__c = 'BillingPostalCode',
                                                                WorkAddressCountryField__c = 'BillingCountry',
                                                                AccountRecordTypeName__c = 'Individual LP',
                                                                TitleField__c = 'PersonTitle',
                                                                MiddleNameField__c = 'Middle_Initial__pc',
                                                                SuffixField__c = 'Suffix__pc');
        insert vcc;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //this is a real vcard sample
        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;\r\n';
        sAttachmentBody +=  ' United States of America\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';

        email.headers=new Messaging.InboundEmail.Header[3];
        
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        h.Name = 'Resent-From';
        h.Value = 'invalid@email.address';
        email.headers[0]=h;        

        Messaging.InboundEmail.Header h1 = new Messaging.InboundEmail.Header();
        h1.Name = 'From';
        h1.Value = 'Some Person <invalid@email.address>';
        email.headers[1]=h1;    
        
        Messaging.InboundEmail.Header h2 = new Messaging.InboundEmail.Header();
        h2.Name = 'To';
        h2.Value = 'Mister Roberts <invalid@email.address>';
        email.headers[2]=h2;            
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';
 
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
     }
    }

    
    public static testMethod void UnexpectedMimeTypeTest(){
 
         
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;
               
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'blah\r\n';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/text';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                                 
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    }

     
    public static testMethod void NoAttachmentTest(){
        
       VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                                     
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    }
    
    public static testMethod void IncompleteInfoTest(){
         VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
              
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:;;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;USA\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                                
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    }
    
    public static testMethod void UnsupportedVersionTest(){
       VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
                
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:4.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:;;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;USA\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
           
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                        
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    }
 
    @isTest(SeeAllData=true) 
    public static void ContactAlreadyExistsTest(){
        
        contact con = new Contact(Firstname = 'Firstname',
                                Lastname = 'Lastname',
                                Email = 'test@test.net'); //an email match should be sufficient to reject
        insert con;
        
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:test@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;USA\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';

        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';

        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                                
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    } 
    
    @isTest(SeeAllData=true) 
    public static void AccountAlreadyExistsTest(){
        
        account a = new Account(Name = 'TestCompany');
        insert a;
        
        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
               
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:anothertest@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;USA\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';
     
        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';
  
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                              
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    } 

    @isTest(SeeAllData=true) 
    public static void ContactOwnerExistsTest(){
       VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:anothertest@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;USA\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';

        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = [Select Email From User Where IsActive = true Limit 1][0].Email; 
        envelope.toAddress = 'test@email.com';
  
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                                   
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
    
    }     
 
     @isTest(SeeAllData=true) 
    public static void PersonOwnerExistsTest(){
     
     //first determine if PersonAccounts are enabled
     Map<String, Schema.SObjectField> accFieldMap = Schema.sObjectType.Account.fields.getMap();
     
     if(accFieldmap.get('IsPersonAccount') != null)
     {
       // PersonAccounts enabled

        VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                PersonAccount__c = true,
                                                                PersonCompanyField__c = 'Company__pc',
                                                                EmailField__c = 'PersonEmail',
                                                                Email2Field__c = 'Email_2__pc',
                                                                Email3Field__c = 'Email_3__pc',
                                                                WorkAddressField__c = 'BillingStreet',
                                                                WorkAddressCityField__c = 'BillingCity',
                                                                WorkAddressStateField__c = 'BillingState',
                                                                WorkAddressZipField__c = 'BillingPostalCode',
                                                                WorkAddressCountryField__c = 'BillingCountry',
                                                                AccountRecordTypeName__c = 'Individual LP',
                                                                TitleField__c = 'PersonTitle',
                                                                MiddleNameField__c = 'Middle_Initial__pc',
                                                                SuffixField__c = 'Suffix__pc');
        insert vcc;    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody +=  'PROFILE:VCARD\r\n';
        sAttachmentBody +=  'VERSION:3.0\r\n';
        sAttachmentBody +=  'MAILER:Microsoft Exchange\r\n';
        sAttachmentBody +=  'PRODID:Microsoft Exchange\r\n';
        sAttachmentBody +=  'FN:Mr. MiddleName LasName Suffix\r\n';
        sAttachmentBody +=  'N:Lastname;Firstname;MiddleName;Mr.;Suffix\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:anothertest@test.net\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email2@goofy.com\r\n';
        sAttachmentBody +=  'EMAIL;TYPE=INTERNET:email3@goofy.com\r\n';
        sAttachmentBody +=  'NOTE:FirstLine\\nSecondLine\\n\r\n';
        sAttachmentBody +=  'ORG:TestCompany;\r\n';
        sAttachmentBody +=  'CLASS:PUBLIC\r\n';
        sAttachmentBody +=  'ADR;TYPE=WORK:;;123 Business Address\\nSuite 24;San Francisco;CA;95444;USA\r\n';
        sAttachmentBody +=  'LABEL;TYPE=WORK:123 Business Address\\nSuite 24\\nSan Francisco\\, CA  95444\r\n';
        sAttachmentBody +=  'ADR;TYPE=HOME:;;;;;;\r\n';
        sAttachmentBody +=  'ADR;TYPE=POSTAL,PREF:;;;;;;\r\n';
        sAttachmentBody +=  'LABEL;TYPE=POSTAL,PREF:\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK:(415) 555-5555\r\n';
        sAttachmentBody +=  'TEL;TYPE=HOME:(415) 111-1111\r\n';
        sAttachmentBody +=  'TEL;TYPE=CELL:(415) 666-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=WORK,FAX:(415) 222-6666\r\n';
        sAttachmentBody +=  'TEL;TYPE=VOICE:\r\n';
        sAttachmentBody +=  'X-MS-TEL;TYPE=ASSISTANT:\r\n';
        sAttachmentBody +=  'X-MS-ASSISTANT;TYPE=N:\r\n';
        sAttachmentBody +=  'TITLE:JobTitle\r\n';
        sAttachmentBody +=  'REV;VALUE=DATE-TIME:2012-11-21T19:32:37,462Z\r\n';
        sAttachmentBody +=  'END:VCARD';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';

        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = [Select Email From User Where IsActive = true Limit 1][0].Email; 
        envelope.toAddress = 'test@email.com';
  
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                                   
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
     }
    }  
       
     public static testMethod void EncodedFieldsTest(){
       VCard_Configuration__c vcc = new VCard_Configuration__c(AddressedTo__c = 'test@email.com',
                                                                EmailField__c = 'Email',
                                                                Email2Field__c = 'Email_2__c',
                                                                Email3Field__c = 'Email_3__c',
                                                                WorkAddressField__c = 'MailingStreet',
                                                                WorkAddressCityField__c = 'MailingCity',
                                                                WorkAddressStateField__c = 'MailingState',
                                                                WorkAddressZipField__c = 'MailingPostalCode',
                                                                WorkAddressCountryField__c = 'MailingCountry',
                                                                AccountRecordTypeName__c = 'Organization',
                                                                TitleField__c = 'Title',
                                                                MiddleNameField__c = 'Middle_Initial__c',
                                                                SuffixField__c = 'Suffix__c');
        insert vcc;    
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //this is a real vcard sample
        String sAttachmentBody = 'BEGIN:VCARD\r\n';
        sAttachmentBody += 'VERSION:2.1\r\n';
        sAttachmentBody += 'N:Cope;Alexander;Walter;Mr.;\r\n';
        sAttachmentBody += 'FN:Mr. Alexander Walter Cope\r\n';
        sAttachmentBody += 'TEL;HOME:+1-541-111-6074\r\n';
        sAttachmentBody += 'TEL;CELL:+1-541-111-7628\r\n';
        sAttachmentBody += 'TEL;WORK:+1-212-111-6086\r\n';
        sAttachmentBody += 'TEL;WORK;FAX:+1-212-111-6087\r\n';
        sAttachmentBody += 'EMAIL;PREF;WORK:acop@fisherinv.com\r\n'; //mistake on next line is intentional
        sAttachmentBody += 'ADR;WORK;ENCODING=QUOTED-PRINTABLE:;;=31=32=33=20=4d=61=69=6e=20=53=74=72=65=65=74;=4e=65=77=20=59=6f=72=6b;=4e=59;=31=30=31=30=356;\n';
        sAttachmentBody += 'ORG:Fisher Investment Group\r\n';
        sAttachmentBody += 'URL:http://www.fisherinv.com/\r\n';
        sAttachmentBody += 'NOTE;ENCODING=QUOTED-PRINTABLE:=45=6D=61=69=0a\n';
        sAttachmentBody += 'END:VCARD\r\n';
        
        email.subject = 'Test Subject';
        email.fromName = 'Admin';
        email.plainTextBody = 'Test Body.';                

        Messaging.InboundEmail.Textattachment[] textAttachments = new Messaging.Inboundemail.Textattachment[1];
        Messaging.InboundEmail.Textattachment textAttachment = new Messaging.Inboundemail.Textattachment();
        textAttachment.Filename = 'test.vcf';
        textAttachment.mimeTypeSubType = 'text/vcard';
        textAttachment.Body = sAttachmentBody;
        textAttachments[0] = textAttachment;
        email.textAttachments = textAttachments;
        envelope.fromAddress = 'invalid@email.address';
        envelope.toAddress = 'test@email.com';
    
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        
        h.Name = 'TestHeader';
        h.Value = 'TestNonsense';
        
        email.headers[0]=h;  
                            
        InboundVCardProcessor c = new InboundVCardProcessor();
        Messaging.InboundEmailResult result = c.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
    }  
 
}