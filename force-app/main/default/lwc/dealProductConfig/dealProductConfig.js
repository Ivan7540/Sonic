/**
 * Created by JurgitaG on 12/2/2021.
 */

import { LightningElement, wire, api, track} from 'lwc';
import getProductOptions from '@salesforce/apex/DealProductController.getProductOptions';
import getDeviceOptions from '@salesforce/apex/DealProductController.getDeviceOptions';
import getContractTermOptions from '@salesforce/apex/DealProductController.getContractTermOptions';
import createBundleLine from '@salesforce/apex/DealProductController.createBundleLine';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
//import BUNDLE_CONFIG_OBJECT from "@salesforce/schema/BundleConfig__c";
//import PRODUCT_FIELD from "@salesforce/schema/BundleConfig__c.Product__c";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import DEALLINE_BUNDLE from '@salesforce/schema/Deal_Line__c.Product__c';
import DEALLINE_DEVICE from '@salesforce/schema/Deal_Line__c.Device__c';
import DEALLINE_CONTRACT_TERM from '@salesforce/schema/Deal_Line__c.ContractTerm__c';
import DEALLINE_QUANTITY from '@salesforce/schema/Deal_Line__c.Quantity__c';
import DEALLINE_METADATAID from '@salesforce/schema/Deal_Line__c.MetadataId__c';

export default class DealProductConfig extends LightningElement {
    @api recordId;
    @track productOptionArray = [];
    @track deviceOptionArray = [];
    @track contractTermOptionArray = [];
    @track additionalFields= [];

    @track bundleSelected;
    @track deviceSelected;
    @track contractSelected;
    @track quantity;
    @track metadataId;
    @api objectApiName ='Deal_Line__c'
    @track rerenderForm = false;


    @api bundleId;

    @wire(getRecord, {
        recordId: '$bundleId',
        fields: [
            DEALLINE_BUNDLE,
            DEALLINE_DEVICE,
            DEALLINE_CONTRACT_TERM,
            DEALLINE_QUANTITY,
            DEALLINE_METADATAID
        ]
    })

    wiredContent({ error, data }) {
        this.dealLine = data;
        this.initialLoadData();
    }

    connectedCallback() {
        this.getProducts();
    }

    initialLoadData() {
        if (this.bundleId) {
            this.bundleSelected = this.dealLine.fields.Product__c.value;
            this.getDevices(this.bundleSelected);
            this.deviceSelected = this.dealLine.fields.Device__c.value;
            this.getContractTerm(this.bundleSelected, this.deviceSelected, this.bundleId);
            this.contractSelected = this.dealLine.fields.ContractTerm__c.value;
            this.quantity = this.dealLine.fields.Quantity__c.value;
            this.metadataId = this.dealLine.fields.MetadataId__c.value;
        } else {
            return false;
        }
    }

