/**
 * Created by JurgitaG on 5/5/2021.
 */

import { LightningElement, api, track, wire } from 'lwc';

import BUSINESS_HOUR_FROM_FIELD from '@salesforce/schema/Account.Business_Hours_From__c';
import BUSINESS_HOUR_TO_FIELD from '@salesforce/schema/Account.Business_Hours_To__c';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';


export default class OfficeUse extends LightningElement {
    // The record page provides recordId and objectApiName
    @api recordId;
    @api merchantId;
    @api objectApiName;
    @track hoursFrom;
    @track hoursTo;
    @track requireVAT= true;
        @wire(getRecord, { recordId: '$recordId', fields: [BUSINESS_HOUR_FROM_FIELD, BUSINESS_HOUR_TO_FIELD] })
            account;
    get hoursFromValue() {
            return getFieldValue(this.account.data, BUSINESS_HOUR_FROM_FIELD);
        }
        get hoursToValue() {
            return getFieldValue(this.account.data, BUSINESS_HOUR_TO_FIELD);
        }

        handleToTime(event) { this.hoursTo = event.detail.value; }
        handleFromTime(event) { this.hoursFrom = event.detail.value; }
        handleNotRegistered(event) {
        this.requireVAT = !event.detail.checked;
         }

    handleSubmit(event){
        event.preventDefault();      // stop the form from submitting
        const fields = event.detail.fields;// modify a field
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input-field')]
                    .reduce((validSoFar, inputField) => {
                        inputField.reportValidity();
                        return validSoFar && inputField.checkValidity();
                    }, true);
        if (isInputsCorrect) {
            //perform success logic
            this.template.querySelector('lightning-record-edit-form').submit(fields);
         }
     }
     handleSuccess(event){
         var navigationEvent = new FlowNavigationNextEvent();
                 this.dispatchEvent(navigationEvent);
     }
}