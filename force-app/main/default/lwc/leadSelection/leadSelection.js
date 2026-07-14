import { LightningElement, api, track } from 'lwc';
import getDuplicateLeads from '@salesforce/apex/LeadSelectionController.getDuplicateLeads';
import getDuplicateContacts from '@salesforce/apex/LeadSelectionController.getDuplicateContacts';


export default class LeadSelection extends LightningElement {
    @api firstName;
    @api lastName;
    @api companyName;
    @api phone;
    @api leadId;
    @api accountId;
    @track selectedValue;
    @track showRadios = true;


    @track leads = [];
    @track contacts = [];
    @track error;

    connectedCallback() {
        this.getLeads();
        this.getContacts();
    }

    getLeads() {
        getDuplicateLeads({ firstName: this.firstName, lastName: this.lastName, company: this.companyName, phone: this.phone })
            .then(result => {
                this.leads = result;
                console.log(result);
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }
    getContacts() {
        getDuplicateContacts({ firstName: this.firstName, lastName: this.lastName, company: this.companyName, phone: this.phone })
            .then(result => {
                this.contacts = result;
                console.log(result);
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }
    handleradiochange(event) {
        this.leadId = event.target.value;
        this.accountId = null;
        console.log(this.leadId);
        console.log(this.accountId);
    }
    handlecontactchange(event) {
        this.accountId = event.target.value;
        this.leadId = null;
        console.log(this.leadId);
        console.log(this.accountId);
    }
     @api
        validate() {

            if(!this.leadId && !this.accountId ){
                 return {
                        isValid: false,
                        errorMessage: 'Please select one Lead or Contact from the list!'
                     };
            }
            return { isValid: true };

        }
}