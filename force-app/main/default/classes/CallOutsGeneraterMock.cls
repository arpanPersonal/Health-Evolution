@isTest(seeAllData = true)
global class CallOutsGeneraterMock implements WebServiceMock {
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction, 
           String requestName,
           String responseNS, 
           String responseName,
           String responseType) {
               
               Contact contobj = [Select id from Contact limit 1];
               System.debug('***contobj**'+contobj.id);
               /* Contact contobj = new Contact();
                contobj.LastName = 'test';
                insert contobj ; */
               
               if( requestName == 'Login' ){
                    schemasCventComApi200611.LoginResult result = new schemasCventComApi200611.LoginResult();       
                    schemasCventComApi200611.LoginResponse_element response_x = new schemasCventComApi200611.LoginResponse_element();
                    response_x.LoginResult = result ;
                    response.put('response_x', response_x );
               }
               
               if( requestName == 'GetUpdated' ){
                 schemasCventComApi200611.GetUpdatedResult GetUpObj = new  schemasCventComApi200611.GetUpdatedResult();
                 schemasCventComApi200611.GetUpdatedResponse_element response_x = new schemasCventComApi200611.GetUpdatedResponse_element();
                 response_x.GetUpdatedResult = GetUpObj ;
                 response.put('response_x', response_x );
               }
               
               if( requestName == 'RetrieveInvitees'){
                    list<schemasCventComApi200611.Invitee> Invieelist = new list<schemasCventComApi200611.Invitee>();
                    schemasCventComApi200611.Invitee InvObj = new schemasCventComApi200611.Invitee();
                    InvObj.SourceId = contobj.id;
                    InvObj.ContactId = 'test2' ;
                    Invieelist.add(InvObj) ;
                   
                    schemasCventComApi200611.ArrayOfInvitee invitees = new schemasCventComApi200611.ArrayOfInvitee();
                    invitees.Invitee = Invieelist ;
                    schemasCventComApi200611.RetrieveInviteesResponse_element response_x1 = new schemasCventComApi200611.RetrieveInviteesResponse_element();
                    response_x1.RetrieveInviteesResult = invitees ;
                    response.put('response_x', response_x1 );
               }
               
               if( requestName == 'RetrieveContacts' ){
                    
                    list<schemasCventComApi200611.CustomFieldDetail> custflist = new list<schemasCventComApi200611.CustomFieldDetail>();
                    schemasCventComApi200611.CustomFieldDetail detObj = new schemasCventComApi200611.CustomFieldDetail();
                    Summit__c summitObj = [Select id From Summit__c limit 1];
                    System.debug('**summitObj***'+summitObj.id);
                    detObj.FieldName = 'Summit Status ID (Salesforce)';
                    detObj.FieldValue = summitObj.id;
                    custflist.add( detObj );
                   // system.debug('**object***'+stub+'****requestObj***'+request);
                    list<schemasCventComApi200611.Contact> contList = new list<schemasCventComApi200611.Contact>(); 
                    schemasCventComApi200611.Contact conObj = new schemasCventComApi200611.Contact();
                    conObj.CustomFieldDetail = custflist ;
                    conObj.sourceId = contobj.id ;
                    contList.add(conObj);
                    schemasCventComApi200611.ArrayOfContact contacts = new schemasCventComApi200611.ArrayOfContact();
                    contacts.contact = contList ;
                    schemasCventComApi200611.RetrieveContactsResponse_element response_x = new schemasCventComApi200611.RetrieveContactsResponse_element();
                    response_x.RetrieveContactsResult = contacts ;
                    response.put('response_x', response_x );
               }
               
               if( requestName == 'RetrieveRegistrations' ){
                   list<schemasCventComApi200611.OrderDetail> orderlist = new list<schemasCventComApi200611.OrderDetail>();
                   schemasCventComApi200611.OrderDetail order = new schemasCventComApi200611.OrderDetail();
                   order.Action = 'Registered' ;
                   order.ProductId = 'test';
                   order.productName = 'test';
                   orderlist.add(order);
                   list<schemasCventComApi200611.Registration> reglist = new list<schemasCventComApi200611.Registration>();
                   schemasCventComApi200611.Registration regObj = new schemasCventComApi200611.Registration();
                   regObj.OrderDetail = orderlist ;
                   reglist.add(regObj);
                   schemasCventComApi200611.ArrayOfRegistration registrations = new schemasCventComApi200611.ArrayOfRegistration();
                   registrations.Registration = reglist ;
                   schemasCventComApi200611.RetrieveRegistrationsResponse_element response_x = new schemasCventComApi200611.RetrieveRegistrationsResponse_element(); 
                   response_x.RetrieveRegistrationsResult = registrations ;
                   response.put('response_x', response_x );
               }
       
   }
}