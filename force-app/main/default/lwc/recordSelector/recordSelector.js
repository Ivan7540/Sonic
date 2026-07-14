/**
 * Created by JurgitaG on 11/12/2021.
 */

import { LightningElement, api } from 'lwc';
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
];
export default class RecordSelector extends LightningElement {
    @api contactList=[];
    @api selectedContactId;
    columns = columns;



    connectedCallback(){
           console.log(this.contactList);
           this.contactList = JSON.parse(JSON.stringify(this.contactList));
                      console.log(this.contactList);

       }
    getSelectedName(event) {
            const selectedRows = event.detail.selectedRows;
            // Display that fieldName of the selected rows
            for (let i = 0; i < selectedRows.length; i++) {
                this.selectedContactId = selectedRows[i].Id;
            }
        }
        @api
        validate() {
            if(this.selectedContactId) {
                return { isValid: true };
            }
            else {
                // If the component is invalid, return the isValid parameter
                // as false and return an error message.
                return {
                    isValid: false,
                    errorMessage: 'You must select one of the Principles!'
                 };
             }
        }
}