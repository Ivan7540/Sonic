/**
 * Created by JurgitaG on 5/25/2021.
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getBranchCodes from '@salesforce/apex/DynamicBranchCodeController.getBranchCodes';

const FIELDS = [
    'BankBranchCode__mdt.MasterLabel',
    'BankBranchCode__mdt.BranchCode__c',
];

export default class DynamicBranchCode extends LightningElement {
    @api bankName;
    @api branchCode;

    @track mapData = new Map();

    @wire(getBranchCodes) branchCodeMap(result) {
                          console.log(result);

       if (result.data) {
           //mapData = [];
           var conts = result.data;
           for(var key in conts){
                console.log(key);
                console.log(conts[key]);

               this.mapData.set(key, conts[key]);
               console.log(this.mapData);
//Here we are creating the array to show on UI.
           }
       }
   }

    handleBank(event){
         this.bankName = event.target.value;
         this.branchCode = this.mapData.get(this.bankName);

    }
    handleBranch (event){
         this.branchCode = event.target.value;
    }

}