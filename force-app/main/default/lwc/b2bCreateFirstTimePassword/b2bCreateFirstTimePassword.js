import { LightningElement, api,wire } from 'lwc';
import createFirstTimePassword from '@salesforce/apex/B2BFirstTimePasswordController.createFirstTimePassword'; 
export default class B2bCreateFirstTimePassword extends LightningElement {
    @api recordId; // The Contact ID passed from the parent component
    passwordGenerated = false;
    password = '';
    error = '';
    isProcessing = false; 
    handleGeneratePassword() {
        createFirstTimePassword({ contactId: this.recordId })
            .then(result => {
                this.passwordGenerated = true;
                this.password = result;
                this.isProcessing = false;
                this.refreshRecordPage();
            })
            .catch(error => {
                console.log('recordId==>',this.recordId);
                this.error = 'An error occurred while generating the password';
                console.error(error);
            });
        
    }
    refreshRecordPage() {
        // Use the NavigationMixin to refresh the current record page
        window.location.reload();
    }

}