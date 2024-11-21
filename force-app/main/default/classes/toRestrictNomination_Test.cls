@IsTest
private with sharing class toRestrictNomination_Test {
     
     static testmethod void restrictPositivtestting(){
     	
     	Account acc = new Account();
     	acc.name = 'test';
     	acc.Max_Complimentary__c = 2;
     	acc.Max_Standard__c = 2;
     	acc.Max_Reduce__c = 2;
     	acc.Max_External_Reduced_Rate_C__c = 2;
     	insert acc;
     	
     	Nomination__c nom = new Nomination__c();
     	nom.Organization_Name__c = acc.Id;
     	nom.Year__c = '2019';
     	nom.Registration_Type__c = 'Complimentary';
     	//nom.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom;
     	
     	Nomination__c nom3 = new Nomination__c();
     	nom3.Organization_Name__c = acc.Id;
     	nom3.Year__c = '2019';
     	nom3.Registration_Type__c = 'Complimentary';
     	//nom3.External_Registration_Type__c = 'Reduced-Rate'; 
     	
     	insert nom3;
     	
     	Nomination__c nom4 = new Nomination__c();
     	nom4.Organization_Name__c = acc.Id;
     	nom4.Year__c = '2020';
     	nom4.Registration_Type__c = 'Complimentary';
     	//nom4.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom4;
     	
     	Nomination__c nom1 = new Nomination__c();
     	nom1.Organization_Name__c = acc.Id;
     	nom1.Year__c = '2019';
     	nom1.Registration_Type__c = 'Reduced-Rate';
     	//nom1.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom1;
     	
     	Nomination__c nom5 = new Nomination__c();
     	nom5.Organization_Name__c = acc.Id;
     	nom5.Year__c = '2019';
     	nom5.Registration_Type__c = 'Reduced-Rate';
     	//nom5.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom5;
     	
     	Nomination__c nom6 = new Nomination__c();
     	nom6.Organization_Name__c = acc.Id;
     	nom6.Year__c = '2020';
     	nom6.Registration_Type__c = 'Reduced-Rate';
     	//nom6.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom6;
     	
     	Nomination__c nom2 = new Nomination__c();
     	nom2.Organization_Name__c = acc.Id;
     	nom2.Year__c = '2021';
     	nom2.Registration_Type__c = 'Standard-Rate';
     	//nom2.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom2;
     	
     	Nomination__c nom7 = new Nomination__c();
     	nom7.Organization_Name__c = acc.Id;
     	nom7.Year__c = '2021';
     	nom7.Registration_Type__c = 'Standard-Rate';
     	//nom7.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom7;
     	
     	Nomination__c nom8 = new Nomination__c();
     	nom8.Organization_Name__c = acc.Id;
     	nom8.Year__c = '2022';
     	nom8.Registration_Type__c = 'Standard-Rate';
     	//nom8.External_Registration_Type__c = 'Reduced-Rate';
     	
     	
     	insert nom8;
     	
     }
     
     static testmethod void restrictPositivtestting2(){
     	
     	Account acc = new Account();
     	acc.name = 'test';
     	acc.Max_Complimentary__c = 3;
     	acc.Max_Standard__c = 3;
     	acc.Max_Reduce__c = 3;
     	acc.Max_External_Reduced_Rate_C__c = 3;
     	insert acc;
     	
     	Nomination__c nom = new Nomination__c();
     	nom.Organization_Name__c = acc.Id;
     	nom.Year__c = '2019';
     	//nom.Registration_Type__c = 'Complimentary';
     	//nom.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom;
     	
     	Nomination__c nom3 = new Nomination__c();
     	nom3.Organization_Name__c = acc.Id;
     	nom3.Year__c = '2019';
     	//nom3.Registration_Type__c = 'Complimentary';
     	//nom3.External_Registration_Type__c = 'Reduced-Rate'; 
     	
     	insert nom3;
     	
     	Nomination__c nom4 = new Nomination__c();
     	nom4.Organization_Name__c = acc.Id;
     	nom4.Year__c = '2020';
     	//nom4.Registration_Type__c = 'Complimentary';
     	//nom4.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom4;
     	
     	Nomination__c nom1 = new Nomination__c();
     	nom1.Organization_Name__c = acc.Id;
     	nom1.Year__c = '2019';
     	//nom1.Registration_Type__c = 'Reduced-Rate';
     	//nom1.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom1;
     	
     	Nomination__c nom5 = new Nomination__c();
     	nom5.Organization_Name__c = acc.Id;
     	nom5.Year__c = '2022';
     	//nom5.Registration_Type__c = 'Reduced-Rate';
     	//nom5.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom5;
     	
     	Nomination__c nom6 = new Nomination__c();
     	nom6.Organization_Name__c = acc.Id;
     	nom6.Year__c = '2020';
     	//nom6.Registration_Type__c = 'Reduced-Rate';
     	//nom6.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom6;
     	
     	Nomination__c nom2 = new Nomination__c();
     	nom2.Organization_Name__c = acc.Id;
     	nom2.Year__c = '2021';
     	//nom2.Registration_Type__c = 'Standard-Rate';
     	//nom2.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom2;
     	
     	Nomination__c nom7 = new Nomination__c();
     	nom7.Organization_Name__c = acc.Id;
     	nom7.Year__c = '2021';
     	//nom7.Registration_Type__c = 'Standard-Rate';
     	//nom7.External_Registration_Type__c = 'Reduced-Rate';
     	
     	insert nom7;
     	
     	Nomination__c nom8 = new Nomination__c();
     	nom8.Organization_Name__c = acc.Id;
     	nom8.Year__c = '2022';
     	//nom8.Registration_Type__c = 'Standard-Rate';
     	///nom8.External_Registration_Type__c = 'Reduced-Rate';
     	
     	
     	insert nom8;
     	
     }
     
     
}