    getProducts() {
        getProductOptions().then(result => {
                this.productOptions = result;
                for (let key in result) {
                    this.productOptionArray = [...this.productOptionArray, {
                        value: key,
                        label: result[key]
                    }];
                }
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }

    getDevices(productName) {
        getDeviceOptions({
                productName: productName
            }).then(result => {
                this.deviceOptionArray = [];
                for (let key in result) {
                    this.deviceOptionArray = [...this.deviceOptionArray, {
                        value: key,
                        label: result[key]
                    }];
                }
                console.log({result});
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }

    getContractTerm(productName, deviceName) {
        getContractTermOptions({
                productName: productName,
                deviceName: deviceName
            }).then(result => {
                console.log(result);
                this.contractTermOptionArray = result;
                if (result[0].additionalFields) {
                    this.additionalFields = result[0].additionalFields.split(",");
                    console.log(this.additionalFields);
                }
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });
    }

    handleProductSelect(event) {
        this.additionalFields = [];
        this.bundleSelected = event.detail.value;
        this.contractSelected='';
        this.deviceSelected='';
        this.getDevices(this.bundleSelected);
        this.getContractTerm(this.bundleSelected, '');
    }

    handleDeviceSelect(event) {
        this.additionalFields = [];
        this.deviceSelected = event.detail.value;
        console.log(this.bundleId);
        this.contractSelected ='';
        this.getContractTerm(this.bundleSelected, this.deviceSelected);
    }

    handleContractSelected(event) {
        this.additionalFields = [];
        this.contractSelected = event.detail.value;
        let selectedTerm = this.contractTermOptionArray.filter(el =>
            el.value == this.contractSelected,
        );
        this.metadataId = selectedTerm[0].metadataId;
        if(selectedTerm[0].additionalFields){
            this.additionalFields = selectedTerm[0].additionalFields.split(",");
        }
    }

    handleQuantityChange(event) {
        this.quantity = event.detail.value;
    }

    handleSave(event) {
        let isFieldsCorrect = true;
        let mandatoryFields = [
            //[0:value, 1:class, 2:error Message]
            [this.bundleSelected, 'dealWizard-bundle', 'Please select bundle'],
            [this.deviceSelected, 'dealWizard-device', 'Please select device'],
            [this.contractSelected, 'dealWizard-contract-term', 'Please select contract term'],
            [this.quantity, 'dealWizard-quantity', 'Please enter quantity'],
        ];
        for(var i = 0; i < mandatoryFields.length; i++) {
            console.log(mandatoryFields[i][0]);
            let inputCmp = this.template.querySelector('.' + mandatoryFields[i][1]);
            if (mandatoryFields[i][0] === undefined || mandatoryFields[i][0] === null) {
                inputCmp.setCustomValidity(mandatoryFields[i][2]);
                inputCmp.reportValidity();
                isFieldsCorrect = false;
            } else {
//                closeValidation(inputCmp);
            }
        }
        console.log(isFieldsCorrect);
        if (isFieldsCorrect) {
            const input={
                productName: this.bundleSelected,
                deviceName: this.deviceSelected,
                contractTerm: this.contractSelected,
                quantity: this.quantity,
                dealId: this.recordId,
                bundleId: this.bundleId,
                metadataId: this.metadataId
            } ;
            console.log({...input});
            createBundleLine(input).then(result => {
                this.bundleId = result.Id;
                this.metadataId = result.MetadataId__c;
                this.rerenderForm = true;
                console.log('BundleId: '+ this.bundleId);
                if (!!this.additionalFields?.length) {
                    let formItem = this.template.querySelector('lightning-record-edit-form');
                    console.log(JSON.parse(JSON.stringify(formItem)));
                    console.log({result});
                    this.saveAdditionalFields();
                } else {
                    this.onBundleSaved(event);
                }

            })
            .catch(error => {
                this.error = error;
                console.log({error});
            });

        }
    }
    saveAdditionalFields(){
       const fields = {};
       fields['Id'] = this.bundleId;
        let that = this;
       this.additionalFields.forEach(function(element){
           console.log(element);
           console.log("[data-name=\""+element+"\"]");
           let inputField = that.template.querySelector("[data-name=\""+element+"\"]");
           if(inputField.type ==='checkbox'){
              fields[element] = inputField.checked;
           }else{
             fields[element] = inputField.value;
           }
       })
       const recordInput = { fields };

       updateRecord(recordInput)
           .then(() => {
               this.onBundleSaved();
           })
           .catch(error => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Error saving record',
                       message: error.body.message,
                       variant: 'error'
                   })
               );
           });
       }

    onBundleSaved(event) {


        const passEvent = new CustomEvent('bundlesaved', {
            detail: {
                metadataId: this.metadataId,
                bundleId: this.bundleId,
            }
        });
        this.dispatchEvent(passEvent);
    }
    get showAdditionalFields(){
        return (this.additionalFields.length > 0 || this.rerenderForm);
    }
    get bundleIdValue(){
        return this.bundleId;
    }
}