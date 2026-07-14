import {LightningElement, api, track} from 'lwc';
import getRebateItems from '@salesforce/apex/DealProductController.getOptionsForRebate';
import saveRebates from '@salesforce/apex/DealProductController.saveRebates';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class DealBundleRebate extends LightningElement {
    @api bundleId;
    @api selectedMetadataId;
    @api records = [];
    @api rebates = [];
    @api additionalRebates = [];
    @track availableOptions = [];
    @track allOptions = [];
    @track noOptions = false;
    @track validationMessage = '';

    connectedCallback() {
        getRebateItems({
            bundleId: this.bundleId,
            metadataId: this.selectedMetadataId
        }).then(result => {
            var that = this;
            result.forEach(function (element) {
                console.log('element');
                console.log(element);
                element.key = that.getUuid();
                that.records = [...that.records, element];
            });
            this.records.forEach(function (element) {
                element.key = that.getUuid();
                var optionValue = element.itemName;
                var optionLabel = element.itemLabel;
                that.availableOptions = [...that.availableOptions, {
                    label: optionLabel,
                    value: optionValue
                }];
                that.allOptions = [...that.allOptions, {
                    label: optionLabel,
                    value: optionValue
                }];
            });


            if (this.availableOptions.length == 0) {
                this.noOptions = true;
            }
        })
            .catch(error => {
                this.error = error;
                console.log(error);
            });

        console.log(this.records);
        this.records = JSON.parse(JSON.stringify(this.records));
        this.rebates = JSON.parse(JSON.stringify(this.rebates));
        console.log(this.records);
        //        var that = this;

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

    handleAddRow() {
        this.rebates = [...this.rebates, {
            key: this.getUuid(),
            itemLabel: '',
            itemName: '',
            maxQuantity: null,
            quantity: null,
            numberOfMonths: null,
            rebateDiscount: null,
            rebateAmount: null,
            discount: null,
            discountAmount: null,
            rebateReason: '',
            rebateMotivation: ''
        }];
        console.log(' After adding Record List ', this.rebates);
    }

    saveItem(event) {
        console.log(event.detail.key);
        console.log(event.detail.discountAmount);
        const uuid = event.detail.key;
        const index = this.rebates.findIndex(item => item.key === uuid);
        this.rebates[index].quantity = event.detail.rebateQuantity;
        this.rebates[index].numberOfMonths = event.detail.rebateMonths;
        this.rebates[index].rebateDiscount = event.detail.rebateDiscount;
        this.rebates[index].rebateAmount = event.detail.rebateAmount;
        this.rebates[index].discount = event.detail.discount;
        this.rebates[index].discountAmount = event.detail.discountAmount;
        this.rebates[index].rebateMotivation = event.detail.rebateMotivation;
        this.rebates[index].rebateReason = event.detail.rebateReason;

        console.log(' After adding Record List ', this.rebates);
    }

    handleOptions(event) {
        console.log(event.detail.key);
        console.log(event.detail.selected);
        console.log(JSON.parse(JSON.stringify(this.rebates)));
        console.log(JSON.parse(JSON.stringify(this.records)));
        const newProduct = event.detail.selected;
        const rebateLabel = event.detail.selectedLabel;

        const key = event.detail.key;
        const rebateItem = this.rebates.find(item => item.key === key);
        const indexOfRebateItem = this.records.findIndex(item => item.itemName === newProduct);
        console.log(rebateItem);
        console.log(JSON.parse(JSON.stringify(this.records[indexOfRebateItem])));

        rebateItem.itemName = newProduct;
        rebateItem.itemLabel = rebateLabel;

        rebateItem.quantity = this.records[indexOfRebateItem].quantity;
        rebateItem.maxQuantity = this.records[indexOfRebateItem].maxQuantity;
        rebateItem.numberOfMonths = this.records[indexOfRebateItem].numberOfMonths;
        rebateItem.rebateDiscount = this.records[indexOfRebateItem].rebateDiscount;
        rebateItem.rebateAmount = this.records[indexOfRebateItem].rebateAmount;
        rebateItem.rebateMotivation = this.records[indexOfRebateItem].rebateMotivation;
        rebateItem.rebateReason = this.records[indexOfRebateItem].rebateReason;
        rebateItem.discount = this.records[indexOfRebateItem].discount;
        rebateItem.discountAmount = this.records[indexOfRebateItem].discountAmount;


        rebateItem.disableQuantity = this.records[indexOfRebateItem].disableQuantity;
        rebateItem.disableNumberOfMonths = this.records[indexOfRebateItem].disableNumberOfMonths;
        rebateItem.disableRebateDiscount = this.records[indexOfRebateItem].disableRebateDiscount;
        rebateItem.disableRebateAmount = this.records[indexOfRebateItem].disableRebateAmount;
        rebateItem.disableDiscount = this.records[indexOfRebateItem].disableDiscount;
        rebateItem.disableDiscountAmount = this.records[indexOfRebateItem].disableDiscountAmount;

        this.rebates = [...this.rebates];
        console.log(JSON.parse(JSON.stringify(this.rebates)));
        this.filterOptions();
        console.log(' After adding Record List ', this.availableOptions);
    }

    filterOptions() {
        var selectedItems = [];
        console.log(this.availableOptions);
        console.log(this.allOptions);
        var that = this;
        this.rebates.forEach(function (element) {

            console.log(selectedItems);
            selectedItems = [...selectedItems, element.itemName];
            console.log('test4');
        });
        console.log('test');

        this.availableOptions = this.allOptions.filter(item => !selectedItems.includes(item.value))
        console.log(this.availableOptions);
        console.log(this.allOptions);

        if (this.availableOptions.length == 0) {
            this.noOptions = true;
        } else {
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
        this.validationMessage = '';
        let quantityLimit = false;
        let rebateItemSelected = true;
        let bothDiscountsFilled = false;
        let discountFilled = true;
        let reasonNotFilled = false;
        let rebateInfoMissing = false;
        console.log(JSON.parse(JSON.stringify(this.rebates)));
        this.rebates.forEach(function (element) {
            discountFilled = false;
            console.log(JSON.parse(JSON.stringify(element)));
            if (element.quantity != null && element.quantity > element.maxQuantity) {
                console.log(element);
                quantityLimit = true;
            }
            if (!Boolean(element.itemName)) {
                rebateItemSelected = false;
            }

            if ((element.rebateDiscount > 0) || (element.rebateAmount > 0) || (element.discount > 0) || (element.discountAmount > 0)) {
                discountFilled = true;
            }
            if (((element.rebateDiscount > 0) || (element.rebateAmount > 0)) && (!element.quantity || element.quantity < 1 || !element.numberOfMonths || element.numberOfMonths < 1)){
                rebateInfoMissing = true;
            }
            if (!element.rebateReason) {
                reasonNotFilled = true;
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
        if (!discountFilled) {
            return {
                isValid: false,
                errorMessage: 'One of the discounts or rebates must be filled!'
            };
        }
        if (rebateInfoMissing) {
            return {
                isValid: false,
                errorMessage: 'Number of products and months must be filled for Rebate Items'
            };
        }
        if (reasonNotFilled) {
            return {
                isValid: false,
                errorMessage: 'Rebate / Discount Reason is required!'
            };
        }
        if (!rebateItemSelected) {
            return {
                isValid: false,
                errorMessage: 'Please select Rebate / Discount Item!'
            };
        }
        return {isValid: true};
    }

    onDiscountSubmit(event) {
        console.log(event);
        let validationResults = this.validate();
        if (!validationResults.isValid) {
            this.validationMessage = validationResults.errorMessage;
            return;
        }
        saveRebates({
            rebateJSON: JSON.stringify(this.rebates),
            bundleId: this.bundleId
        }).then(result => {
            console.log(result);
            const passEvent = new CustomEvent('closebundle', {});
            this.dispatchEvent(passEvent);
        })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving rebates',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });


    }
}