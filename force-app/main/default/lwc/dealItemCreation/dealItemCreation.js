import { LightningElement, track, wire, api } from 'lwc';

const FEE_CODE_ENDING = "_PER_TRANSACTION_FEES";
const RATE_CODE_ENDING = "_FEES";
export default class DealItemCreation extends LightningElement {
    @track accountName;
    @track accountRecordId;
    @api records = [];

    onProductSelect(event) {
        console.log(event.target.accessKey);
        console.log(event.detail.accessKey);
        const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)

        if (index !== -1) {
            this.records[index].Name = event.detail.selectedValue;
           this.records[index].Rate__c = event.detail.selectedRecordId;
        }

        console.log(this.records);

    }
    connectedCallback() {

        console.log(this.records);
        this.records = JSON.parse(JSON.stringify(this.records));
        console.log(this.records);
        console.log(this.getUuid());
        var that = this;
        this.records.forEach(function(element){
            element.key = that.getUuid();
            element.Rate_Percentage__c = parseFloat(element.Rate_Percentage__c);
            element.CardSplit__c = parseFloat(element.CardSplit__c);
            element.TransactionFee__c = parseFloat(element.TransactionFee__c);
            if (element.ProductCode__c.endsWith(FEE_CODE_ENDING)){
                element.disableRate= true;
                element.disableFee=false;
            } else
            {
                element.disableFee= true;
                element.disableRate=false;
            }
        });
      }

      getUuid() {
                return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                  var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
                  return v.toString(16);
                });
          }
//      connectedCallback(){
//          console.log(this.records);
//      }
    savePercentage(event) {
//        const index = event.target.accessKey;
//        console.log(event.target.value);
        const percentage  = parseFloat(event.target.value);
////        event.target.value = percentage;
         const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)

        if (index !== -1) {
            this.records[index].Rate_Percentage__c = percentage;
        }
        console.log(this.records[index].Rate_Percentage__c);
    }
    saveCardSplit(event) {
//        const index = event.target.accessKey;
//        console.log(event.target.value);
        const percentage  = parseFloat(event.target.value);
////        event.target.value = percentage;
         const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)

        if (index !== -1) {
            this.records[index].CardSplit__c = percentage;
        }
    }
    saveTransactionFee(event) {
        const percentage  = parseFloat(event.target.value);
         const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)

        if (index !== -1) {
            this.records[index].TransactionFee__c = percentage;
        }
    }

    handleAddRow() {
        this.records = [...this.records, {
            key: this.getUuid(),
            Name:'',
            Rate__c: '',
            Rate_Percentage__c: '',
            CardSplit__c: '',
        }];
        console.log(' After adding Record List ', this.records);
    }

    removeRecord(event) {
        const index = event.detail.accessKey;
        console.log(index);
//        this.records = this.records.splice(index, 1);
        this.records = this.records.filter(item => item.key !== index);
    }
    formatResults(){
        var splitTotal = 0;
        this.records.forEach(function(element){
            element.Rate_Percentage__c = parseFloat(element.Rate_Percentage__c);
        });
    }
    isNumeric(num){
      return !isNaN(num)
    }
    @api
    validate() {
         var splitTotal = 0;
        this.records.forEach(function(element){
            if (!isNaN(element.CardSplit__c)){
                splitTotal += parseFloat(element.CardSplit__c);
            }
        });
        console.log(splitTotal);
        if(splitTotal>100){
            return {
                isValid: false,
                errorMessage: 'Card Split Total cannot be more than 100%'
             };
        }
        if(splitTotal<100){
            return {
                isValid: false,
                errorMessage: 'Card Split Total must be 100%'
             };
        }
          return { isValid: true };
    }
}