/**
 * Created by JurgitaG on 4/23/2021.
 */

import { LightningElement, track, api, wire } from 'lwc';
import ROLE_FIELD from '@salesforce/schema/AccountContactRelation.Roles';
import ACCOUNT_RELATION_OBJECT from '@salesforce/schema/AccountContactRelation';

export default class DealPrincipalModal extends LightningElement {
@track isModalOpen = false;
    @api contact ;
    @track firstName;
    @track lastName;
    @track phone;
    @track email;
    @track idNumber;
    @track duplicates=[];

    @api
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        //check if it has Duplicates


         this.isModalOpen = false;
         this.contact = {
                      firstname:this.firstName,
                      lastname: this.lastName,
                      phone: this.phone,
                      email: this.email,
                      idNumber: this.idNumber,
                  };
          this.onContactSave();



    }
    handleFirstName(event) {
        this.firstName = event.target.value;
    }
    handleLastName(event) {
        this.lastName = event.target.value;
    }
    handlePhone(event) {
        this.phone = event.target.value;
    }
    handleEmail(event) {
        this.email = event.target.value;
    }
    handleId(event) {
        this.idNumber = event.target.value;
    }


    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    onContactSave(){
       const passEventr = new CustomEvent('addcontactevent', {
         detail: { contact: this.contact }
        });
        this.dispatchEvent(passEventr);
      }
}