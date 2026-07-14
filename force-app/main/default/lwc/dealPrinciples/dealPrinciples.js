/**
 * Created by JurgitaG on 4/16/2021.
 */

import { LightningElement, api, wire, track } from 'lwc';
import getAccountContacts from '@salesforce/apex/DealPrinciplesController.getAccountContacts';
import saveContacts from '@salesforce/apex/DealPrinciplesController.saveContacts';
import ROLE_FIELD from '@salesforce/schema/AccountContactRelation.Roles';
import ACCOUNT_RELATION_OBJECT from '@salesforce/schema/AccountContactRelation';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class DealPrinciples extends LightningElement {
    @api availableActions = [];
    @api recordId;
    @track activeSections = [];
    @track possibleDuplicates = [];
    @track errorMessage ='';
    @track contacts = [
    ];
    @track deletedContacts = [
    ];
    connectedCallback() {
        this.getContacts();
        this.contacts = JSON.parse(JSON.stringify(this.contacts));
        var that = this;
        console.log(this.contacts);
        this.contacts.forEach(function (element) {
            element.key = that.getUuid();
        });
        console.log(this.contacts);
    }

    getActiveSections() {
        this.activeSections = [];
        var activeSectionsList = [];
        var that = this;
        this.contacts.forEach(function (element) {
            activeSectionsList = [...activeSectionsList, element.key];
        });
        this.activeSections = activeSectionsList;
        console.log(JSON.parse(JSON.stringify(this.activeSections)));
    }

    getContacts() {
        getAccountContacts({ dealId: this.recordId })
            .then(result => {
                this.contacts = result;
                var that = this;
                this.contacts.forEach(function (element) {
                    element.key = that.getUuid();
                });
                this.getActiveSections();
                console.log(result);
                console.log(this.contacts);
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }
    saveAccContacts() {
        saveContacts({ principlesString: JSON.stringify(this.contacts), recordId: this.recordId, deletedIds: JSON.stringify(this.deletedContacts) })
            .then(result => {
                //                 this.contacts = result;
                console.log(result);
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }

    handleFirstName(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.contacts[index].firstname = inputValue;
        }
    }
    handleLastName(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.contacts[index].lastname = inputValue;
        }
    }

    handlePhone(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        console.log(index);
        console.log(uuid);
        if (index !== -1) {
            this.contacts[index].phone = inputValue;
        }
    }
    handleEmail(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        console.log(index);
        console.log(uuid);
        if (index !== -1) {
            this.contacts[index].email = inputValue;
        }
    }
    handleLandline(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        console.log(index);
        console.log(uuid);
        if (index !== -1) {
            this.contacts[index].landline = inputValue;
        }
    }
    handleIdNumber(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        console.log(index);
        console.log(uuid);
        if (index !== -1) {
            this.contacts[index].idNumber = inputValue;
        }
    }
    handleStrength(event) {
        const inputValue = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        console.log(index);
        console.log(uuid);
        if (index !== -1) {
            this.contacts[index].relationshipStrength = inputValue;
        }
    }
    handleRole(event) {
        const inputValue = event.target.value;
        console.log(inputValue);
        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)

        if (index !== -1) {
            this.contacts[index].Roles = inputValue;
        }
        console.log(this.contacts);
    }


    handleAddRow() {
        this.template.querySelector('c-deal-principal-modal').openModal();

    }
    saveItem(event) {
        const newContact = event.detail.contact;
        this.contacts = [...this.contacts, {
            key: this.getUuid(),
            contactId: newContact.contactId,
            firstname: newContact.firstname,
            lastname: newContact.lastname,
            phone: newContact.phone,
            email: newContact.email,
            idNumber: newContact.idNumber,
            Roles: newContact.Roles,
        }];
        this.getActiveSections();
    }
    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    removeProduct(event) {
        const uuid = event.target.accessKey;
        const index = this.contacts.findIndex(item => item.key === uuid)
        console.log(index);
        this.deletedContacts = [
            ...this.deletedContacts, this.contacts[index].contactId
        ];
        this.contacts.splice(index, 1);
        this.getActiveSections();
        //                        this.contacts = this.contacts.filter(item => item.key !== index);
        console.log(JSON.parse(JSON.stringify(this.contacts)));
    }
    handleGoNext() {
        var results = this.validate();
        console.log(JSON.parse(JSON.stringify(this.contacts)));
        console.log(results);
        if(results.isValid){
            this.saveAccContacts();
            var navigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigationEvent);
        }else{
            this.errorMessage = results.errorMessage;
        }
    }

    @api
    validate() {
        var splitTotal = 0;
        var isFilled= true;
        this.contacts.forEach(function (element) {
            if (!element.idNumber) {
               isFilled = false;
            }
            if (!element.email) {
               isFilled = false;
            }
        });
        if (!isFilled){
            return {
               isValid: false,
               errorMessage: 'Email and ID Number Residential Permit are required!'
           };
        }

        return { isValid: true };
    }
}