/**
 * Created by JurgitaG on 4/8/2021.
 */

import { LightningElement, api, track } from 'lwc';

export default class RebateConfiguration extends LightningElement {
    @api records = [];
    @api rebates = [];
    @api additionalRebates = [];
    @track availableOptions = [];
    @track allOptions = [];
    @track noOptions = false;
    connectedCallback() {

        console.log(this.records);
        this.records = JSON.parse(JSON.stringify(this.records));
        this.rebates = JSON.parse(JSON.stringify(this.rebates));
        console.log(this.records);
        var that = this;
        var hasFreeInstall = false;
        this.records.forEach(function (element) {
            element.key = that.getUuid();
            var optionValue = element.BundleId__c;
            var optionLabel = element.Product__c;

            if (element.RebatedProduct__c == 'SS_INSTALL_TRAINING_FEE') {
                hasFreeInstall = true;
                optionValue = element.RebatedProduct__c;
                optionLabel = 'Installation Fee';
            }
                that.availableOptions = [...that.availableOptions, {
                    label: optionLabel,
                    value: optionValue
                }];

            that.allOptions = [...that.allOptions, {
                label: optionLabel,
                value: optionValue
            }];
        });

        if (!hasFreeInstall) {
            this.availableOptions = [...this.availableOptions, {
                label: 'Installation Fee',
                value: 'SS_INSTALL_TRAINING_FEE'
            }];
            this.allOptions = [...this.allOptions, {
                label: 'Installation Fee',
                value: 'SS_INSTALL_TRAINING_FEE'
            }];
        }

        if (this.availableOptions.length == 0) {
            this.noOptions = true;
        }
        console.log(this.allOptions);
        console.log(this.rebates);


    }
    checkIfIsRebated(bundleId) {
        const index = this.rebates.findIndex(item => item.BundleId__c === bundleId);
        return index !== -1;
    }

    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    handleChange(event) {
        //        this[event.target.name] = event.target.value;
        const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)
        var finalValue = event.target.value;
        console.log(event.target);
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
        }
        if (index !== -1) {

            this.records[index][event.target.fieldName] = finalValue;
        }
    }

    handleQuantity(event) {
        //        this[event.target.name] = event.target.value;
        const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)
        var finalValue = event.target.value;
        console.log(event.target);
        let quantityField;

        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
            //                    if (this.records[index].Quantity__c<finalValue){
            //                        quantityField.setCustomValidity("Rebated quantity cannot be bigger that bundle device quantity!");
            //                    }else {
            //                                 //reset an error
            //                                quantityField.setCustomValidity('');
            //                                quantityField.reportValidity();
            //
            //                            }
        }
        if (index !== -1) {

            this.records[index][event.target.fieldName] = finalValue;
        }

    }
    handleDiscount(event) {
        //        this[event.target.name] = event.target.value;
        const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)
        var finalValue = event.target.value;
        console.log(event.target);
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
        }

        if (index !== -1) {

            this.records[index][event.target.fieldName] = finalValue;
            //                  this.records[index].discountFilled = true;
            //                  if (!finalValue ||finalValue.length === 0){
            //                      this.records[index].discountFilled = false;
            //                  }
        }

    }
    handleDiscountAmount(event) {
        //        this[event.target.name] = event.target.value;
        const uuid = event.target.accessKey;
        const index = this.records.findIndex(item => item.key === uuid)
        var finalValue = event.target.value;
        console.log(event.target);
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
        }

        if (index !== -1) {
            //                    this.records[index].amountFilled = true;
            this.records[index][event.target.fieldName] = finalValue;
            //                  if (!finalValue || finalValue.length === 0){
            //                        this.records[index].amountFilled = false;
            //                    }
        }
    }
    handleAddRebate() {
        this.template.querySelector('c-rebate-modal').openModal();
    }
    handleAddRow() {
        this.rebates = [...this.rebates, {
            key: this.getUuid(),
            Name: '',
            Product__c: null,
            Device__c: null,
            BundleId__c: null,
            RebatedProduct__c: null,
            RebatedQuantity__c: null,
            RebateMonths__c: null,
            RebateMotivation__c: null,
            RebateDiscountPercentage__c: null,
            RebateDiscountAmount__c: null,
        }];
        console.log(' After adding Record List ', this.rebates);
    }

    saveItem(event) {
        console.log(event.detail.key);
        const uuid = event.detail.key;
        const index = this.rebates.findIndex(item => item.key === uuid);
        this.rebates[index].RebatedQuantity__c = event.detail.rebateQuantity;
        this.rebates[index].RebateMonths__c = event.detail.rebateMonths;
        this.rebates[index].RebateDiscountPercentage__c = event.detail.rebateDiscount;
        this.rebates[index].RebateDiscountAmount__c = event.detail.rebateAmount;
        this.rebates[index].RebateMotivation__c = event.detail.rebateMotivation;

        console.log(' After adding Record List ', this.rebates);
    }
    handleOptions(event) {
        console.log(event.detail.key);
        console.log(event.detail.selected);
        const newProduct = event.detail.selected;
        const rebateLabel = event.detail.selectedLabel;

        const key = event.detail.key;
        const index2 = this.rebates.findIndex(item => item.key === key);
        this.rebates[index2].selectedProduct = newProduct;
        this.rebates[index2].selectedProductLabel = rebateLabel;

        this.rebates[index2].RebatedQuantity__c = event.detail.rebateQuantity;
        this.rebates[index2].RebateMonths__c = event.detail.rebateMonths;
        this.rebates[index2].RebateDiscountPercentage__c = event.detail.rebateDiscount;
        this.rebates[index2].RebateDiscountAmount__c = event.detail.rebateAmount;
        this.rebates[index2].RebateMotivation__c = event.detail.rebateMotivation;

        if (newProduct == 'SS_INSTALL_TRAINING_FEE') {
            this.rebates[index2].RebatedProduct__c = newProduct;
            this.rebates[index2].BundleId__c = null;


        }
        else {
            const indexRecords = this.records.findIndex(item => item.BundleId__c === newProduct);
            this.rebates[index2].Quantity__c = this.records[indexRecords].Quantity__c;
            this.rebates[index2].Device__c = this.records[indexRecords].Device__c;
            this.rebates[index2].Product__c = this.records[indexRecords].Product__c;
            this.rebates[index2].BundleId__c = newProduct;
            this.rebates[index2].RebatedProduct__c = null;
        }
        this.filterOptions();


        console.log(' After adding Record List ', this.availableOptions);
    }

    filterOptions() {
        var selectedItems = [];
        console.log(this.availableOptions);
        console.log(this.allOptions);
        var that = this;
        this.rebates.forEach(function (element) {
            console.log('test2');
            console.log(element);

            if (element.BundleId__c != null) {
                console.log(selectedItems);
                selectedItems = [...selectedItems, element.BundleId__c];
                console.log('test3');

            }
            else {
                selectedItems = [...selectedItems, element.RebatedProduct__c];
                console.log('test4');

            }

        });
        console.log('test');

        this.availableOptions = this.allOptions.filter(item => !selectedItems.includes(item.value))
        console.log(this.availableOptions);
        console.log(this.allOptions);

        if (this.availableOptions.length == 0) {
            this.noOptions = true;
        }
        else {
            this.noOptions = false;
        }
    }
    isInt(n) {
        return Number(n) === n && n % 1 === 0;
    }

    isFloat(n) {
        return Number(n) === n && n % 1 !== 0;
    }
    isNumeric(num) {
        return !isNaN(num)
    }
    removeRebate(event) {
        const uuid = event.detail.key;
        const index = this.rebates.findIndex(item => item.key === uuid);
        console.log(index);
        this.rebates = this.rebates.filter(item => item.key !== uuid);
        this.filterOptions();

        //           this.rebates.splice(index, 1);
    }

    @api
    validate() {
        var quantityLimit = false;
        var bothDiscountsFilled = false;
        var bothDiscountEmpty = false;
        this.rebates.forEach(function (element) {
            if (element.Quantity__c!= null && element.RebatedQuantity__c > element.Quantity__c) {
                            console.log(element);
                quantityLimit = true;
            }
            if (element.RebateDiscountPercentage__c && element.RebateDiscountAmount__c) {
                bothDiscountsFilled = true;
            }
            if (isNaN(element.RebateDiscountPercentage__c) || isNaN(element.RebateDiscountAmount__c)) {
               bothDiscountEmpty = true;

            }
        });
        if (quantityLimit) {
            return {
                isValid: false,
                errorMessage: 'Cannot rebate more devices than was selected on bundle'
            };
        }
        if (bothDiscountsFilled) {
            return {
                isValid: false,
                errorMessage: 'Only one Discount or Discount Amount can be rebated'
            };
        }
         if (bothDiscountEmpty) {
            return {
                isValid: false,
                errorMessage: 'One of the Discount fields must be filled!'
            };
        }
        return { isValid: true };
    }
}