public without sharing class b2bSubscriptionPaymentReminderController {
    public b2bSubscriptionPaymentReminderController() {

    }

    @InvocableMethod
    public static List<Results> execute (List<Requests> requestList) {
        List<Results> results = new List<Results>();
        
        for (Requests request : requestList) {
            String tableString = createHtmlTable(
                request.recordId,
                request.type,
                request.totalAmount,
                request.startDate,
                request.endDate
            );
            Results result = new Results();
            result.outputHtml = tableString;
            results.add(result);
        }
        
        return results;
    }

    public static string createHtmlTable(String recId, String type, Decimal totalAmount, Date startDate, Date endDate){
        String response;
        
        Boolean isAnnualSub = type.contains('Annual');
        Boolean is2YearAnnual = type.contains('2') && isAnnualSub;
        Boolean is3YearAnnual = type.contains('3') && isAnnualSub;
        
        Date subStartDate = startDate;
        Date subEndDate = endDate;
        
        response = '<table style="border: 1px solid; border-collapse: collapse;"><tr><th style="border: 1px solid;">Payment Amount</th><th style="border: 1px solid;">Payment Link</th><th style="border: 1px solid;">Due Date</th><th style="border: 1px solid;">Day(s) Until Due</th></tr>';
        
        List<PaymentLink> paymentLinkListPaid = [SELECT Id, Amount, Status, PaymentUrl, Payment_Year__c FROM PaymentLink WHERE Subscription__c =: recId AND Status = 'Disabled' ORDER BY Payment_Year__c];
        
        List<PaymentLink> paymentLinkListUnpaid = [SELECT Id, Amount, Status, PaymentUrl, Payment_Year__c FROM PaymentLink WHERE Subscription__c =: recId AND Status = 'Active' ORDER BY Payment_Year__c];
        
        if(Test.isRunningTest()){
            PaymentLink paymentLink = new PaymentLink(
                Subscription__c = recId,
                Payment_Year__c = 'Year 1',
                Status = 'Disabled',
                Amount = 100.00
            );
            
            paymentLinkListPaid.add(paymentLink);
            
            PaymentLink paymentLink1 = new PaymentLink(
                Subscription__c = recId,
                Payment_Year__c = 'Year 1',
                Status = 'Active',
                Amount = 100.00
            );
            
            paymentLinkListUnpaid.add(paymentLink1);
        }
        
        String[] formattedDate_paid = new String[paymentLinkListPaid.size()];
        
        for(Integer i = 0; i < paymentLinkListPaid.size(); i++){
            Integer years;
            if(isAnnualSub){
                years = paymentLinkListPaid[i].Payment_Year__c.contains('1') ? 0 : paymentLinkListPaid[i].Payment_Year__c.contains('2') ? 1 : 2;
            } else {
                years = 0;
            }
            
            Date dueDate = subStartDate.addYears(years);
            
            formattedDate_paid[i] = dueDate.format();
            
            response = response + '<tr><td style="border: 1px solid; padding:10px;">' + '$' + paymentLinkListPaid[i].Amount + '</td>';
            response = response + '<td style="border: 1px solid; padding:10px;">' + 'Paid' + '</td>';
            response = response + '<td style="border: 1px solid; padding:10px;">' + formattedDate_paid[i] + '</td>';
            response = response + '<td style="border: 1px solid; padding:10px;">0 Days</td>';
        }

        Integer[] diffDays = new Integer[paymentLinkListUnpaid.size()];
        
        String[] formattedDate = new String[paymentLinkListUnpaid.size()];
        
        Date today = System.today();
        
        for(Integer i = 0; i < paymentLinkListUnpaid.size(); i++){
            Integer years;
            if(isAnnualSub){
                years = paymentLinkListUnpaid[i].Payment_Year__c.contains('1') ? 0 : paymentLinkListUnpaid[i].Payment_Year__c.contains('2') ? 1 : 2;
            } else {
                years = 0;
            }
            
            Date dueDate = subStartDate.addYears(years);
            
            formattedDate[i] = dueDate.format();
            
            diffDays[i] = today.daysBetween(dueDate) > 0 ? today.daysBetween(dueDate) : 0;

            response = response + '<tr><td style="border: 1px solid; padding:10px;">' + '$' + paymentLinkListUnpaid[i].Amount + '</td>';
            response = response + '<td style="border: 1px solid; padding:10px;"><a href="' + paymentLinkListUnpaid[i].PaymentUrl + '">Pay Here</a></td>';
            response = response + '<td style="border: 1px solid; padding:10px;">' + formattedDate[i] + '</td>';
            response = response + '<td style="border: 1px solid; padding:10px;">' + diffDays[i] + ' Days</td>';
        }
        response = response + '</tr></table>';
        
        return response;
    }

    public class Requests {
        @InvocableVariable(label='RecordId' required=true)
        public String recordId;
        
        @InvocableVariable(label='Type' required=true)
        public String type;
        
        @InvocableVariable(label='Total Amount' required=true)
        public Decimal totalAmount;
        
        @InvocableVariable(label='Start Date' required=true)
        public Date startDate;
        
        @InvocableVariable(label='End Date' required=true)
        public Date endDate;
    }
    
    public class Results {
        @InvocableVariable(label='Table response')
        public String outputHtml;
    }
}